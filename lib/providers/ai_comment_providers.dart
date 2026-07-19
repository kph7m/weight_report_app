import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_comment_request.dart';
import '../models/open_ai_exchange.dart';
import '../models/weight_entry.dart';
import '../services/openai_responses_service.dart';
import 'weight_providers.dart';

const aiCommentFailureMessage = '今日はコメントを生成できませんでした。';

enum AiCommentGenerationStatus { idle, generating, success, failure }

class AiCommentGenerationState {
  const AiCommentGenerationState(
    this.status, {
    this.comment,
    this.error,
    this.stackTrace,
  });

  const AiCommentGenerationState.idle()
    : status = AiCommentGenerationStatus.idle,
      comment = null,
      error = null,
      stackTrace = null;

  final AiCommentGenerationStatus status;
  final String? comment;
  final Object? error;
  final StackTrace? stackTrace;
}

final openAiResponsesServiceProvider = Provider<OpenAiResponsesService>((ref) {
  return OpenAiResponsesService();
});

final aiCommentControllerProvider =
    StateNotifierProvider<AiCommentController, AiCommentGenerationState>((ref) {
      return AiCommentController(ref);
    });

class AiCommentController extends StateNotifier<AiCommentGenerationState> {
  AiCommentController(this._ref) : super(const AiCommentGenerationState.idle());

  final Ref _ref;

  Future<AiCommentGenerationState> generate({
    required double weightKg,
    required List<WeightEntry> entries,
  }) async {
    if (state.status == AiCommentGenerationStatus.generating) return state;
    state = const AiCommentGenerationState(
      AiCommentGenerationStatus.generating,
    );

    try {
      final repository = await _ref.read(weightRepositoryProvider.future);
      final settings = await repository.watchSettings().first;
      final apiKey = settings?.openAiApiKey;
      if (apiKey == null || apiKey.trim().isEmpty) {
        throw const AiCommentGenerationException(
          'OpenAI API key is not configured.',
        );
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sorted = [
        WeightEntry(date: today, weightKg: weightKg),
        ...entries.where((entry) => entry.date != today),
      ]..sort((a, b) => b.date.compareTo(a.date));
      final recent = sorted.take(7).toList();
      final previousWeight = sorted.length > 1 ? sorted[1].weightKg : null;
      final target = settings?.targetWeightKg;
      final request = AiCommentRequest(
        heightCm: settings?.heightCm,
        targetWeightKg: target,
        todayWeightKg: weightKg,
        previousDayDifferenceKg: previousWeight == null
            ? null
            : weightKg - previousWeight,
        remainingToTargetKg: target == null
            ? null
            : (weightKg - target).clamp(0, double.infinity).toDouble(),
        recentWeights: recent
            .map(
              (entry) =>
                  AiCommentDailyValue(date: entry.date, value: entry.weightKg),
            )
            .toList(),
        recentAverages: recent
            .map(
              (entry) => AiCommentDailyValue(
                date: entry.date,
                value: _sevenDayAverage(sorted, entry.date),
              ),
            )
            .toList(),
        previousComment: await repository.previousDayAiComment(today),
      );
      final comment = await _ref
          .read(openAiResponsesServiceProvider)
          .generateComment(
            apiKey: apiKey,
            request: request,
            onExchange: (exchange) => repository.saveLatestOpenAiExchange(
              OpenAiExchange(
                requestedAt: exchange.requestedAt,
                requestJson: exchange.requestJson,
                responseBody: exchange.responseBody,
                succeeded: exchange.succeeded,
                statusCode: exchange.statusCode,
                elapsedMilliseconds: exchange.elapsedMilliseconds,
                errorMessage: exchange.errorMessage,
              ),
            ),
          );
      await repository.saveAiComment(today, comment);
      state = AiCommentGenerationState(
        AiCommentGenerationStatus.success,
        comment: comment,
      );
    } on Object catch (error, stackTrace) {
      state = AiCommentGenerationState(
        AiCommentGenerationStatus.failure,
        comment: aiCommentFailureMessage,
        error: error,
        stackTrace: stackTrace,
      );
    }
    return state;
  }
}

double _sevenDayAverage(List<WeightEntry> entries, DateTime date) {
  final end = DateTime(date.year, date.month, date.day);
  final start = end.subtract(const Duration(days: 6));
  final values = entries.where(
    (entry) => !entry.date.isBefore(start) && !entry.date.isAfter(end),
  );
  final total = values.fold<double>(0, (sum, entry) => sum + entry.weightKg);
  return total / values.length;
}

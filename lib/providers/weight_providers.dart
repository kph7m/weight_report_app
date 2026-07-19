import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/ai_model.dart';
import '../models/open_ai_exchange.dart';
import '../models/weight_entry.dart';
import '../services/weight_repository.dart';
import '../services/ai_model_preferences.dart';
import '../services/openai_models_service.dart';

const targetWeightKg = 75.0;

final aiModelPreferencesProvider = Provider<AiModelPreferences>((ref) {
  return AiModelPreferences();
});

final selectedAiModelProvider = FutureProvider<AiModel>((ref) {
  return ref.watch(aiModelPreferencesProvider).loadSelected();
});

final cachedAiModelsProvider = FutureProvider<List<AiModel>>((ref) {
  return ref.watch(aiModelPreferencesProvider).loadCachedModels();
});

final openAiModelsServiceProvider = Provider<OpenAiModelsService>((ref) {
  return OpenAiModelsService();
});

final weightRepositoryProvider = FutureProvider<WeightRepository>((ref) {
  return WeightRepository.open();
});

final weightEntriesProvider = StreamProvider<List<WeightEntry>>((ref) async* {
  final repository = await ref.watch(weightRepositoryProvider.future);
  yield* repository.watchEntries();
});

final appSettingsProvider = StreamProvider<AppSettings?>((ref) async* {
  final repository = await ref.watch(weightRepositoryProvider.future);
  yield* repository.watchSettings();
});

final latestOpenAiExchangeProvider = StreamProvider<OpenAiExchange?>((
  ref,
) async* {
  final repository = await ref.watch(weightRepositoryProvider.future);
  yield* repository.watchLatestOpenAiExchange();
});

final sevenDayAverageProvider = Provider<double?>((ref) {
  final entries =
      ref.watch(weightEntriesProvider).valueOrNull ?? const <WeightEntry>[];
  if (entries.isEmpty) return null;

  final now = DateTime.now();
  final start = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));
  final recent = entries.where((entry) => !entry.date.isBefore(start)).toList();
  if (recent.isEmpty) return null;

  final total = recent.fold<double>(0, (sum, entry) => sum + entry.weightKg);
  return total / recent.length;
});

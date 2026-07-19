import 'package:flutter_test/flutter_test.dart';
import 'package:weight_report_app/models/ai_model.dart';
import 'package:weight_report_app/services/openai_responses_service.dart';
import 'package:weight_report_app/services/openai_models_service.dart';

void main() {
  group('validateAndNormalizeAiComment', () {
    test('rejects null, empty, and whitespace-only comments', () {
      expect(
        () => validateAndNormalizeAiComment(null),
        throwsA(isA<AiCommentGenerationException>()),
      );
      expect(
        () => validateAndNormalizeAiComment(''),
        throwsA(isA<AiCommentGenerationException>()),
      );
      expect(
        () => validateAndNormalizeAiComment('   \n'),
        throwsA(isA<AiCommentGenerationException>()),
      );
    });

    test('trims and limits comments to 300 characters', () {
      expect(validateAndNormalizeAiComment('  ごきげんよう  '), 'ごきげんよう');
      final result = validateAndNormalizeAiComment('あ' * 301);
      expect(result.runes.length, 300);
    });
  });

  test('AI model configuration is centrally defined', () {
    expect(AiModel.defaultModel.apiName, 'gpt-5.5-instant');
    expect(OpenAiResponsesService.timeout, const Duration(seconds: 30));
  });

  test('filters the Models API response to chat-capable GPT models', () {
    final models = parseChatGptModels({
      'data': [
        {'id': 'gpt-5.5'},
        {'id': 'chatgpt-4o-latest'},
        {'id': 'gpt-4o-realtime-preview'},
        {'id': 'gpt-audio-1'},
        {'id': 'text-embedding-3-small'},
        {'id': 'dall-e-3'},
      ],
    });

    expect(models.map((model) => model.apiName), [
      'chatgpt-4o-latest',
      'gpt-5.5',
    ]);
  });
}

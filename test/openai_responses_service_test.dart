import 'package:flutter_test/flutter_test.dart';
import 'package:weight_report_app/services/openai_responses_service.dart';

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

  test('API configuration is centrally defined', () {
    expect(openAiResponsesModel, isNotEmpty);
    expect(OpenAiResponsesService.timeout, const Duration(seconds: 30));
  });
}

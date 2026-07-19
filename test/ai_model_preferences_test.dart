import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight_report_app/models/ai_model.dart';
import 'package:weight_report_app/services/ai_model_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses GPT-5.5 Instant when no model has been saved', () async {
    expect(await AiModelPreferences().load(), AiModel.gpt55Instant);
  });

  test('restores the selected model', () async {
    final preferences = AiModelPreferences();
    await preferences.save(AiModel.gpt56Terra);

    expect(await AiModelPreferences().load(), AiModel.gpt56Terra);
  });

  test('falls back to the default for an unknown saved model', () async {
    SharedPreferences.setMockInitialValues({
      'selected_ai_model': 'removed-model',
    });

    expect(await AiModelPreferences().load(), AiModel.defaultModel);
  });
}

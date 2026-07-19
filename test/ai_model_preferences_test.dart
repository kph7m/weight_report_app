import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight_report_app/models/ai_model.dart';
import 'package:weight_report_app/services/ai_model_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses GPT-5.5 Instant when no model has been saved', () async {
    expect(await AiModelPreferences().loadSelected(), AiModel.defaultModel);
  });

  test('restores the selected model', () async {
    final preferences = AiModelPreferences();
    const model = AiModel('gpt-test-chat');
    await preferences.saveSelected(model);

    expect(await AiModelPreferences().loadSelected(), model);
  });

  test('restores a model id supplied by the API', () async {
    SharedPreferences.setMockInitialValues({
      AiModelPreferences.selectedModelKey: 'server-provided-model',
    });

    expect(
      await AiModelPreferences().loadSelected(),
      const AiModel('server-provided-model'),
    );
  });

  test('stores and restores the cached model list', () async {
    final preferences = AiModelPreferences();
    const models = [AiModel('gpt-a'), AiModel('gpt-b')];
    await preferences.saveCachedModels(models);

    expect(await AiModelPreferences().loadCachedModels(), models);
  });
}

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_model.dart';

class AiModelPreferences {
  static const selectedModelKey = 'selected_ai_model';
  static const cachedModelsKey = 'cached_ai_models';

  Future<AiModel> loadSelected() async {
    final preferences = await SharedPreferences.getInstance();
    return AiModel(
      preferences.getString(selectedModelKey) ?? AiModel.defaultModel.apiName,
    );
  }

  Future<void> saveSelected(AiModel model) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(selectedModelKey, model.apiName);
  }

  Future<List<AiModel>> loadCachedModels() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(cachedModelsKey) ?? const <String>[])
        .map(AiModel.new)
        .toList(growable: false);
  }

  Future<void> saveCachedModels(List<AiModel> models) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      cachedModelsKey,
      models.map((model) => model.apiName).toList(growable: false),
    );
  }
}

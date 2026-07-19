import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_model.dart';

class AiModelPreferences {
  static const _selectedModelKey = 'selected_ai_model';

  Future<AiModel> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AiModel.fromApiName(preferences.getString(_selectedModelKey));
  }

  Future<void> save(AiModel model) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedModelKey, model.apiName);
  }
}

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromptRepositoryException implements Exception {
  const PromptRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null ? message : '$message Details: $cause';
}

class PromptRepository {
  PromptRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  static const aiCommentPromptKey = 'ai_comment_prompt';
  static const _aiCommentPromptAsset = 'assets/prompts/ai_comment.txt';

  final AssetBundle _assetBundle;

  Future<String> getAiCommentPrompt() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(aiCommentPromptKey);
      if (saved != null) return saved;

      final defaultPrompt = await _loadDefaultPrompt();
      await _save(preferences, defaultPrompt);
      return defaultPrompt;
    } on PromptRepositoryException {
      rethrow;
    } on Object catch (error) {
      throw PromptRepositoryException('AIコメントプロンプトを読み込めませんでした。', error);
    }
  }

  Future<void> saveAiCommentPrompt(String prompt) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await _save(preferences, prompt);
    } on PromptRepositoryException {
      rethrow;
    } on Object catch (error) {
      throw PromptRepositoryException('AIコメントプロンプトを保存できませんでした。', error);
    }
  }

  Future<String> resetAiCommentPrompt() async {
    try {
      final defaultPrompt = await _loadDefaultPrompt();
      final preferences = await SharedPreferences.getInstance();
      await _save(preferences, defaultPrompt);
      return defaultPrompt;
    } on PromptRepositoryException {
      rethrow;
    } on Object catch (error) {
      throw PromptRepositoryException('デフォルトプロンプトに戻せませんでした。', error);
    }
  }

  Future<String> _loadDefaultPrompt() async {
    try {
      return await _assetBundle.loadString(_aiCommentPromptAsset);
    } on Object catch (error) {
      throw PromptRepositoryException('デフォルトプロンプトを読み込めませんでした。', error);
    }
  }

  Future<void> _save(SharedPreferences preferences, String prompt) async {
    final saved = await preferences.setString(aiCommentPromptKey, prompt);
    if (!saved) {
      throw const PromptRepositoryException('AIコメントプロンプトを保存できませんでした。');
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/ai_model.dart';

class OpenAiModelsException implements Exception {
  const OpenAiModelsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpenAiModelsService {
  OpenAiModelsService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;
  static const timeout = Duration(seconds: 30);

  Future<List<AiModel>> fetchModels({required String apiKey}) async {
    if (apiKey.trim().isEmpty) {
      throw const OpenAiModelsException('OpenAI API key is not configured.');
    }

    try {
      final request = await _httpClient
          .getUrl(Uri.https('api.openai.com', '/v1/models'))
          .timeout(timeout);
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${apiKey.trim()}',
      );
      final response = await request.close().timeout(timeout);
      final body = await utf8.decoder.bind(response).join().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OpenAiModelsException(
          'Models API returned HTTP ${response.statusCode}.',
        );
      }
      final models = parseChatGptModels(jsonDecode(body));
      if (models.isEmpty) {
        throw const OpenAiModelsException('利用可能なチャット生成モデルが見つかりませんでした。');
      }
      return models;
    } on OpenAiModelsException {
      rethrow;
    } on Object catch (error) {
      throw OpenAiModelsException('Models API request failed. Details: $error');
    }
  }
}

List<AiModel> parseChatGptModels(Object? decoded) {
  if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
    throw const OpenAiModelsException(
      'Models API returned an invalid response.',
    );
  }
  final ids =
      (decoded['data'] as List)
          .whereType<Map>()
          .map((model) => model['id'])
          .whereType<String>()
          .where(isChatGptModel)
          .toSet()
          .toList()
        ..sort();
  return ids.map(AiModel.new).toList(growable: false);
}

bool isChatGptModel(String id) {
  final value = id.toLowerCase();
  if (!value.startsWith('gpt-') && !value.startsWith('chatgpt-')) return false;
  const excludedCapabilities = [
    'audio',
    'realtime',
    'transcribe',
    'tts',
    'image',
    'embedding',
    'moderation',
    'instruct',
  ];
  return !excludedCapabilities.any(value.contains);
}

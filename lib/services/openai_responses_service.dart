import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../models/ai_comment_request.dart';

const openAiResponsesModel = 'gpt-4.1-mini';
const _systemPromptAsset = 'assets/prompts/ai_comment.txt';
const _failureMessage = '今日はコメントを生成できませんでした。';

class AiCommentGenerationException implements Exception {
  const AiCommentGenerationException([this.message = _failureMessage]);

  final String message;

  @override
  String toString() => message;
}

class OpenAiResponsesService {
  OpenAiResponsesService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;
  static const timeout = Duration(seconds: 30);

  Future<String> generateComment({
    required String apiKey,
    required AiCommentRequest request,
  }) async {
    try {
      return await _generateComment(
        apiKey: apiKey,
        request: request,
      ).timeout(timeout);
    } on AiCommentGenerationException {
      rethrow;
    } on Object {
      throw const AiCommentGenerationException();
    }
  }

  Future<String> _generateComment({
    required String apiKey,
    required AiCommentRequest request,
  }) async {
    if (apiKey.trim().isEmpty) throw const AiCommentGenerationException();

    try {
      final systemPrompt = await rootBundle.loadString(_systemPromptAsset);
      final httpRequest = await _httpClient
          .postUrl(Uri.https('api.openai.com', '/v1/responses'))
          .timeout(timeout);
      httpRequest.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer ${apiKey.trim()}')
        ..contentType = ContentType.json;
      httpRequest.write(
        jsonEncode({
          'model': openAiResponsesModel,
          'instructions': systemPrompt,
          'input': request.toPromptInput(),
        }),
      );

      final response = await httpRequest.close().timeout(timeout);
      final body = await utf8.decoder.bind(response).join().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AiCommentGenerationException();
      }

      return validateAndNormalizeAiComment(
        _extractOutputText(jsonDecode(body)),
      );
    } on AiCommentGenerationException {
      rethrow;
    } on Object {
      throw const AiCommentGenerationException();
    }
  }

  String? _extractOutputText(Object? decoded) {
    if (decoded is! Map<String, dynamic>) return null;
    final output = decoded['output'];
    if (output is! List) return null;
    for (final item in output) {
      if (item is! Map) continue;
      final content = item['content'];
      if (content is! List) continue;
      for (final part in content) {
        if (part is Map &&
            part['type'] == 'output_text' &&
            part['text'] is String) {
          return part['text'] as String;
        }
      }
    }
    return null;
  }
}

String validateAndNormalizeAiComment(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    throw const AiCommentGenerationException();
  }
  final characters = trimmed.runes.toList();
  if (characters.length <= 300) return trimmed;
  return String.fromCharCodes(characters.take(300));
}

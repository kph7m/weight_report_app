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
    } on TimeoutException catch (error) {
      throw AiCommentGenerationException(
        'Responses API timed out after ${timeout.inSeconds} seconds. '
        'Details: $error',
      );
    } on Object catch (error) {
      throw AiCommentGenerationException(
        'Responses API request failed. Details: $error',
      );
    }
  }

  Future<String> _generateComment({
    required String apiKey,
    required AiCommentRequest request,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const AiCommentGenerationException(
        'OpenAI API key is not configured.',
      );
    }

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
        throw AiCommentGenerationException(
          'Responses API returned HTTP ${response.statusCode}. '
          'Response: ${_logExcerpt(body)}',
        );
      }

      return validateAndNormalizeAiComment(
        _extractOutputText(jsonDecode(body)),
      );
    } on AiCommentGenerationException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on Object catch (error) {
      throw AiCommentGenerationException(
        'Responses API response processing failed. Details: $error',
      );
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

String _logExcerpt(String value) {
  const maxLength = 4000;
  return value.length <= maxLength
      ? value
      : '${value.substring(0, maxLength)}…';
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

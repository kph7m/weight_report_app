import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../models/ai_comment_request.dart';

const openAiResponsesModel = 'gpt-4.1-mini';
const _systemPromptAsset = 'assets/prompts/ai_comment.txt';
const _failureMessage = '今日はコメントを生成できませんでした。';

class OpenAiExchangeData {
  const OpenAiExchangeData({
    required this.requestedAt,
    required this.requestJson,
    required this.responseBody,
    required this.succeeded,
    required this.statusCode,
    required this.elapsedMilliseconds,
    required this.errorMessage,
  });

  final DateTime requestedAt;
  final String requestJson;
  final String? responseBody;
  final bool succeeded;
  final int? statusCode;
  final int elapsedMilliseconds;
  final String? errorMessage;
}

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
    Future<void> Function(OpenAiExchangeData exchange)? onExchange,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const AiCommentGenerationException(
        'OpenAI API key is not configured.',
      );
    }

    final requestedAt = DateTime.now();
    final stopwatch = Stopwatch()..start();
    String requestJson = '';
    String? responseBody;
    int? statusCode;
    try {
      final systemPrompt = await rootBundle.loadString(_systemPromptAsset);
      final requestBody = {
        'model': openAiResponsesModel,
        'instructions': systemPrompt,
        'input': request.toPromptInput(),
      };
      requestJson = const JsonEncoder.withIndent('  ').convert({
        'method': 'POST',
        'url': 'https://api.openai.com/v1/responses',
        'headers': {
          'Authorization': 'Bearer ${apiKey.trim()}',
          'Content-Type': 'application/json; charset=utf-8',
        },
        'body': requestBody,
      });
      final httpRequest = await _httpClient
          .postUrl(Uri.https('api.openai.com', '/v1/responses'))
          .timeout(timeout);
      httpRequest.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer ${apiKey.trim()}')
        ..contentType = ContentType.json;
      httpRequest.write(jsonEncode(requestBody));

      final response = await httpRequest.close().timeout(timeout);
      statusCode = response.statusCode;
      responseBody = await utf8.decoder.bind(response).join().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AiCommentGenerationException(
          'Responses API returned HTTP ${response.statusCode}. '
          'Response: ${_logExcerpt(responseBody)}',
        );
      }

      final comment = validateAndNormalizeAiComment(
        _extractOutputText(jsonDecode(responseBody)),
      );
      stopwatch.stop();
      await onExchange?.call(
        OpenAiExchangeData(
          requestedAt: requestedAt,
          requestJson: requestJson,
          responseBody: _prettyJson(responseBody),
          succeeded: true,
          statusCode: statusCode,
          elapsedMilliseconds: stopwatch.elapsedMilliseconds,
          errorMessage: null,
        ),
      );
      return comment;
    } on Object catch (error) {
      stopwatch.stop();
      await onExchange?.call(
        OpenAiExchangeData(
          requestedAt: requestedAt,
          requestJson: requestJson,
          responseBody: responseBody == null ? null : _prettyJson(responseBody),
          succeeded: false,
          statusCode: statusCode,
          elapsedMilliseconds: stopwatch.elapsedMilliseconds,
          errorMessage: error.toString(),
        ),
      );
      if (error is AiCommentGenerationException) rethrow;
      if (error is TimeoutException) {
        throw AiCommentGenerationException(
          'Responses API timed out after ${timeout.inSeconds} seconds. Details: $error',
        );
      }
      throw AiCommentGenerationException(
        'Responses API request failed. Details: $error',
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

String _prettyJson(String value) {
  try {
    return const JsonEncoder.withIndent('  ').convert(jsonDecode(value));
  } on FormatException {
    return value;
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

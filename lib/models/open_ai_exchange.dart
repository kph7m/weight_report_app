import 'package:isar/isar.dart';

part 'open_ai_exchange.g.dart';

@Collection(accessor: 'openAiExchanges')
@Name('open_ai_exchanges')
class OpenAiExchange {
  OpenAiExchange({
    this.id = latestExchangeId,
    required this.requestedAt,
    required this.requestJson,
    this.responseBody,
    required this.succeeded,
    this.statusCode,
    required this.elapsedMilliseconds,
    this.errorMessage,
  });

  static const Id latestExchangeId = 1;

  Id id;
  DateTime requestedAt;
  String requestJson;
  String? responseBody;
  bool succeeded;
  int? statusCode;
  int elapsedMilliseconds;
  String? errorMessage;
}

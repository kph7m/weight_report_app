// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_ai_exchange.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOpenAiExchangeCollection on Isar {
  IsarCollection<OpenAiExchange> get openAiExchanges => this.collection();
}

const OpenAiExchangeSchema = CollectionSchema(
  name: r'open_ai_exchanges',
  id: 5615884196048187176,
  properties: {
    r'elapsedMilliseconds': PropertySchema(
      id: 0,
      name: r'elapsedMilliseconds',
      type: IsarType.long,
    ),
    r'errorMessage': PropertySchema(
      id: 1,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'requestJson': PropertySchema(
      id: 2,
      name: r'requestJson',
      type: IsarType.string,
    ),
    r'requestedAt': PropertySchema(
      id: 3,
      name: r'requestedAt',
      type: IsarType.dateTime,
    ),
    r'responseBody': PropertySchema(
      id: 4,
      name: r'responseBody',
      type: IsarType.string,
    ),
    r'statusCode': PropertySchema(
      id: 5,
      name: r'statusCode',
      type: IsarType.long,
    ),
    r'succeeded': PropertySchema(
      id: 6,
      name: r'succeeded',
      type: IsarType.bool,
    ),
  },
  estimateSize: _openAiExchangeEstimateSize,
  serialize: _openAiExchangeSerialize,
  deserialize: _openAiExchangeDeserialize,
  deserializeProp: _openAiExchangeDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _openAiExchangeGetId,
  getLinks: _openAiExchangeGetLinks,
  attach: _openAiExchangeAttach,
  version: '3.1.0+1',
);

int _openAiExchangeEstimateSize(
  OpenAiExchange object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.requestJson.length * 3;
  {
    final value = object.responseBody;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _openAiExchangeSerialize(
  OpenAiExchange object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.elapsedMilliseconds);
  writer.writeString(offsets[1], object.errorMessage);
  writer.writeString(offsets[2], object.requestJson);
  writer.writeDateTime(offsets[3], object.requestedAt);
  writer.writeString(offsets[4], object.responseBody);
  writer.writeLong(offsets[5], object.statusCode);
  writer.writeBool(offsets[6], object.succeeded);
}

OpenAiExchange _openAiExchangeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OpenAiExchange(
    elapsedMilliseconds: reader.readLong(offsets[0]),
    errorMessage: reader.readStringOrNull(offsets[1]),
    id: id,
    requestJson: reader.readString(offsets[2]),
    requestedAt: reader.readDateTime(offsets[3]),
    responseBody: reader.readStringOrNull(offsets[4]),
    statusCode: reader.readLongOrNull(offsets[5]),
    succeeded: reader.readBool(offsets[6]),
  );
  return object;
}

P _openAiExchangeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _openAiExchangeGetId(OpenAiExchange object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _openAiExchangeGetLinks(OpenAiExchange object) {
  return [];
}

void _openAiExchangeAttach(
  IsarCollection<dynamic> col,
  Id id,
  OpenAiExchange object,
) {
  object.id = id;
}

extension OpenAiExchangeQueryWhereSort
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QWhere> {
  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OpenAiExchangeQueryWhere
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QWhereClause> {
  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OpenAiExchangeQueryFilter
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QFilterCondition> {
  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  elapsedMillisecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'elapsedMilliseconds', value: value),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  elapsedMillisecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'elapsedMilliseconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  elapsedMillisecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'elapsedMilliseconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  elapsedMillisecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'elapsedMilliseconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'errorMessage'),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'errorMessage'),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'errorMessage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'errorMessage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'errorMessage', value: ''),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'errorMessage', value: ''),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'requestJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'requestJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'requestJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'requestJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'requestJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'requestJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'requestJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'requestJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'requestJson', value: ''),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'requestJson', value: ''),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'requestedAt', value: value),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'requestedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'requestedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  requestedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'requestedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'responseBody'),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'responseBody'),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'responseBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'responseBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'responseBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'responseBody',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'responseBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'responseBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'responseBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'responseBody',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'responseBody', value: ''),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  responseBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'responseBody', value: ''),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  statusCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'statusCode'),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  statusCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'statusCode'),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  statusCodeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'statusCode', value: value),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  statusCodeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'statusCode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  statusCodeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'statusCode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  statusCodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'statusCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterFilterCondition>
  succeededEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'succeeded', value: value),
      );
    });
  }
}

extension OpenAiExchangeQueryObject
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QFilterCondition> {}

extension OpenAiExchangeQueryLinks
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QFilterCondition> {}

extension OpenAiExchangeQuerySortBy
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QSortBy> {
  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByElapsedMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByElapsedMillisecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByRequestJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestJson', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByRequestJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestJson', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByRequestedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByResponseBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseBody', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByResponseBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseBody', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByStatusCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusCode', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortByStatusCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusCode', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy> sortBySucceeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'succeeded', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  sortBySucceededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'succeeded', Sort.desc);
    });
  }
}

extension OpenAiExchangeQuerySortThenBy
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QSortThenBy> {
  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByElapsedMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByElapsedMillisecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByRequestJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestJson', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByRequestJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestJson', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByRequestedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByResponseBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseBody', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByResponseBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseBody', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByStatusCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusCode', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenByStatusCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusCode', Sort.desc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy> thenBySucceeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'succeeded', Sort.asc);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QAfterSortBy>
  thenBySucceededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'succeeded', Sort.desc);
    });
  }
}

extension OpenAiExchangeQueryWhereDistinct
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct> {
  QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct>
  distinctByElapsedMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elapsedMilliseconds');
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct>
  distinctByErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct>
  distinctByRequestJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct>
  distinctByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestedAt');
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct>
  distinctByResponseBody({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responseBody', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct>
  distinctByStatusCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusCode');
    });
  }

  QueryBuilder<OpenAiExchange, OpenAiExchange, QDistinct>
  distinctBySucceeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'succeeded');
    });
  }
}

extension OpenAiExchangeQueryProperty
    on QueryBuilder<OpenAiExchange, OpenAiExchange, QQueryProperty> {
  QueryBuilder<OpenAiExchange, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OpenAiExchange, int, QQueryOperations>
  elapsedMillisecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elapsedMilliseconds');
    });
  }

  QueryBuilder<OpenAiExchange, String?, QQueryOperations>
  errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<OpenAiExchange, String, QQueryOperations> requestJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestJson');
    });
  }

  QueryBuilder<OpenAiExchange, DateTime, QQueryOperations>
  requestedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestedAt');
    });
  }

  QueryBuilder<OpenAiExchange, String?, QQueryOperations>
  responseBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responseBody');
    });
  }

  QueryBuilder<OpenAiExchange, int?, QQueryOperations> statusCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusCode');
    });
  }

  QueryBuilder<OpenAiExchange, bool, QQueryOperations> succeededProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'succeeded');
    });
  }
}

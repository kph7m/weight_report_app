// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

extension GetWeightEntryCollection on Isar {
  IsarCollection<WeightEntry> get weightEntries => this.collection();
}

const WeightEntrySchema = CollectionSchema(
  name: r'weight_entry',
  id: 588015553941118652,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(id: 1, name: r'date', type: IsarType.dateTime),
    r'weightKg': PropertySchema(
      id: 2,
      name: r'weightKg',
      type: IsarType.double,
    ),
  },
  estimateSize: _weightEntryEstimateSize,
  serialize: _weightEntrySerialize,
  deserialize: _weightEntryDeserialize,
  deserializeProp: _weightEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _weightEntryGetId,
  getLinks: _weightEntryGetLinks,
  attach: _weightEntryAttach,
  version: '3.1.0+1',
);

int _weightEntryEstimateSize(
  WeightEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) => 0;

void _weightEntrySerialize(
  WeightEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeDouble(offsets[2], object.weightKg);
}

WeightEntry _weightEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) => WeightEntry(
  id: id,
  createdAt: reader.readDateTimeOrNull(offsets[0]),
  date: reader.readDateTime(offsets[1]),
  weightKg: reader.readDouble(offsets[2]),
);

P _weightEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weightEntryGetId(WeightEntry object) => object.id;
List<IsarLinkBase<dynamic>> _weightEntryGetLinks(WeightEntry object) => [];
void _weightEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  WeightEntry object,
) => object.id = id;

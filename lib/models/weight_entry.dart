import 'package:isar/isar.dart';

part 'weight_entry.g.dart';

@Collection(accessor: 'weightEntries')
@Name('weight_entry')
class WeightEntry {
  WeightEntry({
    this.id = Isar.autoIncrement,
    required this.date,
    required this.weightKg,
    this.createdAt,
  });

  Id id;

  DateTime date;

  double weightKg;

  DateTime? createdAt;
}

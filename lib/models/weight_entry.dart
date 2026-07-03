import 'package:isar/isar.dart';

part 'weight_entry.g.dart';

@collection
class WeightEntry {
  WeightEntry({
    this.id = Isar.autoIncrement,
    required this.date,
    required this.weightKg,
    this.createdAt,
  });

  Id id;

  @Index(unique: true, replace: true)
  DateTime date;

  double weightKg;

  DateTime? createdAt;
}

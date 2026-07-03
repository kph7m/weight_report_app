import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/weight_entry.dart';

class WeightRepository {
  WeightRepository(this._isar);

  final Isar _isar;

  static Future<WeightRepository> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [WeightEntrySchema],
      directory: directory.path,
      inspector: false,
    );
    return WeightRepository(isar);
  }

  Stream<List<WeightEntry>> watchEntries() async* {
    Future<List<WeightEntry>> readEntries() async {
      final entries = await _isar.weightEntrys.where().findAll();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    }

    yield await readEntries();
    await for (final _ in _isar.weightEntrys.watchLazy()) {
      yield await readEntries();
    }
  }

  Future<void> saveToday(double weightKg) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = WeightEntry(date: today, weightKg: weightKg, createdAt: now);
    await _isar.writeTxn(() => _isar.weightEntrys.put(entry));
  }
}

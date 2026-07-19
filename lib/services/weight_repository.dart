import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_settings.dart';
import '../models/weight_entry.dart';

class WeightRepository {
  WeightRepository(this._isar);

  final Isar _isar;

  static const _schemas = [WeightEntrySchema, AppSettingsSchema];

  static Future<WeightRepository> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final isar = await _openIsar(directory.path);
    return WeightRepository(isar);
  }

  static Future<Isar> _openIsar(String directoryPath) async {
    try {
      return await Isar.open(
        _schemas,
        directory: directoryPath,
        inspector: false,
      );
    } on IsarError catch (error) {
      if (!_isRecoverableSchemaError(error)) {
        rethrow;
      }

      await _deleteDevelopmentDatabase(directoryPath);
      return Isar.open(_schemas, directory: directoryPath, inspector: false);
    }
  }

  static bool _isRecoverableSchemaError(IsarError error) {
    final message = error.message.toLowerCase();
    return message.contains('collection id is invalid') ||
        message.contains('schema') ||
        message.contains('migration');
  }

  static Future<void> _deleteDevelopmentDatabase(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return;

    await for (final entity in directory.list()) {
      final name = entity.uri.pathSegments.last;
      if (name == 'default.isar' ||
          name == 'default.isar.lock' ||
          name.startsWith('default.isar.')) {
        await entity.delete(recursive: true);
      }
    }
  }

  Stream<List<WeightEntry>> watchEntries() async* {
    Future<List<WeightEntry>> readEntries() async {
      final entries = await _isar.weightEntries.where().findAll();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    }

    yield await readEntries();
    await for (final _ in _isar.weightEntries.watchLazy()) {
      yield await readEntries();
    }
  }

  Future<void> saveToday(double weightKg) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _isar.writeTxn(() async {
      final entries = await _isar.weightEntries.where().findAll();
      final existingEntry = entries.cast<WeightEntry?>().firstWhere(
        (entry) => entry?.date == today,
        orElse: () => null,
      );

      final entry =
          existingEntry ??
          WeightEntry(date: today, weightKg: weightKg, createdAt: now);
      entry.weightKg = weightKg;
      entry.createdAt ??= now;
      entry.aiComment = null;
      await _isar.weightEntries.put(entry);
    });
  }

  Future<void> saveAiComment(DateTime date, String comment) async {
    await _isar.writeTxn(() async {
      final entries = await _isar.weightEntries.where().findAll();
      final entry = entries.cast<WeightEntry?>().firstWhere(
        (item) => item?.date == DateTime(date.year, date.month, date.day),
        orElse: () => null,
      );
      if (entry == null) throw StateError('Weight entry not found.');
      entry.aiComment = comment;
      await _isar.weightEntries.put(entry);
    });
  }

  Future<String> previousDayAiComment(DateTime date) async {
    final previousDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(const Duration(days: 1));
    final entries = await _isar.weightEntries.where().findAll();
    return entries
            .cast<WeightEntry?>()
            .firstWhere(
              (entry) => entry?.date == previousDay,
              orElse: () => null,
            )
            ?.aiComment ??
        '';
  }

  Stream<AppSettings?> watchSettings() async* {
    yield await _isar.appSettings.get(AppSettings.settingsId);
    await for (final _ in _isar.appSettings.watchLazy()) {
      yield await _isar.appSettings.get(AppSettings.settingsId);
    }
  }

  Future<void> saveHeight(double? heightCm) =>
      _updateSettings((settings) => settings.heightCm = heightCm);

  Future<void> saveTargetWeight(double? targetWeightKg) =>
      _updateSettings((settings) => settings.targetWeightKg = targetWeightKg);

  Future<void> saveOpenAiApiKey(String? openAiApiKey) =>
      _updateSettings((settings) => settings.openAiApiKey = openAiApiKey);

  Future<void> _updateSettings(void Function(AppSettings) update) async {
    await _isar.writeTxn(() async {
      final settings =
          await _isar.appSettings.get(AppSettings.settingsId) ?? AppSettings();
      update(settings);
      await _isar.appSettings.put(settings);
    });
  }
}

import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@Collection(accessor: 'appSettings')
@Name('app_settings')
class AppSettings {
  AppSettings({
    this.id = settingsId,
    this.heightCm,
    this.targetWeightKg,
    this.openAiApiKey,
  });

  static const Id settingsId = 1;

  Id id;
  double? heightCm;
  double? targetWeightKg;
  String? openAiApiKey;
}

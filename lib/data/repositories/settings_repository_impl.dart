import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/isar_database.dart';
import 'package:isar/isar.dart';

/// Implementation of SettingsRepository using Isar.
class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl({Isar? isar}) : _isar = isar ?? IsarDatabase.instance;

  @override
  Future<AppSettings> getSettings() async {
    final settings = await _isar.appSettings.get(1);
    return settings ?? AppSettings.defaults();
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings.copyWith(id: 1));
    });
  }

  @override
  Future<void> resetToDefaults() async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(AppSettings.defaults());
    });
  }
}
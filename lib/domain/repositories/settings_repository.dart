import '../../domain/entities/app_settings.dart';

/// Repository interface for app settings.
abstract class SettingsRepository {
  /// Get the app settings.
  Future<AppSettings> getSettings();

  /// Update the app settings.
  Future<void> updateSettings(AppSettings settings);

  /// Reset settings to defaults.
  Future<void> resetToDefaults();
}
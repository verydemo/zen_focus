import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import 'repository_providers.dart';

/// Settings state notifier.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(AppSettings.defaults()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _ref.read(settingsRepositoryProvider).getSettings();
    state = settings;
  }

  Future<void> updateFocusDuration(int minutes) async {
    final newSettings = state.copyWith(defaultFocusMinutes: minutes);
    await _ref.read(settingsRepositoryProvider).updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateRestDuration(int minutes) async {
    final newSettings = state.copyWith(defaultRestMinutes: minutes);
    await _ref.read(settingsRepositoryProvider).updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> toggleNotifications() async {
    final newSettings = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    await _ref.read(settingsRepositoryProvider).updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> toggleSound() async {
    final newSettings = state.copyWith(soundEnabled: !state.soundEnabled);
    await _ref.read(settingsRepositoryProvider).updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateDailyGoal(int minutes) async {
    final newSettings = state.copyWith(dailyGoalMinutes: minutes);
    await _ref.read(settingsRepositoryProvider).updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> resetToDefaults() async {
    await _ref.read(settingsRepositoryProvider).resetToDefaults();
    state = AppSettings.defaults();
  }
}

/// Provider for settings.
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref);
});
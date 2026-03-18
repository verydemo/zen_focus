import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// Application settings stored as a singleton in Isar.
/// Always uses id = 1 for the single settings record.
@Collection()
class AppSettings {
  @Id()
  int? id;

  /// Default focus session duration in minutes
  int defaultFocusMinutes;

  /// Default rest duration in minutes
  int defaultRestMinutes;

  /// Whether to show notifications
  bool notificationsEnabled;

  /// Whether to play sounds
  bool soundEnabled;

  /// Daily focus goal in minutes
  int dailyGoalMinutes;

  /// Theme mode: 'system', 'light', 'dark'
  String themeMode;

  AppSettings({
    this.id,
    this.defaultFocusMinutes = 25,
    this.defaultRestMinutes = 5,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.dailyGoalMinutes = 120,
    this.themeMode = 'system',
  });

  /// Factory for default settings
  factory AppSettings.defaults() => AppSettings(id: 1);

  /// Create a copy with modified fields
  AppSettings copyWith({
    int? id,
    int? defaultFocusMinutes,
    int? defaultRestMinutes,
    bool? notificationsEnabled,
    bool? soundEnabled,
    int? dailyGoalMinutes,
    String? themeMode,
  }) {
    return AppSettings(
      id: id ?? this.id,
      defaultFocusMinutes: defaultFocusMinutes ?? this.defaultFocusMinutes,
      defaultRestMinutes: defaultRestMinutes ?? this.defaultRestMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
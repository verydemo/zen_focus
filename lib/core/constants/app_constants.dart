/// Application-wide constants for ZenFocus.

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ZenFocus';
  static const String appVersion = '1.0.0';

  // Timer Defaults
  static const int defaultFocusMinutes = 25;
  static const int defaultRestMinutes = 5;
  static const int defaultLongRestMinutes = 15;
  static const int sessionsBeforeLongRest = 4;

  // Daily Goal
  static const int defaultDailyGoalMinutes = 120; // 2 hours

  // Session Status Thresholds
  static const double successThreshold = 0.8; // 80% completion = success

  // Notification IDs
  static const int focusCompleteNotificationId = 1;
  static const int restCompleteNotificationId = 2;
  static const int reminderNotificationId = 3;

  // Animation Durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 400;
  static const int longAnimationDuration = 600;

  // Timer Tick Interval (in milliseconds)
  static const int timerTickInterval = 1000;
}

/// Route paths for navigation.
class RoutePaths {
  RoutePaths._();

  static const String home = '/';
  static const String timer = '/timer';
  static const String history = '/history';
  static const String settings = '/settings';
}

/// Storage keys for SharedPreferences (if needed).
class StorageKeys {
  StorageKeys._();

  static const String settings = 'settings';
  static const String lastSession = 'last_session';
  static const String dailyGoal = 'daily_goal';
}

/// Default distraction categories with icons and colors.
class DefaultCategories {
  static const Map<String, CategoryInfo> categories = {
    'phone': CategoryInfo(
      name: 'Phone',
      icon: 'phone_android',
      color: 0xFF4CAF50,
    ),
    'social': CategoryInfo(
      name: 'Social Media',
      icon: 'people',
      color: 0xFF2196F3,
    ),
    'thoughts': CategoryInfo(
      name: 'Thoughts',
      icon: 'psychology',
      color: 0xFF9C27B0,
    ),
    'environment': CategoryInfo(
      name: 'Environment',
      icon: 'nature',
      color: 0xFFFF9800,
    ),
    'other': CategoryInfo(
      name: 'Other',
      icon: 'more_horiz',
      color: 0xFF607D8B,
    ),
  };
}

class CategoryInfo {
  final String name;
  final String icon;
  final int color;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
  });
}
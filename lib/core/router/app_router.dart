import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/timer_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../constants/app_constants.dart';

/// GoRouter configuration for ZenFocus.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.timer,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        redirect: (_, __) => RoutePaths.timer,
      ),
      GoRoute(
        path: RoutePaths.timer,
        builder: (context, state) => const TimerScreen(),
      ),
      GoRoute(
        path: RoutePaths.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const TimerScreen(),
  );
});

/// Navigation helper class.
class AppNavigation {
  AppNavigation._();

  /// Navigate to timer screen.
  static void goToTimer(BuildContext context) {
    context.go(RoutePaths.timer);
  }

  /// Navigate to history screen.
  static void goToHistory(BuildContext context) {
    context.go(RoutePaths.history);
  }

  /// Navigate to settings screen.
  static void goToSettings(BuildContext context) {
    context.go(RoutePaths.settings);
  }

  /// Get current route.
  static String getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).matchedLocation;
  }

  /// Check if current route is timer.
  static bool isTimerRoute(BuildContext context) {
    return getCurrentRoute(context) == RoutePaths.timer;
  }

  /// Check if current route is history.
  static bool isHistoryRoute(BuildContext context) {
    return getCurrentRoute(context) == RoutePaths.history;
  }

  /// Check if current route is settings.
  static bool isSettingsRoute(BuildContext context) {
    return getCurrentRoute(context) == RoutePaths.settings;
  }
}
import '../entities/focus_session.dart';
import '../entities/distraction_log.dart';

/// Statistics-related utility functions for ZenFocus.
/// Pure Dart functions with no UI dependencies.

/// Generates daily statistics from sessions.
/// Returns a Map of date string (YYYY-MM-DD) to total focused seconds.
Map<String, int> generateDailyStats(List<FocusSession> sessions) {
  final Map<String, int> stats = {};

  for (final session in sessions) {
    if (session.status != SessionStatus.completed) continue;

    final dateKey = _formatDateKey(session.startTime);
    final focusedSeconds = session.actualDurationSeconds ?? 0;

    stats[dateKey] = (stats[dateKey] ?? 0) + focusedSeconds;
  }

  return stats;
}

/// Generates category breakdown from distraction logs.
/// Returns a Map of category name to total seconds.
Map<String, int> generateDistractionBreakdown(List<DistractionLog> logs) {
  final Map<String, int> breakdown = {};

  for (final log in logs) {
    breakdown[log.category] = (breakdown[log.category] ?? 0) + log.durationSeconds;
  }

  return breakdown;
}

/// Calculates weekly statistics from sessions.
/// Returns a Map of date string to total focused seconds for the week.
Map<String, int> generateWeeklyStats(List<FocusSession> sessions, DateTime weekStart) {
  final Map<String, int> stats = {};
  final weekEnd = weekStart.add(const Duration(days: 7));

  for (final session in sessions) {
    if (session.status != SessionStatus.completed) continue;
    if (session.startTime.isBefore(weekStart) || session.startTime.isAfter(weekEnd)) continue;

    final dateKey = _formatDateKey(session.startTime);
    final focusedSeconds = session.actualDurationSeconds ?? 0;

    stats[dateKey] = (stats[dateKey] ?? 0) + focusedSeconds;
  }

  return stats;
}

/// Calculates monthly statistics from sessions.
/// Returns total focused seconds for the month.
int calculateMonthlyTotal(List<FocusSession> sessions, int year, int month) {
  int total = 0;

  for (final session in sessions) {
    if (session.status != SessionStatus.completed) continue;
    if (session.startTime.year != year || session.startTime.month != month) continue;

    total += session.actualDurationSeconds ?? 0;
  }

  return total;
}

/// Generates heatmap data for a month.
/// Returns a Map of date string to intensity level (0-4).
Map<String, int> generateHeatmapData(
  Map<String, int> dailyStats, {
  int maxLevel = 4,
  int referenceMax = 7200, // 2 hours default max
}) {
  final Map<String, int> heatmap = {};

  for (final entry in dailyStats.entries) {
    final intensity = (entry.value / referenceMax * maxLevel).floor().clamp(0, maxLevel);
    heatmap[entry.key] = intensity;
  }

  return heatmap;
}

/// Calculates average daily focus time.
/// Returns average in seconds per day.
double calculateAverageDailyFocus(Map<String, int> dailyStats) {
  if (dailyStats.isEmpty) return 0.0;

  final totalSeconds = dailyStats.values.reduce((a, b) => a + b);
  return totalSeconds / dailyStats.length;
}

/// Calculates the longest streak of consecutive days with focus sessions.
int calculateLongestStreak(List<FocusSession> sessions) {
  if (sessions.isEmpty) return 0;

  final completedDates = sessions
      .where((s) => s.status == SessionStatus.completed)
      .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
      .toSet()
      .toList()
    ..sort();

  if (completedDates.isEmpty) return 0;

  int longestStreak = 1;
  int currentStreak = 1;

  for (int i = 1; i < completedDates.length; i++) {
    final diff = completedDates[i].difference(completedDates[i - 1]).inDays;
    if (diff == 1) {
      currentStreak++;
      longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
    } else if (diff > 1) {
      currentStreak = 1;
    }
  }

  return longestStreak;
}

/// Formats date key as YYYY-MM-DD.
String _formatDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
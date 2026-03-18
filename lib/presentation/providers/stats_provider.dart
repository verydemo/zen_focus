import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/distraction_log.dart';
import '../../domain/usecases/stats_utils.dart';
import 'repository_providers.dart';

/// Provider for all sessions.
final allSessionsProvider = FutureProvider<List<FocusSession>>((ref) async {
  return ref.read(focusSessionRepositoryProvider).getAllSessions();
});

/// Provider for sessions on a specific date.
final sessionsForDateProvider = FutureProvider.family<List<FocusSession>, DateTime>((ref, date) async {
  return ref.read(focusSessionRepositoryProvider).getSessionsForDate(date);
});

/// Provider for sessions in a date range.
final sessionsInRangeProvider = FutureProvider.family<List<FocusSession>, ({DateTime start, DateTime end})>((ref, params) async {
  return ref.read(focusSessionRepositoryProvider).getSessionsInRange(params.start, params.end);
});

/// Provider for distraction logs for a session.
final logsForSessionProvider = FutureProvider.family<List<DistractionLog>, int>((ref, sessionId) async {
  return ref.read(distractionLogRepositoryProvider).getLogsForSession(sessionId);
});

/// Provider for distraction logs in a date range.
final logsInRangeProvider = FutureProvider.family<List<DistractionLog>, ({DateTime start, DateTime end})>((ref, params) async {
  return ref.read(distractionLogRepositoryProvider).getLogsInRange(params.start, params.end);
});

/// Provider for daily stats.
final dailyStatsProvider = Provider<Map<String, int>>((ref) {
  final sessionsAsync = ref.watch(allSessionsProvider);
  return sessionsAsync.maybeWhen(
    data: (sessions) => generateDailyStats(sessions),
    orElse: () => {},
  );
});

/// Provider for distraction breakdown.
final distractionBreakdownProvider = FutureProvider.family<Map<String, int>, ({DateTime start, DateTime end})>((ref, params) async {
  return ref.read(distractionLogRepositoryProvider).getTotalByCategory(params.start, params.end);
});

/// Provider for today's total focus time.
final todayFocusTimeProvider = FutureProvider<int>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return ref.read(focusSessionRepositoryProvider).getTotalFocusTime(start, end);
});

/// Provider for today's session count.
final todaySessionCountProvider = FutureProvider<int>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return ref.read(focusSessionRepositoryProvider).getSessionCount(start, end);
});
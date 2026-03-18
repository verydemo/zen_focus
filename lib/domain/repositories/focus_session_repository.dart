import '../../domain/entities/focus_session.dart';

/// Repository interface for focus sessions.
abstract class FocusSessionRepository {
  /// Get all focus sessions.
  Future<List<FocusSession>> getAllSessions();

  /// Get sessions within a date range.
  Future<List<FocusSession>> getSessionsInRange(DateTime start, DateTime end);

  /// Get sessions for a specific date.
  Future<List<FocusSession>> getSessionsForDate(DateTime date);

  /// Get the currently active session (if any).
  Future<FocusSession?> getActiveSession();

  /// Get a session by ID.
  Future<FocusSession?> getSessionById(int id);

  /// Save a focus session.
  Future<int> saveSession(FocusSession session);

  /// Update a focus session.
  Future<void> updateSession(FocusSession session);

  /// Delete a focus session.
  Future<void> deleteSession(int id);

  /// Delete all sessions.
  Future<void> deleteAllSessions();

  /// Get total focus time in seconds for a date range.
  Future<int> getTotalFocusTime(DateTime start, DateTime end);

  /// Get session count for a date range.
  Future<int> getSessionCount(DateTime start, DateTime end);
}
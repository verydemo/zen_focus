import '../../domain/entities/distraction_log.dart';

/// Repository interface for distraction logs.
abstract class DistractionLogRepository {
  /// Get all distraction logs.
  Future<List<DistractionLog>> getAllLogs();

  /// Get logs for a specific session.
  Future<List<DistractionLog>> getLogsForSession(int sessionId);

  /// Get logs within a date range.
  Future<List<DistractionLog>> getLogsInRange(DateTime start, DateTime end);

  /// Save a distraction log.
  Future<int> saveLog(DistractionLog log);

  /// Delete a distraction log.
  Future<void> deleteLog(int id);

  /// Delete all logs for a session.
  Future<void> deleteLogsForSession(int sessionId);

  /// Delete all logs.
  Future<void> deleteAllLogs();

  /// Get total distraction time by category.
  Future<Map<String, int>> getTotalByCategory(DateTime start, DateTime end);
}
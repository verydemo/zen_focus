import 'package:isar/isar.dart';
import '../../domain/entities/distraction_log.dart';
import '../../domain/repositories/distraction_log_repository.dart';
import '../datasources/local/isar_database.dart';

/// Implementation of DistractionLogRepository using Isar.
class DistractionLogRepositoryImpl implements DistractionLogRepository {
  final Isar _isar;

  DistractionLogRepositoryImpl({Isar? isar}) : _isar = isar ?? IsarDatabase.instance;

  @override
  Future<List<DistractionLog>> getAllLogs() async {
    return _isar.distractionLogs.where().sortByTimestampDesc().findAll();
  }

  @override
  Future<List<DistractionLog>> getLogsForSession(int sessionId) async {
    return _isar.distractionLogs
        .where()
        .sessionIdEqualTo(sessionId)
        .sortByTimestampDesc()
        .findAll();
  }

  @override
  Future<List<DistractionLog>> getLogsInRange(DateTime start, DateTime end) async {
    return _isar.distractionLogs
        .where()
        .timestampBetween(start, end)
        .sortByTimestampDesc()
        .findAll();
  }

  @override
  Future<int> saveLog(DistractionLog log) async {
    return _isar.writeTxn(() async {
      return _isar.distractionLogs.put(log);
    });
  }

  @override
  Future<void> deleteLog(int id) async {
    await _isar.writeTxn(() async {
      await _isar.distractionLogs.delete(id);
    });
  }

  @override
  Future<void> deleteLogsForSession(int sessionId) async {
    await _isar.writeTxn(() async {
      await _isar.distractionLogs.where().sessionIdEqualTo(sessionId).deleteAll();
    });
  }

  @override
  Future<void> deleteAllLogs() async {
    await _isar.writeTxn(() async {
      await _isar.distractionLogs.clear();
    });
  }

  @override
  Future<Map<String, int>> getTotalByCategory(DateTime start, DateTime end) async {
    final logs = await getLogsInRange(start, end);
    final Map<String, int> totals = {};

    for (final log in logs) {
      totals[log.category] = (totals[log.category] ?? 0) + log.durationSeconds;
    }

    return totals;
  }
}
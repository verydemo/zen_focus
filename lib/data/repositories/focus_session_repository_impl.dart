import 'package:isar/isar.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../datasources/local/isar_database.dart';

/// Implementation of FocusSessionRepository using Isar.
class FocusSessionRepositoryImpl implements FocusSessionRepository {
  final Isar _isar;

  FocusSessionRepositoryImpl({Isar? isar}) : _isar = isar ?? IsarDatabase.instance;

  @override
  Future<List<FocusSession>> getAllSessions() async {
    return _isar.focusSessions.where().sortByStartTimeDesc().findAll();
  }

  @override
  Future<List<FocusSession>> getSessionsInRange(DateTime start, DateTime end) async {
    return _isar.focusSessions
        .where()
        .startTimeBetween(start, end)
        .sortByStartTimeDesc()
        .findAll();
  }

  @override
  Future<List<FocusSession>> getSessionsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return getSessionsInRange(start, end);
  }

  @override
  Future<FocusSession?> getActiveSession() async {
    return _isar.focusSessions
        .where()
        .statusEqualTo(SessionStatus.running)
        .or()
        .statusEqualTo(SessionStatus.paused)
        .findFirst();
  }

  @override
  Future<FocusSession?> getSessionById(int id) async {
    return _isar.focusSessions.get(id);
  }

  @override
  Future<int> saveSession(FocusSession session) async {
    return _isar.writeTxn(() async {
      return _isar.focusSessions.put(session);
    });
  }

  @override
  Future<void> updateSession(FocusSession session) async {
    await _isar.writeTxn(() async {
      await _isar.focusSessions.put(session);
    });
  }

  @override
  Future<void> deleteSession(int id) async {
    await _isar.writeTxn(() async {
      await _isar.focusSessions.delete(id);
    });
  }

  @override
  Future<void> deleteAllSessions() async {
    await _isar.writeTxn(() async {
      await _isar.focusSessions.clear();
    });
  }

  @override
  Future<int> getTotalFocusTime(DateTime start, DateTime end) async {
    final sessions = await _isar.focusSessions
        .where()
        .statusEqualTo(SessionStatus.completed)
        .and()
        .startTimeBetween(start, end)
        .findAll();

    return sessions.fold(0, (sum, session) => sum + (session.actualDurationSeconds ?? 0));
  }

  @override
  Future<int> getSessionCount(DateTime start, DateTime end) async {
    return _isar.focusSessions
        .where()
        .startTimeBetween(start, end)
        .count();
  }
}
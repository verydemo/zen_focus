import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/isar_database.dart';
import '../../data/repositories/focus_session_repository_impl.dart';
import '../../data/repositories/distraction_log_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../../domain/repositories/distraction_log_repository.dart';
import '../../domain/repositories/settings_repository.dart';

/// Provider for Isar database instance.
final isarProvider = Provider((ref) => IsarDatabase.instance);

/// Provider for FocusSessionRepository.
final focusSessionRepositoryProvider = Provider<FocusSessionRepository>((ref) {
  return FocusSessionRepositoryImpl(isar: ref.watch(isarProvider));
});

/// Provider for DistractionLogRepository.
final distractionLogRepositoryProvider = Provider<DistractionLogRepository>((ref) {
  return DistractionLogRepositoryImpl(isar: ref.watch(isarProvider));
});

/// Provider for SettingsRepository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(isar: ref.watch(isarProvider));
});
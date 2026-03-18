import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/app_settings.dart';
import '../../core/utils/timer_utils.dart';
import 'repository_providers.dart';
import 'settings_provider.dart';

/// Timer state enum.
enum TimerState {
  idle,
  running,
  paused,
  completed,
}

/// Timer state data class.
class TimerStateData {
  final TimerState state;
  final FocusSession? currentSession;
  final int remainingSeconds;
  final int elapsedSeconds;
  final bool isRestMode;

  const TimerStateData({
    this.state = TimerState.idle,
    this.currentSession,
    this.remainingSeconds = 0,
    this.elapsedSeconds = 0,
    this.isRestMode = false,
  });

  TimerStateData copyWith({
    TimerState? state,
    FocusSession? currentSession,
    int? remainingSeconds,
    int? elapsedSeconds,
    bool? isRestMode,
  }) {
    return TimerStateData(
      state: state ?? this.state,
      currentSession: currentSession ?? this.currentSession,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRestMode: isRestMode ?? this.isRestMode,
    );
  }
}

/// Timer state notifier.
class TimerNotifier extends StateNotifier<TimerStateData> {
  final Ref _ref;
  Timer? _timer;

  TimerNotifier(this._ref) : super(const TimerStateData());

  /// Start a new focus session.
  Future<void> startSession({int? durationMinutes}) async {
    final settings = _ref.read(settingsProvider);
    final focusMinutes = durationMinutes ?? settings.defaultFocusMinutes;

    final now = DateTime.now();
    final session = FocusSession(
      startTime: now,
      targetEndTime: calculateTargetEndTime(now, focusMinutes),
      status: SessionStatus.running,
      durationMinutes: focusMinutes,
    );

    final id = await _ref.read(focusSessionRepositoryProvider).saveSession(session);
    final savedSession = session.copyWith(id: id);

    state = TimerStateData(
      state: TimerState.running,
      currentSession: savedSession,
      remainingSeconds: focusMinutes * 60,
      elapsedSeconds: 0,
      isRestMode: false,
    );

    _startTimer();
  }

  /// Pause the current session.
  Future<void> pauseSession() async {
    if (state.currentSession == null) return;

    _timer?.cancel();

    final updatedSession = state.currentSession!.copyWith(
      status: SessionStatus.paused,
      pauseCount: state.currentSession!.pauseCount + 1,
    );

    await _ref.read(focusSessionRepositoryProvider).updateSession(updatedSession);

    state = state.copyWith(
      state: TimerState.paused,
      currentSession: updatedSession,
    );
  }

  /// Resume a paused session.
  Future<void> resumeSession() async {
    if (state.currentSession == null) return;

    final updatedSession = state.currentSession!.copyWith(
      status: SessionStatus.running,
    );

    await _ref.read(focusSessionRepositoryProvider).updateSession(updatedSession);

    // Recalculate target end time
    final now = DateTime.now();
    final newTargetEndTime = now.add(Duration(seconds: state.remainingSeconds));

    state = state.copyWith(
      state: TimerState.running,
      currentSession: updatedSession.copyWith(targetEndTime: newTargetEndTime),
    );

    _startTimer();
  }

  /// Complete the current session.
  Future<void> completeSession() async {
    if (state.currentSession == null) return;

    _timer?.cancel();

    final actualSeconds = state.currentSession!.durationMinutes * 60 - state.remainingSeconds;

    final updatedSession = state.currentSession!.copyWith(
      status: SessionStatus.completed,
      actualDurationSeconds: actualSeconds,
      completedAt: DateTime.now(),
    );

    await _ref.read(focusSessionRepositoryProvider).updateSession(updatedSession);

    state = TimerStateData(
      state: TimerState.completed,
      currentSession: updatedSession,
      remainingSeconds: 0,
      elapsedSeconds: actualSeconds,
      isRestMode: false,
    );

    // Start rest timer
    _startRestTimer();
  }

  /// Abandon the current session.
  Future<void> abandonSession() async {
    if (state.currentSession == null) return;

    _timer?.cancel();

    final actualSeconds = state.currentSession!.durationMinutes * 60 - state.remainingSeconds;

    final updatedSession = state.currentSession!.copyWith(
      status: SessionStatus.abandoned,
      actualDurationSeconds: actualSeconds,
      completedAt: DateTime.now(),
    );

    await _ref.read(focusSessionRepositoryProvider).updateSession(updatedSession);

    state = const TimerStateData(state: TimerState.idle);
  }

  /// Reset to idle state.
  void reset() {
    _timer?.cancel();
    state = const TimerStateData();
  }

  /// Start the countdown timer.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentSession == null) {
        timer.cancel();
        return;
      }

      final remaining = calculateRemainingSeconds(state.currentSession!.targetEndTime);

      if (remaining <= 0) {
        completeSession();
        return;
      }

      state = state.copyWith(
        remainingSeconds: remaining,
        elapsedSeconds: state.currentSession!.durationMinutes * 60 - remaining,
      );
    });
  }

  /// Start rest timer after session completion.
  void _startRestTimer() async {
    final settings = _ref.read(settingsProvider);
    final restMinutes = settings.defaultRestMinutes;

    state = state.copyWith(
      state: TimerState.running,
      remainingSeconds: restMinutes * 60,
      isRestMode: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remainingSeconds - 1;

      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(
          state: TimerState.completed,
          remainingSeconds: 0,
        );
        return;
      }

      state = state.copyWith(remainingSeconds: remaining);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider for timer state.
final timerProvider = StateNotifierProvider<TimerNotifier, TimerStateData>((ref) {
  return TimerNotifier(ref);
});
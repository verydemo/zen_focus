import 'package:isar/isar.dart';

part 'focus_session.g.dart';

/// Represents a focus session (Pomodoro timer session).
/// Contains timing information and status for background time calibration.
@Collection()
class FocusSession {
  @Id()
  int? id;

  /// When the session started
  @Index()
  late DateTime startTime;

  /// Target end time for background time calibration
  late DateTime targetEndTime;

  /// Current status of the session
  @Index()
  late SessionStatus status;

  /// Target duration in minutes
  int durationMinutes;

  /// Actual focused time in seconds (only set when completed)
  int? actualDurationSeconds;

  /// When the session was completed or abandoned
  DateTime? completedAt;

  /// Optional notes for the session
  String? notes;

  /// Total pause duration in seconds
  int totalPauseSeconds;

  /// Number of times the session was paused
  int pauseCount;

  FocusSession({
    this.id,
    required this.startTime,
    required this.targetEndTime,
    required this.status,
    this.durationMinutes = 25,
    this.actualDurationSeconds,
    this.completedAt,
    this.notes,
    this.totalPauseSeconds = 0,
    this.pauseCount = 0,
  });

  /// Returns the progress percentage (0.0 to 1.0)
  double get progress {
    if (actualDurationSeconds == null) return 0.0;
    final targetSeconds = durationMinutes * 60;
    return (actualDurationSeconds! / targetSeconds).clamp(0.0, 1.0);
  }
}

/// Status of a focus session
enum SessionStatus {
  running,
  paused,
  completed,
  abandoned,
}
/// Timer-related utility functions for ZenFocus.
/// Pure Dart functions with no UI dependencies.

/// Calculates remaining seconds based on target end time.
/// Returns 0 if the target time has passed.
int calculateRemainingSeconds(DateTime targetEndTime) {
  final now = DateTime.now();
  final difference = targetEndTime.difference(now);
  return difference.inSeconds.clamp(0, double.maxFinite.toInt());
}

/// Calculates elapsed seconds from start time.
int calculateElapsedSeconds(DateTime startTime) {
  return DateTime.now().difference(startTime).inSeconds;
}

/// Formats seconds into MM:SS display string.
String formatTimeDisplay(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Formats seconds into a human-readable duration string.
/// Example: 3725 seconds -> "1h 2m 5s"
String formatDurationHuman(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  final parts = <String>[];
  if (hours > 0) parts.add('${hours}h');
  if (minutes > 0) parts.add('${minutes}m');
  if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');

  return parts.join(' ');
}

/// Formats seconds into a compact duration string.
/// Example: 3725 seconds -> "1:02:05"
String formatDurationCompact(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Calculates the target end time for a focus session.
DateTime calculateTargetEndTime(DateTime startTime, int durationMinutes) {
  return startTime.add(Duration(minutes: durationMinutes));
}

/// Calculates progress as a percentage (0.0 to 1.0).
double calculateProgress(int elapsedSeconds, int targetSeconds) {
  if (targetSeconds <= 0) return 0.0;
  return (elapsedSeconds / targetSeconds).clamp(0.0, 1.0);
}

/// Determines if a session should be considered "successful" (>= 80% completed).
bool isSessionSuccessful(int actualSeconds, int targetSeconds) {
  if (targetSeconds <= 0) return false;
  return (actualSeconds / targetSeconds) >= 0.8;
}
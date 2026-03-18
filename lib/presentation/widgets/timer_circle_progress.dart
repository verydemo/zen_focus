import 'package:flutter/material.dart';
import '../../core/utils/timer_utils.dart';

/// Circular progress indicator for the timer.
class TimerCircleProgress extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final Color color;
  final bool isRestMode;

  const TimerCircleProgress({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.color,
    this.isRestMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final timeDisplay = formatTimeDisplay(remainingSeconds);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              color: Colors.white.withOpacity(0.2),
            ),
          ),

          // Progress circle
          SizedBox(
            width: 280,
            height: 280,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: progress, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  color: color,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),

          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRestMode ? 'REST' : 'FOCUS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
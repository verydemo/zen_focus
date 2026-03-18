import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/timer_utils.dart';
import '../../core/constants/app_constants.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/timer_circle_progress.dart';
import '../widgets/distraction_dialog.dart';
import '../widgets/bottom_nav_bar.dart';

/// Timer Screen - Main focus timer UI.
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = AppTheme.getBackgroundColor(
      isRunning: timerState.state == TimerState.running,
      isPaused: timerState.state == TimerState.paused,
      isRestMode: timerState.isRestMode,
      isDark: isDark,
    );

    final primaryColor = AppTheme.getPrimaryColor(
      isRunning: timerState.state == TimerState.running,
      isPaused: timerState.state == TimerState.paused,
      isRestMode: timerState.isRestMode,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Status indicator
            _buildStatusIndicator(timerState, primaryColor),

            const Spacer(),

            // Timer display
            TimerCircleProgress(
              remainingSeconds: timerState.remainingSeconds,
              totalSeconds: timerState.isRestMode
                  ? settings.defaultRestMinutes * 60
                  : settings.defaultFocusMinutes * 60,
              color: primaryColor,
              isRestMode: timerState.isRestMode,
            ),

            const SizedBox(height: 48),

            // Control buttons
            _buildControlButtons(context, ref, timerState, primaryColor),

            const SizedBox(height: 24),

            // Distraction button (only during focus)
            if (timerState.state == TimerState.running && !timerState.isRestMode)
              _buildDistractionButton(context, ref, primaryColor),

            const Spacer(),

            // Bottom navigation
            const BottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(TimerStateData timerState, Color primaryColor) {
    String statusText;
    IconData statusIcon;

    if (timerState.isRestMode) {
      statusText = 'Rest Mode';
      statusIcon = Icons.coffee;
    } else if (timerState.state == TimerState.running) {
      statusText = 'Focus Mode';
      statusIcon = Icons.timer;
    } else if (timerState.state == TimerState.paused) {
      statusText = 'Paused';
      statusIcon = Icons.pause_circle_outline;
    } else if (timerState.state == TimerState.completed) {
      statusText = 'Session Complete!';
      statusIcon = Icons.check_circle_outline;
    } else {
      statusText = 'Ready to Focus';
      statusIcon = Icons.play_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    WidgetRef ref,
    TimerStateData timerState,
    Color primaryColor,
  ) {
    final timerNotifier = ref.read(timerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start/Pause button
        _buildMainButton(
          icon: timerState.state == TimerState.running
              ? Icons.pause
              : Icons.play_arrow,
          label: timerState.state == TimerState.running ? 'Pause' : 'Start',
          onPressed: () {
            if (timerState.state == TimerState.idle ||
                timerState.state == TimerState.completed) {
              timerNotifier.startSession();
            } else if (timerState.state == TimerState.running) {
              timerNotifier.pauseSession();
            } else if (timerState.state == TimerState.paused) {
              timerNotifier.resumeSession();
            }
          },
          color: primaryColor,
        ),

        const SizedBox(width: 24),

        // Abandon button (only during active session)
        if (timerState.state != TimerState.idle &&
            timerState.state != TimerState.completed)
          _buildMainButton(
            icon: Icons.stop,
            label: 'Abandon',
            onPressed: () => _showAbandonDialog(context, timerNotifier),
            color: AppTheme.error,
            isOutlined: true,
          ),
      ],
    );
  }

  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isOutlined ? color : Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? color : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistractionButton(BuildContext context, WidgetRef ref, Color primaryColor) {
    return TextButton.icon(
      onPressed: () => _showDistractionDialog(context, ref),
      icon: const Icon(Icons.edit_note, color: Colors.white70),
      label: const Text(
        'Record Distraction',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  void _showAbandonDialog(BuildContext context, TimerNotifier timerNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon Session?'),
        content: const Text(
          'Are you sure you want to abandon this focus session? '
          'The time spent will be recorded but marked as abandoned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              timerNotifier.abandonSession();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
  }

  void _showDistractionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const DistractionDialog(),
    );
  }
}
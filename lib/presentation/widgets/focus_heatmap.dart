import 'package:flutter/material.dart';
import '../../domain/entities/focus_session.dart';
import '../../core/theme/app_theme.dart';
import 'dart:collection';

/// Focus heatmap calendar widget showing daily focus intensity.
class FocusHeatmap extends StatelessWidget {
  final DateTime month;
  final List<FocusSession> sessions;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const FocusHeatmap({
    super.key,
    required this.month,
    required this.sessions,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final dailyStats = _calculateDailyStats();
    final daysInMonth = _getDaysInMonth();
    final firstDayWeekday = DateTime(month.year, month.month, 1).weekday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Weekday headers
              _buildWeekdayHeaders(),
              const SizedBox(height: 8),

              // Calendar grid
              _buildCalendarGrid(daysInMonth, firstDayWeekday, dailyStats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(
    int daysInMonth,
    int firstDayWeekday,
    Map<int, int> dailyStats,
  ) {
    final rows = <Widget>[];
    var currentDay = 1;
    final today = DateTime.now();

    // Calculate number of rows needed
    final totalCells = daysInMonth + (firstDayWeekday - 1);
    final rowCount = (totalCells / 7).ceil();

    for (var row = 0; row < rowCount; row++) {
      final cells = <Widget>[];

      for (var col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;

        if (cellIndex < firstDayWeekday - 1 || currentDay > daysInMonth) {
          // Empty cell
          cells.add(const Expanded(child: SizedBox(height: 40)));
        } else {
          // Day cell
          final date = DateTime(month.year, month.month, currentDay);
          final isToday = _isSameDay(date, today);
          final isSelected = _isSameDay(date, selectedDay);
          final focusSeconds = dailyStats[currentDay] ?? 0;
          final intensity = _calculateIntensity(focusSeconds);

          cells.add(
            Expanded(
              child: GestureDetector(
                onTap: () => onDaySelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _getIntensityColor(intensity),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppTheme.focusPrimary, width: 2)
                        : isToday
                            ? Border.all(color: Colors.grey, width: 1)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '$currentDay',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: intensity > 0.5 ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          currentDay++;
        }
      }

      rows.add(Row(children: cells));
    }

    return Column(children: rows);
  }

  Map<int, int> _calculateDailyStats() {
    final stats = <int, int>{};

    for (final session in sessions) {
      if (session.status != SessionStatus.completed) continue;
      if (session.startTime.year != month.year ||
          session.startTime.month != month.month) continue;

      final day = session.startTime.day;
      stats[day] = (stats[day] ?? 0) + (session.actualDurationSeconds ?? 0);
    }

    return stats;
  }

  int _getDaysInMonth() {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  double _calculateIntensity(int seconds) {
    // Max expected: 4 hours (14400 seconds)
    const maxSeconds = 14400.0;
    return (seconds / maxSeconds).clamp(0.0, 1.0);
  }

  Color _getIntensityColor(double intensity) {
    if (intensity <= 0) return Colors.grey.shade200;
    if (intensity <= 0.25) return AppTheme.focusPrimary.withOpacity(0.25);
    if (intensity <= 0.5) return AppTheme.focusPrimary.withOpacity(0.5);
    if (intensity <= 0.75) return AppTheme.focusPrimary.withOpacity(0.75);
    return AppTheme.focusPrimary;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
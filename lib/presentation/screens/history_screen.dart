import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/distraction_log.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/timer_utils.dart';
import '../providers/stats_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/focus_heatmap.dart';

/// History Screen - Statistics and session history.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            _buildMonthSelector(context),

            // Heatmap calendar
            _buildHeatmap(context, isDark),

            const Divider(height: 32),

            // Today's summary
            _buildTodaySummary(context),

            const SizedBox(height: 24),

            // Distraction breakdown
            _buildDistractionChart(context, isDark),

            const SizedBox(height: 24),

            // Session list for selected day
            _buildSessionList(context),

            const SizedBox(height: 16),

            // Bottom navigation
            const BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');
    final monthName = monthFormat.format(_selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, bool isDark) {
    final dailyStatsAsync = ref.watch(allSessionsProvider);

    return dailyStatsAsync.when(
      data: (sessions) {
        return FocusHeatmap(
          month: _selectedMonth,
          sessions: sessions,
          selectedDay: _selectedDay,
          onDaySelected: (day) {
            setState(() => _selectedDay = day);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Error loading data: $error'),
        ),
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    final focusTimeAsync = ref.watch(todayFocusTimeProvider);
    final sessionCountAsync = ref.watch(todaySessionCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryCard(
                context,
                icon: Icons.timer,
                title: 'Focused',
                value: focusTimeAsync.maybeWhen(
                  data: (seconds) => formatDurationHuman(seconds),
                  orElse: () => '0m',
                ),
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                context,
                icon: Icons.check_circle,
                title: 'Sessions',
                value: sessionCountAsync.maybeWhen(
                  data: (count) => '$count',
                  orElse: () => '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.focusPrimary, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistractionChart(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final breakdownAsync = ref.watch(
      distractionBreakdownProvider((start: start, end: end)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distraction Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          breakdownAsync.when(
            data: (breakdown) {
              if (breakdown.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No distractions recorded today'),
                    ),
                  ),
                );
              }
              return _buildPieChart(breakdown, isDark);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> breakdown, bool isDark) {
    final total = breakdown.values.reduce((a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Pie chart
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(
                PieChartData(
                  sections: breakdown.entries.map((entry) {
                    final percentage = (entry.value / total * 100).round();
                    final color = _getCategoryColor(entry.key);
                    return PieChartSectionData(
                      color: color,
                      value: entry.value.toDouble(),
                      title: '$percentage%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 20,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: breakdown.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DistractionCategory.getDisplayName(entry.key),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          formatDurationHuman(entry.value),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case DistractionCategory.phone:
        return const Color(0xFF4CAF50);
      case DistractionCategory.social:
        return const Color(0xFF2196F3);
      case DistractionCategory.thoughts:
        return const Color(0xFF9C27B0);
      case DistractionCategory.environment:
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF607D8B);
    }
  }

  Widget _buildSessionList(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsForDateProvider(_selectedDay));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          sessionsAsync.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No sessions for this day'),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return _buildSessionTile(sessions[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(FocusSession session) {
    final timeFormat = DateFormat.jm();
    final startTime = timeFormat.format(session.startTime);

    String statusText;
    Color statusColor;

    switch (session.status) {
      case SessionStatus.completed:
        statusText = 'Completed';
        statusColor = AppTheme.success;
        break;
      case SessionStatus.abandoned:
        statusText = 'Abandoned';
        statusColor = AppTheme.error;
        break;
      default:
        statusText = 'In Progress';
        statusColor = AppTheme.warning;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          session.status == SessionStatus.completed
              ? Icons.check_circle
              : Icons.cancel,
          color: statusColor,
        ),
        title: Text('$startTime - ${session.durationMinutes} min'),
        subtitle: Text(
          '${formatDurationHuman(session.actualDurationSeconds ?? 0)} focused',
        ),
        trailing: Text(
          statusText,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
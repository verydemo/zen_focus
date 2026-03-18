import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../providers/repository_providers.dart';
import '../widgets/bottom_nav_bar.dart';

/// Settings Screen - App configuration.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Settings
            _buildSection(
              context,
              title: 'Timer Settings',
              children: [
                _buildStepperTile(
                  context,
                  title: 'Focus Duration',
                  subtitle: 'Default focus session length',
                  value: settings.defaultFocusMinutes,
                  unit: 'min',
                  onDecrease: () => settingsNotifier.updateFocusDuration(
                    (settings.defaultFocusMinutes - 5).clamp(5, 60),
                  ),
                  onIncrease: () => settingsNotifier.updateFocusDuration(
                    (settings.defaultFocusMinutes + 5).clamp(5, 60),
                  ),
                ),
                _buildStepperTile(
                  context,
                  title: 'Rest Duration',
                  subtitle: 'Default rest period',
                  value: settings.defaultRestMinutes,
                  unit: 'min',
                  onDecrease: () => settingsNotifier.updateRestDuration(
                    (settings.defaultRestMinutes - 1).clamp(1, 30),
                  ),
                  onIncrease: () => settingsNotifier.updateRestDuration(
                    (settings.defaultRestMinutes + 1).clamp(1, 30),
                  ),
                ),
                _buildStepperTile(
                  context,
                  title: 'Daily Goal',
                  subtitle: 'Target focus time per day',
                  value: settings.dailyGoalMinutes,
                  unit: 'min',
                  onDecrease: () => settingsNotifier.updateDailyGoal(
                    (settings.dailyGoalMinutes - 15).clamp(15, 480),
                  ),
                  onIncrease: () => settingsNotifier.updateDailyGoal(
                    (settings.dailyGoalMinutes + 15).clamp(15, 480),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Notifications
            _buildSection(
              context,
              title: 'Notifications',
              children: [
                _buildSwitchTile(
                  context,
                  title: 'Timer Alerts',
                  subtitle: 'Get notified when session ends',
                  value: settings.notificationsEnabled,
                  onChanged: () => settingsNotifier.toggleNotifications(),
                ),
                _buildSwitchTile(
                  context,
                  title: 'Sound Effects',
                  subtitle: 'Play sounds for timer events',
                  value: settings.soundEnabled,
                  onChanged: () => settingsNotifier.toggleSound(),
                ),
              ],
            ),

            const Divider(height: 32),

            // Data
            _buildSection(
              context,
              title: 'Data',
              children: [
                _buildActionTile(
                  context,
                  title: 'Export Data',
                  subtitle: 'Export your focus history',
                  icon: Icons.download,
                  onTap: () => _showExportDialog(context),
                ),
                _buildActionTile(
                  context,
                  title: 'Clear All Data',
                  subtitle: 'Delete all sessions and settings',
                  icon: Icons.delete_forever,
                  iconColor: AppTheme.error,
                  onTap: () => _showClearDataDialog(context, ref),
                ),
              ],
            ),

            const Divider(height: 32),

            // About
            _buildSection(
              context,
              title: 'About',
              children: [
                _buildInfoTile(
                  context,
                  title: 'Version',
                  value: AppConstants.appVersion,
                ),
                _buildInfoTile(
                  context,
                  title: 'Developer',
                  value: 'ZenFocus Team',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Reset to defaults
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => _showResetDialog(context, settingsNotifier),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Defaults'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 100),

            // Bottom navigation
            const BottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.focusPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int value,
    required String unit,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onDecrease,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.focusPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value $unit',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: (_) => onChanged(),
        activeColor: AppTheme.focusPrimary,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Icon(icon, color: iconColor ?? AppTheme.focusPrimary),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your focus history will be exported as a JSON file. '
          'This feature requires file system access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your focus sessions, '
          'distraction logs, and reset settings to defaults. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Clear all data
              final sessionRepo = ref.read(focusSessionRepositoryProvider);
              final logRepo = ref.read(distractionLogRepositoryProvider);
              final settingsNotifier = ref.read(settingsProvider.notifier);

              await sessionRepo.deleteAllSessions();
              await logRepo.deleteAllLogs();
              await settingsNotifier.resetToDefaults();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsNotifier settingsNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all settings to their default values. '
          'Your focus history will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsNotifier.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
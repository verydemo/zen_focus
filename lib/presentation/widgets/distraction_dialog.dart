import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/distraction_log.dart';
import '../../domain/entities/focus_session.dart';
import '../providers/timer_provider.dart';
import '../providers/repository_providers.dart';

/// Dialog for recording a distraction during a focus session.
class DistractionDialog extends ConsumerStatefulWidget {
  const DistractionDialog({super.key});

  @override
  ConsumerState<DistractionDialog> createState() => _DistractionDialogState();
}

class _DistractionDialogState extends ConsumerState<DistractionDialog> {
  String _selectedCategory = DistractionCategory.phone;
  int _durationMinutes = 1;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Distraction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category selection
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DistractionCategory.all.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        DistractionCategory.getIcon(category),
                        size: 16,
                        color: isSelected ? Colors.white : null,
                      ),
                      const SizedBox(width: 4),
                      Text(DistractionCategory.getDisplayName(category)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Duration
            const Text(
              'Duration (minutes)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _durationMinutes > 1
                      ? () => setState(() => _durationMinutes--)
                      : null,
                ),
                Text(
                  '$_durationMinutes',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _durationMinutes < 60
                      ? () => setState(() => _durationMinutes++)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description (optional)
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'What distracted you?',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveDistraction,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveDistraction() async {
    final timerState = ref.read(timerProvider);
    final session = timerState.currentSession;

    if (session == null || session.id == null) {
      Navigator.pop(context);
      return;
    }

    final log = DistractionLog(
      sessionId: session.id!,
      timestamp: DateTime.now(),
      category: _selectedCategory,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      durationSeconds: _durationMinutes * 60,
    );

    await ref.read(distractionLogRepositoryProvider).saveLog(log);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distraction recorded')),
      );
    }
  }
}
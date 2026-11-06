import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule_item.dart';
import '../providers/hunter_provider.dart';
import '../theme/system_theme.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hunter = context.watch<HunterProvider>();
    final items = hunter.scheduleItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DAILY SCHEDULE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_time, color: SystemTheme.primaryCyan),
            onPressed: () => _showAddScheduleDialog(context),
            tooltip: 'Add Schedule Block',
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month,
                      color: SystemTheme.textMuted, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No schedule blocks yet.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Organize your daily routine by adding your first time block.',
                    style: TextStyle(color: SystemTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystemTheme.primaryCyan,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Block',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showAddScheduleDialog(context),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildTimelineItem(context, hunter, item);
              },
            ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, HunterProvider hunter, ScheduleItem item) {
    Color categoryColor = _getCategoryColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SystemTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isCompleted
              ? SystemTheme.successGreen.withValues(alpha: 0.4)
              : SystemTheme.border,
          width: 1.0,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left color bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? SystemTheme.successGreen
                    : categoryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Time column
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.time,
                      style: TextStyle(
                        color: item.isCompleted
                            ? SystemTheme.textMuted
                            : SystemTheme.primaryCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (item.endTime.isNotEmpty)
                      Text(
                        item.endTime,
                        style: const TextStyle(
                          color: SystemTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Content column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: item.isCompleted
                            ? SystemTheme.textMuted
                            : Colors.white,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: SystemTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Checkbox & menu
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    item.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: item.isCompleted
                        ? SystemTheme.successGreen
                        : SystemTheme.textMuted,
                    size: 22,
                  ),
                  onPressed: () => hunter.toggleScheduleItem(item.id),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: SystemTheme.textMuted, size: 18),
                  color: SystemTheme.surfaceElevated,
                  onSelected: (val) {
                    if (val == 'delete') {
                      hunter.deleteScheduleItem(item.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Block',
                          style: TextStyle(color: SystemTheme.alertRed)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'workout':
        return SystemTheme.alertRed;
      case 'work':
        return SystemTheme.electricBlue;
      case 'recovery':
        return SystemTheme.successGreen;
      case 'routine':
      default:
        return SystemTheme.systemPurple;
    }
  }

  void _showAddScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final timeController = TextEditingController(text: '08:00');
    final endTimeController = TextEditingController(text: '09:00');
    String category = 'work';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: SystemTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SystemTheme.border),
          ),
          title: const Text(
            'NEW SCHEDULE BLOCK',
            style: TextStyle(
              color: SystemTheme.primaryCyan,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          hintText: '08:00',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endTimeController,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          hintText: '09:00',
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Activity Title',
                    hintText: 'e.g. Dungeon Training',
                  ),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Details (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: SystemTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'work', child: Text('Work / Study')),
                    DropdownMenuItem(value: 'workout', child: Text('Workout / Fitness')),
                    DropdownMenuItem(value: 'routine', child: Text('Daily Routine')),
                    DropdownMenuItem(value: 'recovery', child: Text('Rest / Recovery')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL',
                  style: TextStyle(color: SystemTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SystemTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final hunter = context.read<HunterProvider>();
                final newItem = ScheduleItem(
                  id: const Uuid().v4(),
                  time: timeController.text.trim(),
                  endTime: endTimeController.text.trim(),
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  category: category,
                );
                hunter.addScheduleItem(newItem);
                Navigator.pop(ctx);
              },
              child: const Text('SAVE',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

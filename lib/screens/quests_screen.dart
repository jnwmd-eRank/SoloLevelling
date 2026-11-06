import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/quest.dart';
import '../providers/hunter_provider.dart';
import '../theme/system_theme.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final hunter = context.watch<HunterProvider>();
    final allQuests = hunter.quests;
    final filteredQuests = _selectedCategory == 'all'
        ? allQuests
        : allQuests.where((q) => q.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QUEST BOARD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: SystemTheme.primaryCyan),
            onPressed: () => _showAddQuestDialog(context),
            tooltip: 'Add Custom Quest',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'ALL QUESTS'),
                  const SizedBox(width: 8),
                  _buildFilterChip('fitness', 'FITNESS'),
                  const SizedBox(width: 8),
                  _buildFilterChip('focus', 'FOCUS / STUDY'),
                  const SizedBox(width: 8),
                  _buildFilterChip('habits', 'DAILY HABITS'),
                ],
              ),
            ),
          ),

          // Quest List
          Expanded(
            child: filteredQuests.isEmpty
                ? const Center(
                    child: Text(
                      'No quests found in this category.\nAdd one with the (+) button!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SystemTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filteredQuests.length,
                    itemBuilder: (context, index) {
                      final quest = filteredQuests[index];
                      return _buildQuestCard(context, hunter, quest);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : SystemTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      selected: isSelected,
      selectedColor: SystemTheme.primaryCyan,
      backgroundColor: SystemTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? SystemTheme.primaryCyan : SystemTheme.border,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategory = key;
          });
        }
      },
    );
  }

  Widget _buildQuestCard(
      BuildContext context, HunterProvider hunter, Quest quest) {
    final double progress = quest.targetProgress == 0
        ? 0.0
        : (quest.currentProgress / quest.targetProgress).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SystemTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: quest.isCompleted
              ? SystemTheme.successGreen.withValues(alpha: 0.5)
              : SystemTheme.border,
          width: quest.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: quest.isCompleted
            ? [
                BoxShadow(
                  color: SystemTheme.successGreen.withValues(alpha: 0.15),
                  blurRadius: 8,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: quest.isCompleted
                        ? SystemTheme.textSecondary
                        : Colors.white,
                    decoration:
                        quest.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SystemTheme.primaryCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: SystemTheme.primaryCyan.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: const TextStyle(
                    color: SystemTheme.primaryCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (quest.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              quest.description,
              style: const TextStyle(
                color: SystemTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Progress indicator
          LinearPercentIndicator(
            lineHeight: 6.0,
            percent: progress,
            backgroundColor: SystemTheme.surfaceElevated,
            progressColor: quest.isCompleted
                ? SystemTheme.successGreen
                : SystemTheme.electricBlue,
            barRadius: const Radius.circular(3),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          // Progress status and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quest.currentProgress} / ${quest.targetProgress} ${quest.unit}',
                style: const TextStyle(
                  color: SystemTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  if (!quest.isCompleted && quest.targetProgress > 1) ...[
                    _buildIncrementBtn(
                      label: '+1',
                      onPressed: () =>
                          hunter.updateQuestProgress(quest.id, 1),
                    ),
                    const SizedBox(width: 6),
                    if (quest.targetProgress >= 10) ...[
                      _buildIncrementBtn(
                        label: '+10',
                        onPressed: () =>
                            hunter.updateQuestProgress(quest.id, 10),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                  IconButton(
                    icon: Icon(
                      quest.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: quest.isCompleted
                          ? SystemTheme.successGreen
                          : SystemTheme.primaryCyan,
                      size: 24,
                    ),
                    onPressed: () {
                      final leveledUp =
                          hunter.toggleQuestComplete(quest.id);
                      if (quest.isCompleted) {
                        _showCompletionSnackBar(context, quest);
                      }
                      if (leveledUp) {
                        _showLevelUpDialog(context);
                      }
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: SystemTheme.textMuted, size: 20),
                    color: SystemTheme.surfaceElevated,
                    onSelected: (val) {
                      if (val == 'delete') {
                        hunter.deleteQuest(quest.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Quest',
                            style: TextStyle(color: SystemTheme.alertRed)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementBtn(
      {required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: SystemTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SystemTheme.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: SystemTheme.primaryCyan,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCompletionSnackBar(BuildContext context, Quest quest) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SystemTheme.surfaceElevated,
        content: Row(
          children: [
            const Icon(Icons.check_circle,
                color: SystemTheme.successGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'QUEST CLEARED: +${quest.xpReward} XP Awarded!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLevelUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SystemTheme.rankGold, width: 2),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upgrade, color: SystemTheme.rankGold, size: 30),
            SizedBox(width: 8),
            Text(
              'LEVEL UP!',
              style: TextStyle(
                color: SystemTheme.rankGold,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The System acknowledges your growth.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              '+3 Stat Points Awarded!',
              style: TextStyle(
                color: SystemTheme.primaryCyan,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SystemTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ACCEPT',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddQuestDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final targetController = TextEditingController(text: '10');
    final unitController = TextEditingController(text: 'reps');
    final xpController = TextEditingController(text: '50');
    String category = 'fitness';

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
            'NEW DAILY QUEST',
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
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Quest Title',
                    hintText: 'e.g. 50 Pull-ups',
                  ),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: SystemTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'fitness', child: Text('Fitness')),
                    DropdownMenuItem(
                        value: 'focus', child: Text('Focus / Study')),
                    DropdownMenuItem(
                        value: 'habits', child: Text('Daily Habits')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => category = val);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Target Count'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: xpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'XP Reward'),
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
                final newQuest = Quest(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  category: category,
                  targetProgress:
                      int.tryParse(targetController.text) ?? 1,
                  unit: unitController.text.trim().isEmpty
                      ? 'reps'
                      : unitController.text.trim(),
                  xpReward: int.tryParse(xpController.text) ?? 50,
                );
                hunter.addQuest(newQuest);
                Navigator.pop(ctx);
              },
              child: const Text('CREATE',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

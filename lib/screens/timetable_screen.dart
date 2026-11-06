import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule_item.dart';
import '../providers/hunter_provider.dart';
import '../theme/system_theme.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  // 'day', 'week', 'month'
  String _viewMode = 'day';
  DateTime _selectedDate = DateTime.now();

  String get _selectedDateStr =>
      DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _prevPeriod() {
    setState(() {
      if (_viewMode == 'day') {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else if (_viewMode == 'week') {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else if (_viewMode == 'month') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_viewMode == 'day') {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      } else if (_viewMode == 'week') {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      } else if (_viewMode == 'month') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      }
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  String _formatHeaderTitle() {
    if (_viewMode == 'day') {
      final now = DateTime.now();
      if (_selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day) {
        return 'Today, ${DateFormat('MMM d').format(_selectedDate)}';
      }
      return DateFormat('EEEE, MMM d').format(_selectedDate);
    } else if (_viewMode == 'week') {
      final startOfWeek = _selectedDate
          .subtract(Duration(days: _selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(endOfWeek)}';
    } else {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hunter = context.watch<HunterProvider>();

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
            icon: const Icon(Icons.today, color: SystemTheme.primaryCyan),
            onPressed: _goToToday,
            tooltip: 'Jump to Today',
          ),
          IconButton(
            icon: const Icon(Icons.more_time, color: SystemTheme.primaryCyan),
            onPressed: () => _showScheduleDialog(context),
            tooltip: 'Add Schedule Block',
          ),
        ],
      ),
      body: Column(
        children: [
          // View Switcher (Day / Week / Month)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SystemTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SystemTheme.border),
              ),
              child: Row(
                children: [
                  _buildViewTab('day', 'DAY VIEW'),
                  _buildViewTab('week', 'WEEK VIEW'),
                  _buildViewTab('month', 'MONTH VIEW'),
                ],
              ),
            ),
          ),

          // Date Navigator Header (< Nov 6, 2026 >)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: SystemTheme.primaryCyan),
                  onPressed: _prevPeriod,
                ),
                Text(
                  _formatHeaderTitle().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: SystemTheme.primaryCyan),
                  onPressed: _nextPeriod,
                ),
              ],
            ),
          ),

          // Body depending on View Mode
          Expanded(
            child: _viewMode == 'day'
                ? _buildDayView(context, hunter)
                : _viewMode == 'week'
                    ? _buildWeekView(context, hunter)
                    : _buildMonthView(context, hunter),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTab(String key, String label) {
    final isSelected = _viewMode == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? SystemTheme.primaryCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : SystemTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ================= DAY VIEW =================
  Widget _buildDayView(BuildContext context, HunterProvider hunter) {
    final dayItems = hunter.scheduleItems
        .where((item) => item.date == _selectedDateStr)
        .toList();

    if (dayItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, color: SystemTheme.textMuted, size: 54),
            const SizedBox(height: 12),
            Text(
              'No schedule on ${DateFormat('MMM d').format(_selectedDate)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap (+) to plan an activity for this date.',
              style: TextStyle(color: SystemTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SystemTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Block',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _showScheduleDialog(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: dayItems.length,
      itemBuilder: (context, index) {
        final item = dayItems[index];
        return _buildTimelineItem(context, hunter, item);
      },
    );
  }

  // ================= WEEK VIEW =================
  Widget _buildWeekView(BuildContext context, HunterProvider hunter) {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    final dayItems = hunter.scheduleItems
        .where((item) => item.date == _selectedDateStr)
        .toList();

    return Column(
      children: [
        // 7-Day Horizontal Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: SystemTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SystemTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((date) {
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final isSelected = dateStr == _selectedDateStr;
              final hasEvents =
                  hunter.scheduleItems.any((item) => item.date == dateStr);
              final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SystemTheme.primaryCyan
                        : isToday
                            ? SystemTheme.surfaceElevated
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: SystemTheme.rankGold, width: 1.2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(date).substring(0, 1),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : isToday
                                  ? SystemTheme.rankGold
                                  : SystemTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasEvents
                              ? (isSelected
                                  ? Colors.black
                                  : SystemTheme.primaryCyan)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Selected Day Schedule Items
        Expanded(
          child: dayItems.isEmpty
              ? Center(
                  child: Text(
                    'No schedule on ${DateFormat('EEEE, MMM d').format(_selectedDate)}',
                    style: const TextStyle(color: SystemTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: dayItems.length,
                  itemBuilder: (context, index) {
                    final item = dayItems[index];
                    return _buildTimelineItem(context, hunter, item);
                  },
                ),
        ),
      ],
    );
  }

  // ================= MONTH VIEW =================
  Widget _buildMonthView(BuildContext context, HunterProvider hunter) {
    final year = _selectedDate.year;
    final month = _selectedDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    final selectedDayItems = hunter.scheduleItems
        .where((item) => item.date == _selectedDateStr)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Calendar Grid Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SystemTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SystemTheme.border),
            ),
            child: Column(
              children: [
                // Weekday initials (M T W T F S S)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _WeekdayHeader('M'),
                    _WeekdayHeader('T'),
                    _WeekdayHeader('W'),
                    _WeekdayHeader('T'),
                    _WeekdayHeader('F'),
                    _WeekdayHeader('S'),
                    _WeekdayHeader('S'),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: SystemTheme.border, height: 1),
                const SizedBox(height: 8),

                // Days grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 42, // 6 weeks * 7 days
                  itemBuilder: (context, index) {
                    final dayOffset = index - (startingWeekday - 1);
                    if (dayOffset < 0 || dayOffset >= daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final dayNumber = dayOffset + 1;
                    final cellDate = DateTime(year, month, dayNumber);
                    final cellDateStr =
                        DateFormat('yyyy-MM-dd').format(cellDate);
                    final isSelected = cellDateStr == _selectedDateStr;
                    final isToday =
                        DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                            cellDateStr;
                    final hasEvents = hunter.scheduleItems
                        .any((item) => item.date == cellDateStr);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = cellDate),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SystemTheme.primaryCyan
                              : isToday
                                  ? SystemTheme.surfaceElevated
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? SystemTheme.primaryCyan
                                : isToday
                                    ? SystemTheme.rankGold
                                    : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.black
                                    : isToday
                                        ? SystemTheme.rankGold
                                        : Colors.white,
                              ),
                            ),
                            if (hasEvents) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.black
                                      : SystemTheme.primaryCyan,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Day Agenda Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AGENDA: ${DateFormat('MMM d, yyyy').format(_selectedDate).toUpperCase()}',
                style: const TextStyle(
                  color: SystemTheme.primaryCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${selectedDayItems.length} Blocks',
                style: const TextStyle(
                  color: SystemTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Agenda items
          if (selectedDayItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No schedule blocks on this day.',
                style: TextStyle(color: SystemTheme.textMuted),
              ),
            )
          else
            ...selectedDayItems.map((item) {
              return _buildTimelineItem(context, hunter, item);
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= TIMELINE ITEM WIDGET =================
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

            // Checkbox & edit/delete menu
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
                    if (val == 'edit') {
                      _showScheduleDialog(context, existingItem: item);
                    } else if (val == 'delete') {
                      hunter.deleteScheduleItem(item.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: SystemTheme.primaryCyan),
                          SizedBox(width: 8),
                          Text('Edit Block'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 16, color: SystemTheme.alertRed),
                          SizedBox(width: 8),
                          Text('Delete Block',
                              style: TextStyle(color: SystemTheme.alertRed)),
                        ],
                      ),
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

  // ================= ADD / EDIT SCHEDULE DIALOG =================
  void _showScheduleDialog(BuildContext context, {ScheduleItem? existingItem}) {
    final titleController =
        TextEditingController(text: existingItem?.title ?? '');
    final descController =
        TextEditingController(text: existingItem?.description ?? '');
    final timeController =
        TextEditingController(text: existingItem?.time ?? '08:00');
    final endTimeController =
        TextEditingController(text: existingItem?.endTime ?? '09:00');
    String category = existingItem?.category ?? 'work';

    DateTime chosenDate = existingItem != null
        ? DateFormat('yyyy-MM-dd').parse(existingItem.date)
        : _selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: SystemTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SystemTheme.border),
          ),
          title: Text(
            existingItem != null ? 'EDIT SCHEDULE BLOCK' : 'NEW SCHEDULE BLOCK',
            style: const TextStyle(
              color: SystemTheme.primaryCyan,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker row
                const Text(
                  'SCHEDULE DATE',
                  style: TextStyle(
                    color: SystemTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: chosenDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: SystemTheme.primaryCyan,
                              surface: SystemTheme.surface,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setModalState(() => chosenDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: SystemTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SystemTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(chosenDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            color: SystemTheme.primaryCyan, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Start & End Time
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
                const SizedBox(height: 8),

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Activity Title',
                    hintText: 'e.g. Dungeon Training',
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Details (optional)',
                  ),
                ),
                const SizedBox(height: 14),

                // Category dropdown
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: SystemTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'work', child: Text('Work / Study')),
                    DropdownMenuItem(
                        value: 'workout', child: Text('Workout / Fitness')),
                    DropdownMenuItem(
                        value: 'routine', child: Text('Daily Routine')),
                    DropdownMenuItem(
                        value: 'recovery', child: Text('Rest / Recovery')),
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
                final chosenDateStr =
                    DateFormat('yyyy-MM-dd').format(chosenDate);

                if (existingItem != null) {
                  // Edit existing
                  final updated = existingItem.copyWith(
                    date: chosenDateStr,
                    time: timeController.text.trim(),
                    endTime: endTimeController.text.trim(),
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    category: category,
                  );
                  hunter.updateScheduleItem(updated);
                } else {
                  // Add new
                  final newItem = ScheduleItem(
                    id: const Uuid().v4(),
                    date: chosenDateStr,
                    time: timeController.text.trim(),
                    endTime: endTimeController.text.trim(),
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    category: category,
                  );
                  hunter.addScheduleItem(newItem);
                }

                setState(() {
                  _selectedDate = chosenDate;
                });
                Navigator.pop(ctx);
              },
              child: Text(
                existingItem != null ? 'UPDATE' : 'SAVE',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String label;
  const _WeekdayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: SystemTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

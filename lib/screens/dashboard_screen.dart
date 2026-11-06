import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/hunter_provider.dart';
import '../theme/system_theme.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final hunter = context.watch<HunterProvider>();
    final profile = hunter.profile;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SystemTheme.primaryCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SystemTheme.primaryCyan, width: 1),
              ),
              child: const Text(
                'SYSTEM',
                style: TextStyle(
                  color: SystemTheme.primaryCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'HUNTER HUD',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: SystemTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SystemTheme.rankGold.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: SystemTheme.rankGold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${profile.currentStreak} Days',
                  style: const TextStyle(
                    color: SystemTheme.rankGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: hunter.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: SystemTheme.primaryCyan))
          : RefreshIndicator(
              onRefresh: () => hunter.loadData(),
              color: SystemTheme.primaryCyan,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- HUNTER LEVEL & RANK CARD ---
                  _buildStatusHUD(context, hunter),
                  const SizedBox(height: 20),

                  // --- DAILY QUESTS OVERVIEW ---
                  _buildDailyQuestCard(context, hunter),
                  const SizedBox(height: 20),

                  // --- QUICK ACTIONS / WORKOUT LAUNCHER ---
                  _buildQuickActionCards(context),
                  const SizedBox(height: 20),

                  // --- UPCOMING SCHEDULE ---
                  _buildUpcomingSchedule(context, hunter),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusHUD(BuildContext context, HunterProvider hunter) {
    final profile = hunter.profile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SystemTheme.hudCardDecoration(glow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.title.toUpperCase(),
                    style: const TextStyle(
                      color: SystemTheme.primaryCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SystemTheme.electricBlue, SystemTheme.systemPurple],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: SystemTheme.electricBlue.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  profile.rank,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Level & XP Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LV. ${profile.level}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: SystemTheme.primaryCyan,
                ),
              ),
              Text(
                '${profile.currentXp} / ${profile.xpToNextLevel} XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: SystemTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 10.0,
            percent: profile.xpProgress,
            backgroundColor: SystemTheme.surfaceElevated,
            progressColor: SystemTheme.primaryCyan,
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
            animation: true,
            animateFromLastPercent: true,
          ),
          const SizedBox(height: 16),

          // Mini Stats Quick Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('STR', profile.statStrength),
              _buildMiniStat('AGI', profile.statAgility),
              _buildMiniStat('VIT', profile.statVitality),
              _buildMiniStat('INT', profile.statIntelligence),
              _buildMiniStat('DISC', profile.statDiscipline),
            ],
          ),
          if (profile.unassignedPoints > 0) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => onNavigateTab(4), // Go to Profile/Stats tab
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: SystemTheme.rankGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: SystemTheme.rankGold.withValues(alpha: 0.7), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upgrade,
                        color: SystemTheme.rankGold, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${profile.unassignedPoints} Stat Points Available!',
                      style: const TextStyle(
                        color: SystemTheme.rankGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SystemTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyQuestCard(BuildContext context, HunterProvider hunter) {
    final progress = hunter.dailyQuestProgress;
    final completed = hunter.completedQuestsToday;
    final total = hunter.totalDailyQuests;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SystemTheme.hudCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.assignment,
                      color: SystemTheme.primaryCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'DAILY QUEST STATUS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  color: SystemTheme.primaryCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress,
            backgroundColor: SystemTheme.surfaceElevated,
            progressColor:
                progress >= 1.0 ? SystemTheme.successGreen : SystemTheme.electricBlue,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress >= 1.0
                    ? 'All Daily Quests Cleared! +Bonus XP Awarded'
                    : 'Clear all quests to avoid penalty zone.',
                style: TextStyle(
                  color: progress >= 1.0
                      ? SystemTheme.successGreen
                      : SystemTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateTab(1), // Go to Quests tab
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'VIEW >',
                  style: TextStyle(
                    color: SystemTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onNavigateTab(3), // Workout Timer Tab
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    SystemTheme.surface,
                    SystemTheme.surfaceElevated,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SystemTheme.primaryCyan.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.timer_outlined,
                      color: SystemTheme.primaryCyan, size: 28),
                  SizedBox(height: 10),
                  Text(
                    'WORKOUT TIMER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sets, Rest & Intervals',
                    style: TextStyle(
                      color: SystemTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onNavigateTab(2), // Timetable Tab
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    SystemTheme.surface,
                    SystemTheme.surfaceElevated,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: SystemTheme.systemPurple.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: SystemTheme.systemPurple, size: 28),
                  SizedBox(height: 10),
                  Text(
                    'DAILY SCHEDULE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Timetable & Blocks',
                    style: TextStyle(
                      color: SystemTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSchedule(
      BuildContext context, HunterProvider hunter) {
    final items = hunter.scheduleItems.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SystemTheme.hudCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time_filled,
                      color: SystemTheme.electricBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SCHEDULE TIMELINE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => onNavigateTab(2),
                child: const Text(
                  'ALL >',
                  style: TextStyle(
                    color: SystemTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No events scheduled for today.',
                style: TextStyle(color: SystemTheme.textMuted),
              ),
            )
          else
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: SystemTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isCompleted
                        ? SystemTheme.successGreen.withValues(alpha: 0.3)
                        : SystemTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: SystemTheme.primaryCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isCompleted
                                  ? SystemTheme.textMuted
                                  : Colors.white,
                            ),
                          ),
                          if (item.description.isNotEmpty)
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: SystemTheme.textMuted,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: item.isCompleted
                            ? SystemTheme.successGreen
                            : SystemTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () => hunter.toggleScheduleItem(item.id),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

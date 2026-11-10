import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/hunter_provider.dart';
import '../theme/system_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final hunter = context.watch<HunterProvider>();
    final profile = hunter.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'STATUS WINDOW',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- SOLO LEVELING STATUS WINDOW HUD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: SystemTheme.hudCardDecoration(
                borderColor: SystemTheme.primaryCyan,
                glow: true,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Name & Title
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
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: SystemTheme.textSecondary, size: 20),
                        onPressed: () => _showEditNameDialog(context, hunter),
                        tooltip: 'Edit Hunter Name',
                      ),
                    ],
                  ),
                  const Divider(color: SystemTheme.border, height: 24),

                  // Rank, Level & Class
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn('LEVEL', '${profile.level}'),
                      _buildInfoColumn('RANK', profile.rank),
                      _buildInfoColumn('STREAK', '${profile.currentStreak} Days'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Completed quests stat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn('QUESTS CLEARED',
                          '${profile.completedQuestsCount}'),
                      _buildInfoColumn('STATUS', 'Active Hunter'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Experience Progress Bar and 0/200XP
                  const Text(
                    'EXPERIENCE PROGRESS',
                    style: TextStyle(
                      color: SystemTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
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
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(profile.xpProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: SystemTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${profile.currentXp}/${profile.xpToNextLevel}XP',
                        style: const TextStyle(
                          fontSize: 13,
                          color: SystemTheme.primaryCyan,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: SystemTheme.border, height: 28),

                  // Unassigned Stat Points Banner
                  if (profile.unassignedPoints > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: SystemTheme.rankGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: SystemTheme.rankGold, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.stars,
                                  color: SystemTheme.rankGold, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'UNASSIGNED POINTS',
                                style: TextStyle(
                                  color: SystemTheme.rankGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '+${profile.unassignedPoints}',
                            style: const TextStyle(
                              color: SystemTheme.rankGold,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Attributes Section
                  const Text(
                    'ATTRIBUTES',
                    style: TextStyle(
                      color: SystemTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Wisdom',
                    code: 'WIS',
                    value: profile.statWisdom,
                    description: 'Spirituality and mindfulness',
                  ),
                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Vitality',
                    code: 'VIT',
                    value: profile.statVitality,
                    description: 'Physical health and well-being',
                  ),
                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Agility',
                    code: 'AGI',
                    value: profile.statAgility,
                    description: 'Speed, running endurance, and reflexes',
                  ),
                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Strength',
                    code: 'STR',
                    value: profile.statStrength,
                    description: 'Physical power, reps, and explosive output',
                  ),
                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Intelligence',
                    code: 'INT',
                    value: profile.statIntelligence,
                    description: 'Career development and personal growth',
                  ),
                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Perception',
                    code: 'PER',
                    value: profile.statPerception,
                    description: 'Finance and wealth management skills',
                  ),
                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Charisma',
                    code: 'CHA',
                    value: profile.statCharisma,
                    description: 'Social life and leadership',
                  ),
                  _buildStatRow(
                    context,
                    hunter,
                    name: 'Dexterity',
                    code: 'DEX',
                    value: profile.statDexterity,
                    description: 'Rare and valuable skills',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SCHEDULE ALERTS NOTICE ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SystemTheme.hudCardDecoration(),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: SystemTheme.primaryCyan, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCHEDULE ALERTS ACTIVE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'The System delivers alerts for every scheduled activity. Manage banner and sound preferences in device Settings.',
                          style: TextStyle(
                            color: SystemTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    HunterProvider hunter, {
    required String name,
    required String code,
    required int value,
    required String description,
  }) {
    final canUpgrade = hunter.profile.unassignedPoints > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: SystemTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: SystemTheme.border),
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SystemTheme.primaryCyan,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: SystemTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          if (canUpgrade) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: SystemTheme.rankGold, size: 24),
              onPressed: () => hunter.allocateStat(name),
              tooltip: 'Allocate +1 to $name',
            ),
          ],
        ],
      ),
    );
  }



  void _showEditNameDialog(BuildContext context, HunterProvider hunter) {
    final controller =
        TextEditingController(text: hunter.profile.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemTheme.surface,
        title: const Text('Change Hunter Codename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SystemTheme.primaryCyan,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                hunter.profile.name = controller.text.trim();
                hunter.saveData();
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}

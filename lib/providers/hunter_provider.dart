import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hunter_profile.dart';
import '../models/quest.dart';
import '../models/schedule_item.dart';

class HunterProvider extends ChangeNotifier {
  HunterProfile _profile = HunterProfile();
  List<Quest> _quests = [];
  List<ScheduleItem> _scheduleItems = [];
  bool _isLoading = true;

  HunterProfile get profile => _profile;
  List<Quest> get quests => _quests;
  List<ScheduleItem> get scheduleItems => _scheduleItems;
  bool get isLoading => _isLoading;

  int get completedQuestsToday =>
      _quests.where((q) => q.isCompleted).length;

  int get totalDailyQuests => _quests.length;

  double get dailyQuestProgress =>
      totalDailyQuests == 0 ? 0.0 : completedQuestsToday / totalDailyQuests;

  HunterProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final profileJson = prefs.getString('hunter_profile');
      if (profileJson != null) {
        _profile = HunterProfile.fromJson(
            jsonDecode(profileJson) as Map<String, dynamic>);
      }

      final questsJson = prefs.getString('hunter_quests');
      if (questsJson != null) {
        final List<dynamic> list = jsonDecode(questsJson);
        _quests = list.map((item) => Quest.fromJson(item)).toList();
      } else {
        _quests = _getDefaultQuests();
      }

      final scheduleJson = prefs.getString('hunter_schedule');
      if (scheduleJson != null) {
        final List<dynamic> list = jsonDecode(scheduleJson);
        _scheduleItems =
            list.map((item) => ScheduleItem.fromJson(item)).toList();
      } else {
        _scheduleItems = _getDefaultSchedule();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading data: $e');
      _quests = _getDefaultQuests();
      _scheduleItems = _getDefaultSchedule();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'hunter_profile', jsonEncode(_profile.toJson()));
      await prefs.setString(
          'hunter_quests',
          jsonEncode(_quests.map((q) => q.toJson()).toList()));
      await prefs.setString(
          'hunter_schedule',
          jsonEncode(_scheduleItems.map((s) => s.toJson()).toList()));
    } catch (e) {
      if (kDebugMode) print('Error saving data: $e');
    }
  }

  bool addXp(int amount) {
    bool leveledUp = false;
    _profile.currentXp += amount;

    while (_profile.currentXp >= _profile.xpToNextLevel) {
      _profile.currentXp -= _profile.xpToNextLevel;
      _profile.level += 1;
      _profile.unassignedPoints += 3;
      leveledUp = true;
    }

    saveData();
    notifyListeners();
    return leveledUp;
  }

  bool toggleQuestComplete(String questId) {
    bool leveledUp = false;
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index != -1) {
      final quest = _quests[index];
      quest.isCompleted = !quest.isCompleted;

      if (quest.isCompleted) {
        quest.currentProgress = quest.targetProgress;
        _profile.completedQuestsCount += 1;
        leveledUp = addXp(quest.xpReward);
      } else {
        quest.currentProgress = 0;
        _profile.currentXp = (_profile.currentXp - quest.xpReward).clamp(0, 999999);
      }

      saveData();
      notifyListeners();
    }
    return leveledUp;
  }

  void updateQuestProgress(String questId, int delta) {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index != -1) {
      final quest = _quests[index];
      final newProgress = (quest.currentProgress + delta)
          .clamp(0, quest.targetProgress);

      quest.currentProgress = newProgress;
      if (quest.currentProgress >= quest.targetProgress && !quest.isCompleted) {
        quest.isCompleted = true;
        _profile.completedQuestsCount += 1;
        addXp(quest.xpReward);
      } else if (quest.currentProgress < quest.targetProgress && quest.isCompleted) {
        quest.isCompleted = false;
      }

      saveData();
      notifyListeners();
    }
  }

  void addQuest(Quest quest) {
    _quests.add(quest);
    saveData();
    notifyListeners();
  }

  void deleteQuest(String questId) {
    _quests.removeWhere((q) => q.id == questId);
    saveData();
    notifyListeners();
  }

  void toggleScheduleItem(String id) {
    final index = _scheduleItems.indexWhere((s) => s.id == id);
    if (index != -1) {
      _scheduleItems[index].isCompleted = !_scheduleItems[index].isCompleted;
      if (_scheduleItems[index].isCompleted) {
        addXp(20);
      }
      saveData();
      notifyListeners();
    }
  }

  void addScheduleItem(ScheduleItem item) {
    _scheduleItems.add(item);
    _scheduleItems.sort((a, b) => a.time.compareTo(b.time));
    saveData();
    notifyListeners();
  }

  void deleteScheduleItem(String id) {
    _scheduleItems.removeWhere((s) => s.id == id);
    saveData();
    notifyListeners();
  }

  bool allocateStat(String statName) {
    if (_profile.unassignedPoints <= 0) return false;

    switch (statName.toLowerCase()) {
      case 'wisdom':
      case 'wis':
        _profile.statWisdom += 1;
        break;
      case 'vitality':
      case 'vit':
        _profile.statVitality += 1;
        break;
      case 'agility':
      case 'agi':
        _profile.statAgility += 1;
        break;
      case 'strength':
      case 'str':
        _profile.statStrength += 1;
        break;
      case 'intelligence':
      case 'int':
        _profile.statIntelligence += 1;
        break;
      case 'perception':
      case 'per':
        _profile.statPerception += 1;
        break;
      case 'charisma':
      case 'cha':
        _profile.statCharisma += 1;
        break;
      case 'dexterity':
      case 'dex':
        _profile.statDexterity += 1;
        break;
      default:
        return false;
    }

    _profile.unassignedPoints -= 1;
    saveData();
    notifyListeners();
    return true;
  }

  List<Quest> _getDefaultQuests() {
    return [
      Quest(
        id: 'quest_pushups',
        title: 'Daily Training: Push-ups',
        description: 'Complete 100 push-ups to fortify physical strength.',
        category: 'fitness',
        xpReward: 80,
        targetProgress: 100,
        unit: 'reps',
      ),
      Quest(
        id: 'quest_situps',
        title: 'Daily Training: Sit-ups',
        description: 'Engage core with 100 sit-ups.',
        category: 'fitness',
        xpReward: 80,
        targetProgress: 100,
        unit: 'reps',
      ),
      Quest(
        id: 'quest_squats',
        title: 'Daily Training: Squats',
        description: 'Build lower body explosiveness with 100 squats.',
        category: 'fitness',
        xpReward: 80,
        targetProgress: 100,
        unit: 'reps',
      ),
      Quest(
        id: 'quest_run',
        title: 'Daily Training: 10km Run',
        description: 'Outdoor endurance running or treadmill.',
        category: 'fitness',
        xpReward: 120,
        targetProgress: 10,
        unit: 'km',
      ),
      Quest(
        id: 'quest_reading',
        title: 'Mental Cultivation: Read 20 Mins',
        description: 'Expand knowledge through focused book reading.',
        category: 'focus',
        xpReward: 50,
        targetProgress: 20,
        unit: 'mins',
      ),
      Quest(
        id: 'quest_water',
        title: 'Vitality: Drink 2.5L Water',
        description: 'Hydrate cells for optimal metabolic recovery.',
        category: 'habits',
        xpReward: 40,
        targetProgress: 5,
        unit: 'cups',
      ),
    ];
  }

  List<ScheduleItem> _getDefaultSchedule() {
    return [
      ScheduleItem(
        id: 'sched_1',
        time: '06:30',
        endTime: '07:00',
        title: 'Awakening & Hydration',
        description: '500ml water, light mobility and system check-in',
        category: 'routine',
      ),
      ScheduleItem(
        id: 'sched_2',
        time: '07:00',
        endTime: '08:00',
        title: 'Morning Dungeon Run (Workout)',
        description: 'Daily quest: Push-ups, Sit-ups, Squats',
        category: 'workout',
      ),
      ScheduleItem(
        id: 'sched_3',
        time: '09:00',
        endTime: '12:30',
        title: 'Deep Work: Quest Sprint 1',
        description: 'High-focus productivity block',
        category: 'work',
      ),
      ScheduleItem(
        id: 'sched_4',
        time: '12:30',
        endTime: '13:30',
        title: 'Nutritional Refuel & Rest',
        description: 'High protein meal, 15 min mental recovery',
        category: 'recovery',
      ),
      ScheduleItem(
        id: 'sched_5',
        time: '14:00',
        endTime: '18:00',
        title: 'Deep Work: Quest Sprint 2',
        description: 'Execution on key projects',
        category: 'work',
      ),
      ScheduleItem(
        id: 'sched_6',
        time: '21:30',
        endTime: '22:30',
        title: 'Evening Debrief & Night Routine',
        description: 'Review quest log, plan tomorrow, sleep preparation',
        category: 'routine',
      ),
    ];
  }
}

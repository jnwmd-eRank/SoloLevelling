class HunterProfile {
  String name;
  String title;
  int level;
  int currentXp;
  int statWisdom;
  int statVitality;
  int statAgility;
  int statStrength;
  int statIntelligence;
  int statPerception;
  int statCharisma;
  int statDexterity;
  int unassignedPoints;
  int currentStreak;
  int completedQuestsCount;

  HunterProfile({
    this.name = 'Jinwoo',
    this.title = 'The Awakened',
    this.level = 1,
    this.currentXp = 0,
    this.statWisdom = 10,
    this.statVitality = 10,
    this.statAgility = 10,
    this.statStrength = 10,
    this.statIntelligence = 10,
    this.statPerception = 10,
    this.statCharisma = 10,
    this.statDexterity = 10,
    this.unassignedPoints = 3,
    this.currentStreak = 1,
    this.completedQuestsCount = 0,
  });

  int get xpToNextLevel => level * 100;

  double get xpProgress => (currentXp / xpToNextLevel).clamp(0.0, 1.0);

  String get rank {
    if (level >= 100) return 'Shadow Monarch';
    if (level >= 80) return 'S-Rank Hunter';
    if (level >= 60) return 'A-Rank Hunter';
    if (level >= 40) return 'B-Rank Hunter';
    if (level >= 20) return 'C-Rank Hunter';
    if (level >= 10) return 'D-Rank Hunter';
    return 'E-Rank Hunter';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'level': level,
      'currentXp': currentXp,
      'statWisdom': statWisdom,
      'statVitality': statVitality,
      'statAgility': statAgility,
      'statStrength': statStrength,
      'statIntelligence': statIntelligence,
      'statPerception': statPerception,
      'statCharisma': statCharisma,
      'statDexterity': statDexterity,
      'unassignedPoints': unassignedPoints,
      'currentStreak': currentStreak,
      'completedQuestsCount': completedQuestsCount,
    };
  }

  factory HunterProfile.fromJson(Map<String, dynamic> json) {
    return HunterProfile(
      name: (json['name'] ?? 'Jinwoo') as String,
      title: (json['title'] ?? 'The Awakened') as String,
      level: (json['level'] ?? 1) as int,
      currentXp: (json['currentXp'] ?? 0) as int,
      statWisdom: (json['statWisdom'] ?? 10) as int,
      statVitality: (json['statVitality'] ?? 10) as int,
      statAgility: (json['statAgility'] ?? 10) as int,
      statStrength: (json['statStrength'] ?? 10) as int,
      statIntelligence: (json['statIntelligence'] ?? 10) as int,
      statPerception: (json['statPerception'] ?? 10) as int,
      statCharisma: (json['statCharisma'] ?? 10) as int,
      statDexterity: (json['statDexterity'] ?? 10) as int,
      unassignedPoints: (json['unassignedPoints'] ?? 3) as int,
      currentStreak: (json['currentStreak'] ?? 1) as int,
      completedQuestsCount: (json['completedQuestsCount'] ?? 0) as int,
    );
  }
}

class Quest {
  final String id;
  final String title;
  final String description;
  final String category; // 'fitness', 'habits', 'focus', 'custom'
  final int xpReward;
  final int targetProgress;
  int currentProgress;
  bool isCompleted;
  final String unit;

  Quest({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.xpReward,
    this.targetProgress = 1,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.unit = 'reps',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'xpReward': xpReward,
      'targetProgress': targetProgress,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'unit': unit,
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? 'fitness') as String,
      xpReward: (json['xpReward'] ?? 50) as int,
      targetProgress: (json['targetProgress'] ?? 1) as int,
      currentProgress: (json['currentProgress'] ?? 0) as int,
      isCompleted: (json['isCompleted'] ?? false) as bool,
      unit: (json['unit'] ?? 'reps') as String,
    );
  }
}

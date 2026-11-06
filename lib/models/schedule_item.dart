class ScheduleItem {
  final String id;
  final String time; // e.g. "07:00"
  final String endTime; // e.g. "08:00"
  final String title;
  final String description;
  final String category; // 'routine', 'workout', 'work', 'recovery'
  bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.time,
    this.endTime = '',
    required this.title,
    this.description = '',
    this.category = 'routine',
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'endTime': endTime,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      time: json['time'] as String,
      endTime: (json['endTime'] ?? '') as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? 'routine') as String,
      isCompleted: (json['isCompleted'] ?? false) as bool,
    );
  }
}

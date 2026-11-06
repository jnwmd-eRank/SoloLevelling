import 'package:intl/intl.dart';

class ScheduleItem {
  final String id;
  final String date; // format: "yyyy-MM-dd"
  final String time; // e.g. "07:00"
  final String endTime; // e.g. "08:00"
  final String title;
  final String description;
  final String category; // 'routine', 'workout', 'work', 'recovery'
  bool isCompleted;

  ScheduleItem({
    required this.id,
    String? date,
    required this.time,
    this.endTime = '',
    required this.title,
    this.description = '',
    this.category = 'routine',
    this.isCompleted = false,
  }) : date = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  ScheduleItem copyWith({
    String? id,
    String? date,
    String? time,
    String? endTime,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
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
      date: (json['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()))
          as String,
      time: (json['time'] ?? '08:00') as String,
      endTime: (json['endTime'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? 'routine') as String,
      isCompleted: (json['isCompleted'] ?? false) as bool,
    );
  }
}

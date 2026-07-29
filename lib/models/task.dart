class Task {
  final int? id;
  final String title;
  final bool isDone;
  final DateTime date;
  final String category;
  final String? scheduledTime;
  final int reminderMinutes;
  final int progress;
  final bool hasCompleted;

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    required this.date,
    this.category = 'عام',
    this.scheduledTime,
    this.reminderMinutes = 30,
    this.progress = 0,
    this.hasCompleted = false,
  });

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    DateTime? date,
    String? category,
    String? scheduledTime,
    int? reminderMinutes,
    int? progress,
    bool? hasCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      progress: progress ?? this.progress,
      hasCompleted: hasCompleted ?? this.hasCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'date': date.toIso8601String(),
      'category': category,
      'scheduledTime': scheduledTime,
      'reminderMinutes': reminderMinutes,
      'progress': progress,
      'hasCompleted': hasCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isDone: (map['isDone'] as int?) == 1,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String? ?? 'عام',
      scheduledTime: map['scheduledTime'] as String?,
      reminderMinutes: map['reminderMinutes'] as int? ?? 30,
      progress: map['progress'] as int? ?? 0,
      hasCompleted: (map['hasCompleted'] as int?) == 1,
    );
  }
}

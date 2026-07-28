class Task {
  final int? id;
  final String title;
  final bool isDone;
  final DateTime date;
  final String category;

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    required this.date,
    this.category = 'عام',
  });

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    DateTime? date,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isDone: (map['isDone'] as int) == 1,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String? ?? 'عام',
    );
  }
}

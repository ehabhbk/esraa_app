class DailyGoal {
  final int? id;
  final String title;
  final String type;
  final String category;
  final bool isDone;
  final String date;
  final String? weekStart;

  DailyGoal({this.id, required this.title, required this.type, required this.category, this.isDone = false, required this.date, this.weekStart});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type,
    'category': category,
    'isDone': isDone ? 1 : 0,
    'date': date,
    'weekStart': weekStart,
  };

  factory DailyGoal.fromMap(Map<String, dynamic> m) => DailyGoal(
    id: m['id'] as int?,
    title: m['title'] as String,
    type: m['type'] as String,
    category: m['category'] as String,
    isDone: (m['isDone'] as int?) == 1,
    date: m['date'] as String,
    weekStart: m['weekStart'] as String?,
  );
}

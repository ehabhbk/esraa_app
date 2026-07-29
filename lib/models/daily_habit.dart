class DailyHabit {
  final int? id;
  final String name;
  final String icon;
  final String unit;
  final int target;
  final int current;
  final String date;

  DailyHabit({this.id, required this.name, required this.icon, required this.unit, this.target = 1, this.current = 0, required this.date});

  Map<String, dynamic> toMap() => { 'id': id, 'name': name, 'icon': icon, 'unit': unit, 'target': target, 'current': current, 'date': date };
  factory DailyHabit.fromMap(Map<String, dynamic> m) => DailyHabit(id: m['id'] as int?, name: m['name'] as String, icon: m['icon'] as String, unit: m['unit'] as String, target: m['target'] as int? ?? 1, current: m['current'] as int? ?? 0, date: m['date'] as String);
}

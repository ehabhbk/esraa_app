import 'package:flutter/foundation.dart';
import '../models/daily_habit.dart';
import '../services/database_service.dart';

class HabitProvider extends ChangeNotifier {
  List<DailyHabit> _habits = [];
  List<DailyHabit> get habits => _habits;

  final List<Map<String, dynamic>> _defaultHabits = [
    {'name': 'قهوة', 'icon': '☕', 'unit': 'أكواب', 'target': 5},
    {'name': 'ماء', 'icon': '💧', 'unit': 'أكواب', 'target': 8},
    {'name': 'مشي', 'icon': '🚶', 'unit': 'دقائق', 'target': 30},
    {'name': 'قراءة', 'icon': '📖', 'unit': 'دقائق', 'target': 20},
    {'name': 'تأمل', 'icon': '🧘', 'unit': 'دقائق', 'target': 10},
  ];

  Future<void> loadToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final data = await DatabaseService.query('daily_habits',
        where: 'date = ?', whereArgs: [today]);
    if (data.isEmpty) {
      for (final h in _defaultHabits) {
        await DatabaseService.insert('daily_habits', {
          'name': h['name'],
          'icon': h['icon'],
          'unit': h['unit'],
          'target': h['target'],
          'current': 0,
          'date': today,
        });
      }
      final newData = await DatabaseService.query('daily_habits',
          where: 'date = ?', whereArgs: [today]);
      _habits = newData.map((m) => DailyHabit.fromMap(m)).toList();
    } else {
      _habits = data.map((m) => DailyHabit.fromMap(m)).toList();
    }
    notifyListeners();
  }

  Future<void> increment(int id) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    await DatabaseService.update('daily_habits',
        {'current': habit.current + 1}, 'id = ?', [id]);
    await loadToday();
  }

  Future<void> decrement(int id) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    if (habit.current > 0) {
      await DatabaseService.update('daily_habits',
          {'current': habit.current - 1}, 'id = ?', [id]);
      await loadToday();
    }
  }

  Future<void> addHabit(DailyHabit habit) async {
    await DatabaseService.insert('daily_habits', habit.toMap());
    await loadToday();
  }

  Future<void> deleteHabit(int id) async {
    await DatabaseService.delete('daily_habits', 'id = ?', [id]);
    await loadToday();
  }
}

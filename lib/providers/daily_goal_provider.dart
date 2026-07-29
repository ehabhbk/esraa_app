import 'package:flutter/foundation.dart';
import '../models/daily_goal.dart';
import '../services/database_service.dart';

class DailyGoalProvider extends ChangeNotifier {
  List<DailyGoal> _goals = [];
  List<DailyGoal> get goals => _goals;

  Future<void> loadGoals() async {
    final data = await DatabaseService.query('daily_goals', orderBy: 'date DESC');
    _goals = data.map((m) => DailyGoal.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addGoal(DailyGoal g) async {
    await DatabaseService.insert('daily_goals', g.toMap());
    await loadGoals();
  }

  Future<void> updateGoal(DailyGoal g) async {
    await DatabaseService.update('daily_goals', g.toMap(), 'id = ?', [g.id]);
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    await DatabaseService.delete('daily_goals', 'id = ?', [id]);
    await loadGoals();
  }

  Future<void> toggleDone(int id) async {
    final goal = _goals.firstWhere((g) => g.id == id);
    await DatabaseService.update('daily_goals', {'isDone': goal.isDone ? 0 : 1}, 'id = ?', [id]);
    await loadGoals();
  }
}

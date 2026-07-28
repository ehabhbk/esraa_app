import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('tasks', orderBy: 'date DESC');
      _tasks = maps.map((m) => Task.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DatabaseService.insert('tasks', task.toMap());
    await loadTasks();
  }

  Future<void> toggleTask(int id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await DatabaseService.update('tasks', {'isDone': task.isDone ? 0 : 1},
        'id = ?', [id]);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseService.delete('tasks', 'id = ?', [id]);
    await loadTasks();
  }

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((t) {
      return t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day;
    }).toList();
  }

  int get completedCount => _tasks.where((t) => t.isDone).length;
  int get pendingCount => _tasks.where((t) => !t.isDone).length;
}

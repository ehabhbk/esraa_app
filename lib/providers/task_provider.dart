import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

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
    _scheduleTaskNotifications(task);
  }

  Future<void> updateTask(Task task) async {
    await DatabaseService.update('tasks', task.toMap(), 'id = ?', [task.id]);
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

  void _scheduleTaskNotifications(Task task) {
    if (task.scheduledTime == null) return;
    final parts = task.scheduledTime!.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final now = DateTime.now();
    var taskTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (!taskTime.isAfter(now)) {
      taskTime = taskTime.add(const Duration(days: 1));
    }

    // Reminder notification
    var reminderTime = taskTime.subtract(Duration(minutes: task.reminderMinutes));
    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }
    NotificationService.scheduleNotification(
      id: 10000 + (task.id ?? 0),
      title: '⏰ تذكير بالمهمة',
      body: 'لديك مهمة "${task.title}" الساعة ${task.scheduledTime}',
      scheduledDate: reminderTime,
    );

    // Completion question notification with Yes/No buttons
    NotificationService.scheduleTaskCheckNotification(
      id: 20000 + (task.id ?? 0),
      taskTitle: task.title,
      taskId: task.id ?? 0,
      scheduledDate: taskTime,
    );
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

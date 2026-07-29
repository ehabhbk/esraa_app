import 'package:flutter/foundation.dart';
import '../models/skincare_routine.dart';
import '../services/database_service.dart';

class SkincareProvider extends ChangeNotifier {
  List<SkincareRoutine> _items = [];
  bool _isLoading = false;

  List<SkincareRoutine> get items => _items;
  bool get isLoading => _isLoading;

  List<SkincareRoutine> get morningItems =>
      _items.where((i) => i.time == 'صباح' || i.time == 'صباح ومساء').toList();

  List<SkincareRoutine> get eveningItems =>
      _items.where((i) => i.time == 'مساء' || i.time == 'صباح ومساء').toList();

  int get doneCount => _items.where((i) => i.isDone).length;
  int get totalCount => _items.length;

  Future<void> loadToday() async {
    _isLoading = true;
    notifyListeners();
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      final maps = await DatabaseService.query('skincare_routines',
          where: 'date >= ? AND date <= ?',
          whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);
      if (maps.isEmpty) {
        await _createDefaultRoutine(today);
        return await loadToday();
      }
      _items = maps.map((m) => SkincareRoutine.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading skincare routines: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _createDefaultRoutine(DateTime date) async {
    final defaults = [
      SkincareRoutine(productName: 'منظف', category: 'منظف', time: 'صباح ومساء', date: date),
      SkincareRoutine(productName: 'تونر', category: 'تونر', time: 'صباح ومساء', date: date),
      SkincareRoutine(productName: 'سيروم فيتامين C', category: 'سيروم', time: 'صباح', date: date),
      SkincareRoutine(productName: 'مرطب', category: 'مرطب', time: 'صباح ومساء', date: date),
      SkincareRoutine(productName: 'واقي شمس', category: 'واقي شمس', time: 'صباح', date: date),
      SkincareRoutine(productName: 'سيروم ريتينول', category: 'سيروم', time: 'مساء', date: date),
    ];
    for (final item in defaults) {
      await DatabaseService.insert('skincare_routines', item.toMap());
    }
  }

  Future<void> toggleDone(int id) async {
    final item = _items.firstWhere((i) => i.id == id);
    await DatabaseService.update('skincare_routines', {'isDone': item.isDone ? 0 : 1}, 'id = ?', [id]);
    await loadToday();
  }

  Future<void> addItem(SkincareRoutine item) async {
    await DatabaseService.insert('skincare_routines', item.toMap());
    await loadToday();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseService.delete('skincare_routines', 'id = ?', [id]);
    await loadToday();
  }
}

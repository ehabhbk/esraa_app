import 'package:flutter/foundation.dart';
import '../models/my_look.dart';
import '../services/database_service.dart';

class LookProvider extends ChangeNotifier {
  List<MyLook> _looks = [];
  bool _isLoading = false;

  List<MyLook> get looks => _looks;
  bool get isLoading => _isLoading;

  Future<void> loadLooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('my_looks', orderBy: 'date DESC');
      _looks = maps.map((m) => MyLook.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading looks: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLook(MyLook look) async {
    await DatabaseService.insert('my_looks', look.toMap());
    await loadLooks();
  }

  Future<void> updateLook(MyLook look) async {
    await DatabaseService.update('my_looks', look.toMap(), 'id = ?', [look.id]);
    await loadLooks();
  }

  Future<void> deleteLook(int id) async {
    await DatabaseService.delete('my_looks', 'id = ?', [id]);
    await loadLooks();
  }

  MyLook? get todayLook {
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day);
    try {
      return _looks.firstWhere((l) =>
        l.date.year == todayStr.year &&
        l.date.month == todayStr.month &&
        l.date.day == todayStr.day
      );
    } catch (_) {
      return null;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/dream.dart';
import '../services/database_service.dart';

class DreamProvider extends ChangeNotifier {
  List<Dream> _dreams = [];
  bool _isLoading = false;

  List<Dream> get dreams => _dreams;
  List<Dream> get achieved => _dreams.where((d) => d.isAchieved).toList();
  bool get isLoading => _isLoading;

  Future<void> loadDreams() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('dreams', orderBy: 'createdAt DESC');
      _dreams = maps.map((m) => Dream.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading dreams: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDream(Dream dream) async {
    await DatabaseService.insert('dreams', dream.toMap());
    await loadDreams();
  }

  Future<void> updateDream(Dream dream) async {
    await DatabaseService.update('dreams', dream.toMap(), 'id = ?', [dream.id]);
    await loadDreams();
  }

  Future<void> deleteDream(int id) async {
    await DatabaseService.delete('dreams', 'id = ?', [id]);
    await loadDreams();
  }

  Future<void> toggleAchieved(int id) async {
    final dream = _dreams.firstWhere((d) => d.id == id);
    final now = DateTime.now().toIso8601String();
    if (dream.isAchieved) {
      await DatabaseService.update('dreams', {'isAchieved': 0, 'achievedDate': null}, 'id = ?', [id]);
    } else {
      await DatabaseService.update('dreams', {'isAchieved': 1, 'achievedDate': now}, 'id = ?', [id]);
    }
    await loadDreams();
  }
}

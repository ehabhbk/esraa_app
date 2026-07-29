import 'package:flutter/foundation.dart';
import '../models/hobby.dart';
import '../services/database_service.dart';

class HobbyProvider extends ChangeNotifier {
  List<Hobby> _hobbies = [];
  bool _isLoading = false;

  List<Hobby> get hobbies => _hobbies;
  List<Hobby> get active => _hobbies.where((h) => h.isActive).toList();
  bool get isLoading => _isLoading;

  Future<void> loadHobbies() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('hobbies', orderBy: 'createdAt DESC');
      _hobbies = maps.map((m) => Hobby.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading hobbies: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHobby(Hobby hobby) async {
    await DatabaseService.insert('hobbies', hobby.toMap());
    await loadHobbies();
  }

  Future<void> updateHobby(Hobby hobby) async {
    await DatabaseService.update('hobbies', hobby.toMap(), 'id = ?', [hobby.id]);
    await loadHobbies();
  }

  Future<void> deleteHobby(int id) async {
    await DatabaseService.delete('hobbies', 'id = ?', [id]);
    await loadHobbies();
  }

  Future<void> toggleActive(int id) async {
    final hobby = _hobbies.firstWhere((h) => h.id == id);
    await DatabaseService.update('hobbies', {'isActive': hobby.isActive ? 0 : 1}, 'id = ?', [id]);
    await loadHobbies();
  }
}

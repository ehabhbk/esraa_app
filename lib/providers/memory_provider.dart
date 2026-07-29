import 'package:flutter/foundation.dart';
import '../models/memory_capsule.dart';
import '../services/database_service.dart';

class MemoryProvider extends ChangeNotifier {
  List<MemoryCapsule> _memories = [];
  List<MemoryCapsule> get memories => _memories;

  Future<void> loadMemories() async {
    final data = await DatabaseService.query('memory_capsules', orderBy: 'date DESC');
    _memories = data.map((m) => MemoryCapsule.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addMemory(MemoryCapsule m) async {
    await DatabaseService.insert('memory_capsules', m.toMap());
    await loadMemories();
  }

  Future<void> updateMemory(MemoryCapsule m) async {
    await DatabaseService.update('memory_capsules', m.toMap(), 'id = ?', [m.id]);
    await loadMemories();
  }

  Future<void> deleteMemory(int id) async {
    await DatabaseService.delete('memory_capsules', 'id = ?', [id]);
    await loadMemories();
  }
}

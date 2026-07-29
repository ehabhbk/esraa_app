import 'package:flutter/foundation.dart';
import '../models/photo_diary.dart';
import '../services/database_service.dart';

class PhotoDiaryProvider extends ChangeNotifier {
  List<PhotoDiary> _entries = [];
  List<PhotoDiary> get entries => _entries;

  Future<void> loadEntries() async {
    final data = await DatabaseService.query('photo_diary', orderBy: 'date DESC');
    _entries = data.map((m) => PhotoDiary.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addEntry(PhotoDiary e) async {
    await DatabaseService.insert('photo_diary', e.toMap());
    await loadEntries();
  }

  Future<void> updateEntry(PhotoDiary e) async {
    await DatabaseService.update('photo_diary', e.toMap(), 'id = ?', [e.id]);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseService.delete('photo_diary', 'id = ?', [id]);
    await loadEntries();
  }
}

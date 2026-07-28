import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps =
          await DatabaseService.query('notes', orderBy: 'createdAt DESC');
      _notes = maps.map((m) => Note.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await DatabaseService.insert('notes', note.toMap());
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await DatabaseService.update('notes', note.toMap(), 'id = ?', [note.id]);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await DatabaseService.delete('notes', 'id = ?', [id]);
    await loadNotes();
  }

  List<Note> get recentNotes =>
      _notes.take(10).toList();
}

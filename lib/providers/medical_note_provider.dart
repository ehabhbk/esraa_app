import 'package:flutter/foundation.dart';
import '../models/medical_note.dart';
import '../services/database_service.dart';

class MedicalNoteProvider extends ChangeNotifier {
  List<MedicalNote> _notes = [];
  List<MedicalNote> get notes => _notes;

  Future<void> loadNotes() async {
    final data = await DatabaseService.query('medical_notes', orderBy: 'createdAt DESC');
    _notes = data.map((m) => MedicalNote.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addNote(MedicalNote n) async {
    await DatabaseService.insert('medical_notes', n.toMap());
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await DatabaseService.delete('medical_notes', 'id = ?', [id]);
    await loadNotes();
  }
}

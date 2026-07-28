import 'package:flutter/foundation.dart';
import '../models/letter_to_father.dart';
import '../services/database_service.dart';

class LettersProvider extends ChangeNotifier {
  List<LetterToFather> _letters = [];
  bool _isLoading = false;

  List<LetterToFather> get letters => _letters;
  bool get isLoading => _isLoading;

  Future<void> loadLetters() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('letters_to_father',
          orderBy: 'createdAt DESC');
      _letters = maps.map((m) => LetterToFather.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading letters: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLetter(LetterToFather letter) async {
    await DatabaseService.insert('letters_to_father', letter.toMap());
    await loadLetters();
  }

  Future<void> deleteLetter(int id) async {
    await DatabaseService.delete('letters_to_father', 'id = ?', [id]);
    await loadLetters();
  }

  int get totalLetters => _letters.length;
}

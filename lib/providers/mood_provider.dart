import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import '../services/database_service.dart';

class MoodProvider extends ChangeNotifier {
  List<MoodEntry> _entries = [];
  MoodEntry? _todayEntry;
  bool _isLoading = false;

  List<MoodEntry> get entries => _entries;
  MoodEntry? get todayEntry => _todayEntry;
  bool get isLoading => _isLoading;

  Future<void> loadMoods() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('moods', orderBy: 'date DESC');
      _entries = maps.map((m) => MoodEntry.fromMap(m)).toList();
      _todayEntry = _entries.where((e) {
        final today = DateTime.now();
        return e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day;
      }).firstOrNull;
    } catch (e) {
      debugPrint('Error loading moods: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveMood(MoodEntry entry) async {
    try {
      if (_todayEntry != null) {
        await DatabaseService.update('moods', entry.toMap(),
            'id = ?', [_todayEntry!.id]);
      } else {
        await DatabaseService.insert('moods', entry.toMap());
      }
      await loadMoods();
    } catch (e) {
      debugPrint('Error saving mood: $e');
    }
  }

  Future<void> deleteMood(int id) async {
    await DatabaseService.delete('moods', 'id = ?', [id]);
    await loadMoods();
  }

  List<MoodEntry> get last7Days {
    final now = DateTime.now();
    return _entries.where((e) {
      return now.difference(e.date).inDays < 7;
    }).toList();
  }

  List<MoodEntry> get last30Days {
    final now = DateTime.now();
    return _entries.where((e) {
      return now.difference(e.date).inDays < 30;
    }).toList();
  }
}

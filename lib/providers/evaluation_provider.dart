import 'package:flutter/foundation.dart';
import '../models/daily_evaluation.dart';
import '../services/database_service.dart';

class EvaluationProvider extends ChangeNotifier {
  List<DailyEvaluation> _evaluations = [];
  DailyEvaluation? _todayEvaluation;
  bool _isLoading = false;

  List<DailyEvaluation> get evaluations => _evaluations;
  DailyEvaluation? get todayEvaluation => _todayEvaluation;
  bool get isLoading => _isLoading;

  Future<void> loadEvaluations() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('evaluations',
          orderBy: 'date DESC');
      _evaluations = maps.map((m) => DailyEvaluation.fromMap(m)).toList();
      _todayEvaluation = _evaluations.where((e) {
        final today = DateTime.now();
        return e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day;
      }).firstOrNull;
    } catch (e) {
      debugPrint('Error loading evaluations: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveEvaluation(DailyEvaluation evaluation) async {
    try {
      if (_todayEvaluation != null) {
        await DatabaseService.update('evaluations', evaluation.toMap(),
            'id = ?', [_todayEvaluation!.id]);
      } else {
        await DatabaseService.insert('evaluations', evaluation.toMap());
      }
      await loadEvaluations();
    } catch (e) {
      debugPrint('Error saving evaluation: $e');
    }
  }

  List<DailyEvaluation> get last30Days {
    final now = DateTime.now();
    return _evaluations.where((e) {
      return now.difference(e.date).inDays < 30;
    }).toList();
  }

  double get averageRating {
    if (_evaluations.isEmpty) return 0;
    return _evaluations.fold(0, (sum, e) => sum + e.rating) /
        _evaluations.length;
  }

  int get satisfiedDays => _evaluations.where((e) => e.satisfied).length;
  int get totalDays => _evaluations.length;
}

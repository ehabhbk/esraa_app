import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterProvider extends ChangeNotifier {
  int _todayCups = 0;
  static const int _targetCups = 8;

  int get todayCups => _todayCups;
  int get targetCups => _targetCups;
  double get progress => (_todayCups / _targetCups).clamp(0.0, 1.0);
  int get remaining => (_targetCups - _todayCups).clamp(0, _targetCups);

  Future<void> loadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    _todayCups = prefs.getInt('water_cups_$today') ?? 0;
    notifyListeners();
  }

  Future<void> addCup() async {
    if (_todayCups >= _targetCups) return;
    _todayCups++;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setInt('water_cups_$today', _todayCups);
    notifyListeners();
  }

  Future<void> removeCup() async {
    if (_todayCups <= 0) return;
    _todayCups--;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setInt('water_cups_$today', _todayCups);
    notifyListeners();
  }

  Future<void> resetDaily() async {
    _todayCups = 0;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setInt('water_cups_$today', 0);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_log.dart';

class MealProvider extends ChangeNotifier {
  final Map<MealType, bool> _todayMeals = {};

  bool isEaten(MealType type) => _todayMeals[type] ?? false;
  int get eatenCount =>
      _todayMeals.values.where((e) => e).length;
  int get totalMeals => MealType.values.length;

  Future<void> loadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    for (final meal in MealType.values) {
      final key = 'meal_${meal.name}_$today';
      _todayMeals[meal] = prefs.getBool(key) ?? false;
    }
    notifyListeners();
  }

  Future<void> toggleMeal(MealType type) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final current = _todayMeals[type] ?? false;
    final newValue = !current;
    _todayMeals[type] = newValue;
    await prefs.setBool('meal_${type.name}_$today', newValue);
    notifyListeners();
  }
}

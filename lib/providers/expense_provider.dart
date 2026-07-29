import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;
  double _dailyLimit = 0;
  double get dailyLimit => _dailyLimit;
  bool _limitExceeded = false;
  bool get limitExceeded => _limitExceeded;
  double _threshold = 0.8;
  double get threshold => _threshold;
  bool _nearLimitNotified = false;

  Future<void> loadExpenses() async {
    final data = await DatabaseService.query('expenses', orderBy: 'date DESC');
    _expenses = data.map((m) => Expense.fromMap(m)).toList();
    await _loadDailyLimit();
    notifyListeners();
  }

  Future<void> _loadDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyLimit = prefs.getDouble('daily_expense_limit') ?? 0;
    _threshold = prefs.getDouble('expense_threshold') ?? 0.8;
  }

  Future<void> setDailyLimit(double limit) async {
    _dailyLimit = limit;
    _nearLimitNotified = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('daily_expense_limit', limit);
    _checkDailyLimit();
    notifyListeners();
  }

  Future<void> setThreshold(double t) async {
    _threshold = t;
    _nearLimitNotified = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('expense_threshold', t);
    notifyListeners();
  }

  double get todayTotal {
    final today = DateTime.now();
    final todayStr = _dateStr(today);
    return _expenses
        .where((e) => e.date == todayStr)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get dailyTotals {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.date] = (map[e.date] ?? 0) + e.amount;
    }
    return map;
  }

  List<MapEntry<String, double>> get last30DaysTotals {
    final totals = dailyTotals;
    final result = <MapEntry<String, double>>[];
    final now = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = _dateStr(d);
      result.add(MapEntry(key, totals[key] ?? 0));
    }
    return result;
  }

  double get averageDaily {
    final totals = dailyTotals;
    if (totals.isEmpty) return 0;
    return totals.values.fold(0.0, (a, b) => a + b) / totals.length;
  }

  MapEntry<String, double>? get maxDay {
    final totals = dailyTotals;
    if (totals.isEmpty) return null;
    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
  }

  MapEntry<String, double>? get minDay {
    final totals = dailyTotals;
    if (totals.isEmpty) return null;
    return totals.entries.reduce((a, b) => a.value <= b.value ? a : b);
  }

  void _checkDailyLimit() {
    if (_dailyLimit <= 0) return;
    final today = todayTotal;
    _limitExceeded = today >= _dailyLimit;
    if (_limitExceeded) {
      NotificationService.showNotification(
        id: 998,
        title: '⚠️ تجاوز الحد اليومي',
        body: 'لقد تجاوزتي الحد اليومي للمصروفات (${_dailyLimit.toStringAsFixed(0)} ج.س)',
      );
    } else if (today >= _dailyLimit * _threshold && !_nearLimitNotified) {
      _nearLimitNotified = true;
      final remaining = _dailyLimit - today;
      NotificationService.showNotification(
        id: 997,
        title: '⚡ اقتربت من الحد اليومي',
        body: 'بقى لك فقط $remaining ج.س للوصول للحد اليومي (${_dailyLimit.toStringAsFixed(0)} ج.س)',
      );
    }
  }

  Future<void> addExpense(Expense e) async {
    await DatabaseService.insert('expenses', e.toMap());
    await loadExpenses();
    _checkDailyLimit();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseService.delete('expenses', 'id = ?', [id]);
    await loadExpenses();
    _limitExceeded = false;
    _nearLimitNotified = false;
  }

  double get totalAmount => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

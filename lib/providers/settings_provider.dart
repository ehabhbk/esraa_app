import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _biometricEnabled = false;
  int _waterInterval = 60;
  bool _notificationsEnabled = true;
  bool _summaryEnabled = true;
  int _summaryHour = 20;
  int _summaryMinute = 0;

  bool get isDarkMode => _isDarkMode;
  bool get biometricEnabled => _biometricEnabled;
  int get waterInterval => _waterInterval;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get summaryEnabled => _summaryEnabled;
  int get summaryHour => _summaryHour;
  int get summaryMinute => _summaryMinute;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    _waterInterval = prefs.getInt('waterInterval') ?? 60;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _summaryEnabled = prefs.getBool('summaryEnabled') ?? true;
    _summaryHour = prefs.getInt('summaryHour') ?? 20;
    _summaryMinute = prefs.getInt('summaryMinute') ?? 0;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleBiometric() async {
    _biometricEnabled = !_biometricEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', _biometricEnabled);
    notifyListeners();
  }

  Future<void> setWaterInterval(int minutes) async {
    _waterInterval = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterInterval', minutes);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> setSummaryTime(int hour, int minute) async {
    _summaryHour = hour;
    _summaryMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('summaryHour', hour);
    await prefs.setInt('summaryMinute', minute);
    await NotificationService.cancelDailySummary();
    if (_summaryEnabled) await NotificationService.scheduleDailySummary(hour, minute);
    notifyListeners();
  }

  Future<void> toggleSummary() async {
    _summaryEnabled = !_summaryEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('summaryEnabled', _summaryEnabled);
    if (_summaryEnabled) {
      await NotificationService.scheduleDailySummary(_summaryHour, _summaryMinute);
    } else {
      await NotificationService.cancelDailySummary();
    }
    notifyListeners();
  }
}

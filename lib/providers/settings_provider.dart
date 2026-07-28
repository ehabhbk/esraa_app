import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _biometricEnabled = false;
  int _waterInterval = 60;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get biometricEnabled => _biometricEnabled;
  int get waterInterval => _waterInterval;
  bool get notificationsEnabled => _notificationsEnabled;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    _waterInterval = prefs.getInt('waterInterval') ?? 60;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
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
}

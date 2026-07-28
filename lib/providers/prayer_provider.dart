import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_record.dart';

class PrayerProvider extends ChangeNotifier {
  final Map<PrayerName, bool> _todayPrayers = {};

  bool isPerformed(PrayerName prayer) => _todayPrayers[prayer] ?? false;
  int get performedCount =>
      _todayPrayers.values.where((p) => p).length;
  int get totalPrayers => PrayerName.values.length;
  double get progress => performedCount / totalPrayers;

  Future<void> loadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    for (final prayer in PrayerName.values) {
      final key = 'prayer_${prayer.name}_$today';
      _todayPrayers[prayer] = prefs.getBool(key) ?? false;
    }
    notifyListeners();
  }

  Future<void> togglePrayer(PrayerName prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final current = _todayPrayers[prayer] ?? false;
    _todayPrayers[prayer] = !current;
    await prefs.setBool('prayer_${prayer.name}_$today', !current);
    notifyListeners();
  }

  String get nextPrayer {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 5) return 'الفجر';
    if (hour < 12) return 'الظهر';
    if (hour < 15) return 'العصر';
    if (hour < 18) return 'المغرب';
    if (hour < 21) return 'العشاء';
    return 'الفجر (غدًا)';
  }

  String getCountdown() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    int targetHour;
    if (hour < 5) {
      targetHour = 5;
    } else if (hour < 12) {
      targetHour = 12;
    } else if (hour < 15) {
      targetHour = 15;
    } else if (hour < 18) {
      targetHour = 18;
    } else if (hour < 21) {
      targetHour = 21;
    } else {
      return 'الفجر غدًا';
    }
    int diffHours = targetHour - hour;
    int diffMinutes = 0 - minute;
    if (diffMinutes < 0) {
      diffHours--;
      diffMinutes += 60;
    }
    if (diffHours < 0) diffHours += 24;
    return '$diffHours ساعة $diffMinutes دقيقة';
  }
}

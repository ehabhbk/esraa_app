import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  List<Achievement> get achievements => _achievements;

  Future<void> loadAchievements() async {
    final data = await DatabaseService.query('achievements', orderBy: 'title ASC');
    _achievements = data.map((m) => Achievement.fromMap(m)).toList();
    notifyListeners();
  }

  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;
}

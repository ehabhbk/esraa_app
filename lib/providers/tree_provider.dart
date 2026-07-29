import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class TreeProvider extends ChangeNotifier {
  int _totalAchievements = 0;
  int _unlockedAchievements = 0;
  List<Map<String, dynamic>> _recentAchievements = [];

  int get totalAchievements => _totalAchievements;
  int get unlockedAchievements => _unlockedAchievements;
  List<Map<String, dynamic>> get recentAchievements => _recentAchievements;

  Future<void> loadProgress() async {
    final data = await DatabaseService.query('achievements');
    _totalAchievements = data.length;
    _unlockedAchievements = data.where((a) => (a['isUnlocked'] as int) == 1).length;
    final recent = await DatabaseService.query('achievements',
        where: 'isUnlocked = 1', orderBy: 'unlockedAt DESC', limit: 5);
    _recentAchievements = recent;
    notifyListeners();
  }

  double getProgress() {
    if (_totalAchievements == 0) return 0.0;
    return (_unlockedAchievements / _totalAchievements).clamp(0.0, 1.0);
  }

  Map<String, dynamic> getTreeStage() {
    final progress = getProgress();
    if (progress < 0.1) {
      return {'name': 'بذرة', 'emoji': '🌱', 'description': 'بداية الرحلة'};
    } else if (progress < 0.25) {
      return {'name': 'شتلة', 'emoji': '🌿', 'description': 'بداية النمو'};
    } else if (progress < 0.5) {
      return {'name': 'شجرة صغيرة', 'emoji': '🌳', 'description': 'استمرار النمو'};
    } else if (progress < 0.75) {
      return {'name': 'شجرة متوسطة', 'emoji': '🌲', 'description': 'نمو مستمر'};
    } else if (progress < 0.9) {
      return {'name': 'شجرة مثمرة', 'emoji': '🌴', 'description': 'الإثمار والنجاح'};
    } else {
      return {'name': 'غابة', 'emoji': '🌴🌲🌳', 'description': 'قمة النجاح'};
    }
  }
}

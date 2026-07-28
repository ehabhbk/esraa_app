import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const achievements = [
    {'emoji': '🔥', 'title': 'بداية قوية', 'desc': 'أول يوم استخدام', 'target': 1},
    {'emoji': '🌟', 'title': 'أسبوع كامل', 'desc': '7 أيام استخدام متواصل', 'target': 7},
    {'emoji': '💪', 'title': 'شهر من الالتزام', 'desc': '30 يوم استخدام', 'target': 30},
    {'emoji': '📝', 'title': 'مدونة محترفة', 'desc': '50 ملاحظة مكتوبة', 'target': 50},
    {'emoji': '💧', 'title': 'عاشقة الماء', 'desc': 'شرب 8 أكواب لـ 7 أيام', 'target': 7},
    {'emoji': '🕌', 'title': 'محافظة على الصلاة', 'desc': 'أداء 5 صلوات لـ 30 يوم', 'target': 30},
    {'emoji': '🤲', 'title': 'الدعاء الدائم', 'desc': '30 يوم دعاء لأبي', 'target': 30},
    {'emoji': '😊', 'title': 'متفائلة', 'desc': 'تسجيل 10 أيام بمزاج ممتاز', 'target': 10},
    {'emoji': '⭐', 'title': 'التقييم اليومي', 'desc': '50 تقييم يومي', 'target': 50},
    {'emoji': '✉️', 'title': 'رسائل لأبي', 'desc': '10 رسائل لأبي', 'target': 10},
    {'emoji': '📋', 'title': 'منجزة', 'desc': '100 مهمة مكتملة', 'target': 100},
    {'emoji': '🏆', 'title': 'طبيبة الامتياز', 'desc': 'استخدام التطبيق طوال فترة الامتياز', 'target': 365},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 الإنجازات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  const Text(
                    'إنجازاتك',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'كل يوم هو إنجاز جديد',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('${achievements.length}', 'إنجاز'),
                      _buildStat('${(achievements.length * 0.3).toInt()}', 'مُنجز'),
                      _buildStat('🔥 0', 'أيام'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...achievements.map((a) {
              final progress = 0.0;
              final isUnlocked = false;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Row(
                    children: [
                      Text(a['emoji'] as String,
                          style: TextStyle(
                            fontSize: 36,
                            color: isUnlocked ? null : Colors.grey[400],
                          )),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isUnlocked
                                    ? AppColors.textPrimary
                                    : Colors.grey[500],
                              ),
                            ),
                            Text(
                              a['desc'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

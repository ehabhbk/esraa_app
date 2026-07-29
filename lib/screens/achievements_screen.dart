import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 الإنجازات')),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          final achievements = provider.achievements;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      const Text('إنجازاتك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('كل يوم هو إنجاز جديد', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat('${achievements.length}', 'إجمالي'),
                          _buildStat('${provider.unlockedCount}', 'مفتوح'),
                          _buildStat('${achievements.length - provider.unlockedCount}', 'مغلق'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (achievements.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('لا توجد إنجازات', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...achievements.map((a) {
                    final isUnlocked = a.isUnlocked;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Text(a.iconEmoji, style: TextStyle(fontSize: 36, color: isUnlocked ? Colors.black87 : Colors.grey)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isUnlocked ? AppColors.textPrimary : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    a.description,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: a.percentage,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isUnlocked ? AppColors.success : AppColors.primary,
                                      ),
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
          );
        },
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

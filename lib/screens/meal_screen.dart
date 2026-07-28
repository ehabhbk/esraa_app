import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/meal_log.dart';
import '../providers/meal_provider.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍽 الوجبات')),
      body: Consumer<MealProvider>(
        builder: (context, meal, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMealStat('${meal.eatenCount}', 'تم'),
                          _buildMealStat(
                              '${meal.totalMeals - meal.eatenCount}', 'متبقي'),
                          _buildMealStat(
                              '${(meal.eatenCount / meal.totalMeals * 100).toInt()}%',
                              'نسبة'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...MealType.values.map((type) {
                  final eaten = meal.isEaten(type);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      child: ListTile(
                        leading: Text(
                          type.label.split(' ').first,
                          style: const TextStyle(fontSize: 32),
                        ),
                        title: Text(
                          type.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          eaten ? Icons.check_circle : Icons.circle_outlined,
                          color: eaten ? AppColors.success : Colors.grey[400],
                          size: 32,
                        ),
                        onTap: () => meal.toggleMeal(type),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🥗 نصائح غذائية',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildTip('🌅', 'الفطور: وجبة خفيفة ومغذية'),
                      _buildTip('☀️', 'الغداء: بروتين وخضراوات'),
                      _buildTip('🌙', 'العشاء: خفيف وسهل الهضم'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

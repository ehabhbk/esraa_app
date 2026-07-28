import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../data/prayer_duas.dart';

class DuaScreen extends StatelessWidget {
  final String title;

  const DuaScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final allDuas = PrayerDuas.allDuas;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          GlassCard(
            backgroundColor: AppColors.purpleSoft,
            margin: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Text('🤲', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text(
                  'اللهم اغفر لإبراهيم مضوي وارحمه',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'واجعل قبره روضة من رياض الجنة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  '📖 أدعية متنوعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${allDuas.length} دعاء',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allDuas.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.purpleSoft.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          allDuas[index],
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                      duration: 300.ms,
                      delay: Duration(milliseconds: index * 30),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

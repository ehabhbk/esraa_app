import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/water_tracker_widget.dart';
import '../providers/water_provider.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💧 شرب الماء')),
      body: Consumer<WaterProvider>(
        builder: (context, water, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  backgroundColor: AppColors.blueSoft,
                  child: const Column(
                    children: [
                      Text('💧', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text(
                        'تذكير بشرب الماء',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '8 أكواب يومياً للحفاظ على صحتك ونشاطك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    children: [
                      const WaterTrackerWidget(),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: water.progress,
                          minHeight: 16,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.waterBlue),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(water.progress * 100).toInt()}% من هدفك اليومي',
                        style: const TextStyle(
                          color: AppColors.waterBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 فوائد شرب الماء',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildBenefit('✅', 'يحسن التركيز والذاكرة'),
                      _buildBenefit('✅', 'يرطب البشرة ويحسن مظهرها'),
                      _buildBenefit('✅', 'يساعد على الهضم'),
                      _buildBenefit('✅', 'يقلل الإرهاق والتعب'),
                      _buildBenefit('✅', 'ينظم درجة حرارة الجسم'),
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

  Widget _buildBenefit(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

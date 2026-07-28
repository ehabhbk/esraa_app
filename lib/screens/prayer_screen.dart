import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/prayer_record.dart';
import '../providers/prayer_provider.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🕌 الصلاة')),
      body: Consumer<PrayerProvider>(
        builder: (context, prayer, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  backgroundColor: AppColors.prayerGreen.withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      const Text('🕌', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text(
                        'الصلاة القادمة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prayer.nextPrayer,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.prayerGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'متبقي: ${prayer.getCountdown()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: prayer.progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.prayerGreen),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${prayer.performedCount} من ${prayer.totalPrayers}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.prayerGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    children: PrayerName.values.map((p) {
                      final performed = prayer.isPerformed(p);
                      return ListTile(
                        leading: Text(p.emoji, style: const TextStyle(fontSize: 28)),
                        title: Text(
                          p.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          performed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: performed
                              ? AppColors.prayerGreen
                              : Colors.grey[400],
                          size: 28,
                        ),
                        onTap: () => prayer.togglePrayer(p),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📖 أذكار',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildAdhkarItem('🌅', 'أذكار الصباح'),
                      const SizedBox(height: 8),
                      _buildAdhkarItem('🌇', 'أذكار المساء'),
                      const SizedBox(height: 8),
                      _buildAdhkarItem('🌙', 'أذكار النوم'),
                      const SizedBox(height: 8),
                      _buildAdhkarItem('☀️', 'أذكار الاستيقاظ'),
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

  Widget _buildAdhkarItem(String emoji, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.chevron_left, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

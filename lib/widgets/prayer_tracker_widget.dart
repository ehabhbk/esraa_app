import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_record.dart';
import '../providers/prayer_provider.dart';
import '../theme/app_colors.dart';

class PrayerTrackerWidget extends StatelessWidget {
  const PrayerTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, prayer, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🕌', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  'الصلاة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'الصلاة القادمة: ${prayer.nextPrayer}',
              style: const TextStyle(
                color: AppColors.prayerGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'متبقي: ${prayer.getCountdown()}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PrayerName.values.map((p) {
                final performed = prayer.isPerformed(p);
                return GestureDetector(
                  onTap: () => prayer.togglePrayer(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: performed
                          ? AppColors.prayerGreen.withValues(alpha: 0.2)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: performed ? AppColors.prayerGreen : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          performed ? '✅' : p.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.label,
                          style: TextStyle(
                            fontWeight: performed
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: performed
                                ? AppColors.prayerGreen
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

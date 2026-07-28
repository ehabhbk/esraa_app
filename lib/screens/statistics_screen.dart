import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/mood_provider.dart';
import '../providers/evaluation_provider.dart';
import '../providers/water_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 الإحصائيات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsGrid(context),
            const SizedBox(height: 16),
            _buildMoodChart(context),
            const SizedBox(height: 16),
            _buildSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final mood = context.watch<MoodProvider>();
    final eval = context.watch<EvaluationProvider>();
    final water = context.watch<WaterProvider>();
    final prayer = context.watch<PrayerProvider>();
    final task = context.watch<TaskProvider>();
    final notes = context.watch<NoteProvider>();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('😊', 'المزاج', mood.last30Days.length.toString(),
            AppColors.purpleSoft),
        _buildStatCard('⭐', 'التقييمات',
            eval.averageRating.toStringAsFixed(1), AppColors.orangeSoft),
        _buildStatCard('💧', 'شرب الماء', '${water.todayCups}/8',
            AppColors.blueSoft),
        _buildStatCard('🕌', 'الصلاة', '${prayer.performedCount}/5',
            AppColors.greenSoft),
        _buildStatCard('📋', 'المهام',
            '${task.completedCount}', AppColors.pinkSoft),
        _buildStatCard('📓', 'ملاحظات',
            '${notes.notes.length}', AppColors.purpleSoft),
      ],
    );
  }

  Widget _buildStatCard(
      String emoji, String label, String value, Color bgColor) {
    return GlassCard(
      backgroundColor: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, mood, child) {
        final recent = mood.last7Days;
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📈 تطور المزاج (آخر 7 أيام)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('لا توجد بيانات كافية',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: recent.reversed.take(7).map((e) {
                    return Column(
                      children: [
                        Text(e.mood.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          '${e.date.day}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Consumer<EvaluationProvider>(
      builder: (context, eval, child) {
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 ملخص عام',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow('إجمالي التقييمات', '${eval.totalDays}'),
              const Divider(),
              _buildSummaryRow('متوسط التقييم',
                  eval.averageRating.toStringAsFixed(1)),
              const Divider(),
              _buildSummaryRow('أيام راضية',
                  '${eval.satisfiedDays}'),
              const Divider(),
              _buildSummaryRow('نسبة الرضا',
                  '${eval.totalDays > 0 ? (eval.satisfiedDays / eval.totalDays * 100).toInt() : 0}%'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

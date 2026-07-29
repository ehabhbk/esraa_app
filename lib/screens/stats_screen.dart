import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/mood_provider.dart';
import '../providers/evaluation_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/shift_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatients();
      context.read<AchievementProvider>().loadAchievements();
      context.read<ShiftProvider>().loadShifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 الإحصائيات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCards(context),
            const SizedBox(height: 16),
            _buildWeeklyMoodChart(context),
            const SizedBox(height: 16),
            _buildMonthlyEvaluationChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final patients = context.watch<PatientProvider>().patients.length;
    final achievements = context.watch<AchievementProvider>().unlockedCount;
    final shifts = context.watch<ShiftProvider>().shifts.length;
    return Row(
      children: [
        Expanded(child: _buildMiniCard('📋', 'المرضى', '$patients', AppColors.purpleSoft)),
        const SizedBox(width: 8),
        Expanded(child: _buildMiniCard('🏆', 'الإنجازات', '$achievements', AppColors.greenSoft)),
        const SizedBox(width: 8),
        Expanded(child: _buildMiniCard('⏰', 'الشفتات', '$shifts', AppColors.orangeSoft)),
      ],
    );
  }

  Widget _buildMiniCard(String emoji, String label, String value, Color bg) {
    return GlassCard(
      backgroundColor: bg,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildWeeklyMoodChart(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final weekData = moodProvider.last7Days;
        final dayNames = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
        final today = DateTime.now();
        final bars = <BarChartGroupData>[];
        for (int i = 6; i >= 0; i--) {
          final day = today.subtract(Duration(days: i));
          final dayStr = DateFormat('yyyy-MM-dd').format(day);
          final entry = weekData.where((e) =>
            DateFormat('yyyy-MM-dd').format(e.date) == dayStr).toList();
          final avg = entry.isEmpty ? 0.0 : entry.fold(0.0, (sum, e) => sum + e.mood.value) / entry.length;
          bars.add(BarChartGroupData(
            x: 6 - i,
            barRods: [BarChartRodData(toY: avg, color: AppColors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
          ));
        }
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📈 المزاج الأسبوعي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 4.5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                      final idx = val.toInt();
                      return idx >= 0 && idx < 7 ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(dayNames[idx][0], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ) : const SizedBox();
                    })),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: bars,
                )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyEvaluationChart(BuildContext context) {
    return Consumer<EvaluationProvider>(
      builder: (context, evalProvider, child) {
        final monthData = evalProvider.last30Days;
        if (monthData.isEmpty) {
          return GlassCard(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('لا توجد تقييمات بعد', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          );
        }
        final spots = <FlSpot>[];
        final sorted = monthData.reversed.toList();
        for (int i = 0; i < sorted.length; i++) {
          spots.add(FlSpot(i.toDouble(), sorted[i].rating.toDouble()));
        }
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📊 تطور التقييمات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: LineChart(LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppColors.accent.withValues(alpha: 0.1)),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}

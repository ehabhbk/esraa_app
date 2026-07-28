import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/daily_evaluation.dart';
import '../providers/evaluation_provider.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int _rating = 0;
  bool _learnedSomething = false;
  bool _helpedPatient = false;
  bool _satisfied = false;
  final _notesController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExisting();
    });
  }

  void _loadExisting() {
    final provider = context.read<EvaluationProvider>();
    final existing = provider.todayEvaluation;
    if (existing != null) {
      setState(() {
        _rating = existing.rating;
        _learnedSomething = existing.learnedSomething;
        _helpedPatient = existing.helpedPatient;
        _satisfied = existing.satisfied;
        _notesController.text = existing.notes;
        _isSubmitted = true;
      });
    }
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    final evaluation = DailyEvaluation(
      date: DateTime.now(),
      rating: _rating,
      learnedSomething: _learnedSomething,
      helpedPatient: _helpedPatient,
      satisfied: _satisfied,
      notes: _notesController.text,
    );
    await context.read<EvaluationProvider>().saveEvaluation(evaluation);
    setState(() => _isSubmitted = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم تسجيل تقييم اليوم'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 تقييم اليوم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                children: [
                  const Text(
                    'كيف كان يومك؟',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 40,
                            color: index < _rating
                                ? AppColors.gold
                                : Colors.grey[300],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _buildQuestion(
                    'هل تعلمت شيئًا جديدًا؟',
                    _learnedSomething,
                    (v) => setState(() => _learnedSomething = v ?? false),
                  ),
                  const Divider(),
                  _buildQuestion(
                    'هل ساعدت مريضًا اليوم؟',
                    _helpedPatient,
                    (v) => setState(() => _helpedPatient = v ?? false),
                  ),
                  const Divider(),
                  _buildQuestion(
                    'هل أنت راضية عن نفسك؟',
                    _satisfied,
                    (v) => setState(() => _satisfied = v ?? false),
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
                    'ملاحظاتك',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'اكتبي ملاحظاتك عن اليوم...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 ? _submit : null,
                child: Text(_isSubmitted ? 'تم التقييم ✅' : 'تسجيل التقييم'),
              ),
            ),
            const SizedBox(height: 30),
            _buildChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(
      String text, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(text),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildChart(BuildContext context) {
    return Consumer<EvaluationProvider>(
      builder: (context, provider, child) {
        final data = provider.last30Days;
        if (data.isEmpty) {
          return const GlassCard(
            child: Center(
              child: Text('لا توجد بيانات كافية بعد',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 تطور التقييمات (آخر 30 يوم)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 5,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < data.length) {
                              return Text(
                                '${data[idx].date.day}',
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 20,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0 || value == 5) {
                              return Text('${value.toInt()}',
                                  style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.take(30).toList().asMap().entries.map(
                      (entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.rating.toDouble(),
                              color: entry.value.rating >= 4
                                  ? AppColors.success
                                  : entry.value.rating >= 3
                                      ? AppColors.warning
                                      : AppColors.error,
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('المعدل', provider.averageRating.toStringAsFixed(1)),
                  _buildStat('أيام راضية', '${provider.satisfiedDays}'),
                  _buildStat('إجمالي', '${provider.totalDays}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

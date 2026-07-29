import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/measurement.dart';
import '../providers/measurement_provider.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeasurementProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📏 قياساتي'),
        centerTitle: true,
      ),
      body: Consumer<MeasurementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: provider.loadRecords,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.weightHistory.length >= 2)
                    _buildWeightChart(provider.weightHistory),
                  if (provider.weightHistory.length >= 2)
                    const SizedBox(height: 16),
                  if (provider.records.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('لا توجد قياسات بعد 🌸', style: TextStyle(color: AppColors.textSecondary)),
                    ))
                  else
                    ...provider.records.map((r) => _buildMeasurementCard(r, provider)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWeightChart(List<Measurement> history) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📈', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('الوزن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < history.length) {
                          return Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              DateFormat('M/d').format(history[idx].date),
                              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(history.length, (i) {
                      return FlSpot(i.toDouble(), history[i].weight!);
                    }),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                minY: (history.map((e) => e.weight!).reduce((a, b) => a < b ? a : b) - 2).floorToDouble(),
                maxY: (history.map((e) => e.weight!).reduce((a, b) => a > b ? a : b) + 2).ceilToDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(Measurement record, MeasurementProvider provider) {
    final dateStr = DateFormat('EEEE, d MMMM y', 'ar').format(record.date);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('حذف القياس'),
                      content: const Text('هل تريد حذف هذا القياس؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                        ElevatedButton(
                          onPressed: () {
                            provider.deleteRecord(record.id!);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('حذف', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.delete_outline, color: AppColors.textLight, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (record.weight != null)
                _buildMeasureItem('الوزن', '${record.weight!.toStringAsFixed(1)} كجم'),
              if (record.height != null)
                _buildMeasureItem('الطول', '${record.height!.toStringAsFixed(1)} سم'),
            ],
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(record.notes, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildMeasureItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة قياس جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('التاريخ: ${DateFormat('yyyy/MM/dd').format(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: weightCtrl,
                  decoration: const InputDecoration(labelText: 'الوزن (كجم)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightCtrl,
                  decoration: const InputDecoration(labelText: 'الطول (سم)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                context.read<MeasurementProvider>().addRecord(Measurement(
                  date: selectedDate,
                  weight: weightCtrl.text.isNotEmpty ? double.tryParse(weightCtrl.text) : null,
                  height: heightCtrl.text.isNotEmpty ? double.tryParse(heightCtrl.text) : null,
                  notes: notesCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

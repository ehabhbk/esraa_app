import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  static const _categoryColors = {
    'طعام': AppColors.orangeSoft,
    'مواصلات': AppColors.blueSoft,
    'مستلزمات': AppColors.purpleSoft,
    'علاج': AppColors.pinkSoft,
    'ترفيه': AppColors.greenSoft,
    'أخرى': Color(0xFFF5F5F5),
  };

  static const _categoryIcons = {
    'طعام': Icons.restaurant,
    'مواصلات': Icons.directions_car,
    'مستلزمات': Icons.shopping_bag,
    'علاج': Icons.medical_services,
    'ترفيه': Icons.movie,
    'أخرى': Icons.more_horiz,
  };

  void _showDialog() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'طعام';
    String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('إضافة مصروف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: _categoryColors.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDState(() => category = v!),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, initialDate: DateTime.parse(dateStr), firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (d != null) setDState(() => dateStr = DateFormat('yyyy-MM-dd').format(d));
                  },
                  child: AbsorbPointer(
                    child: TextField(decoration: InputDecoration(labelText: 'التاريخ', border: const OutlineInputBorder(), hintText: dateStr), textAlign: TextAlign.right),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (descCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                final e = Expense(
                  amount: double.parse(amountCtrl.text),
                  category: category,
                  description: descCtrl.text,
                  date: dateStr,
                );
                context.read<ExpenseProvider>().addExpense(e);
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyLimitCard(ExpenseProvider provider, double todayTotal, double limit) {
    final hasLimit = limit > 0;
    final ratio = hasLimit ? (todayTotal / limit) : 0.0;
    final exceeded = ratio >= 1.0;
    return GestureDetector(
      onTap: () => _setDailyLimitDialog(provider),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.today, size: 20, color: exceeded ? AppColors.error : AppColors.primary),
                const SizedBox(width: 8),
                const Text('مصروفات اليوم', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!hasLimit)
                  GestureDetector(
                    onTap: () => _setDailyLimitDialog(provider),
                    child: const Text('تحديد حد', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('$todayTotal ج.س', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: exceeded ? AppColors.error : AppColors.textPrimary)),
            if (hasLimit) ...[
              const SizedBox(height: 4),
              Text('من أصل $limit ج.س', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(exceeded ? AppColors.error : AppColors.success),
                ),
              ),
              if (exceeded) ...[
                const SizedBox(height: 8),
                const Text('⚠️ تجاوزتي الحد اليومي!', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _setDailyLimitDialog(ExpenseProvider provider) {
    final ctrl = TextEditingController(text: provider.dailyLimit > 0 ? provider.dailyLimit.toStringAsFixed(0) : '');
    double threshold = provider.threshold;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('الحد اليومي للمصروفات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), textAlign: TextAlign.right),
              const SizedBox(height: 16),
              Text('الإشعار عند: ${(threshold * 100).toInt()}% من الحد'),
              Slider(
                value: threshold,
                min: 0.5, max: 0.95, divisions: 9,
                label: '${(threshold * 100).toInt()}%',
                onChanged: (v) => setDState(() => threshold = v),
              ),
              Text('مثال: عند ${(provider.dailyLimit * threshold).toStringAsFixed(0)} ج.س', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text);
                if (v != null && v > 0) provider.setDailyLimit(v);
                provider.setThreshold(threshold);
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyComparison(ExpenseProvider provider) {
    final data = provider.last30DaysTotals;
    final last7 = data.length > 7 ? data.sublist(data.length - 7) : data;
    final maxVal = last7.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return const SizedBox.shrink();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 مقارنة آخر 7 أيام', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barGroups: last7.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: entry.value >= maxVal ? AppColors.error : AppColors.primary,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ]);
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= last7.length) return const SizedBox.shrink();
                        final d = last7[idx].key.substring(5);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(d, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ExpenseProvider provider) {
    final avg = provider.averageDaily;
    final maxD = provider.maxDay;
    final minD = provider.minDay;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📈 مؤشرات الصرف', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _statBox('📊', 'المعدل', '${avg.toStringAsFixed(0)} ج.س', AppColors.primary),
              const SizedBox(width: 8),
              _statBox('⬆️', 'أعلى يوم', maxD != null ? '${maxD.value.toStringAsFixed(0)} ج.س' : '---', AppColors.error),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statBox('⬇️', 'أقل يوم', minD != null ? '${minD.value.toStringAsFixed(0)} ج.س' : '---', AppColors.success),
              const SizedBox(width: 8),
              _statBox('📋', 'إجمالي', '${provider.totalAmount.toStringAsFixed(0)} ج.س', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💰 المصروفات')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.expenses.isEmpty) {
            return Center(
              child: Text('لا توجد مصروفات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          final catTotals = provider.categoryTotals;
          final total = provider.totalAmount;
          final today = provider.todayTotal;
          final limit = provider.dailyLimit;
          final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.warning, AppColors.success, AppColors.purpleSoft];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('إجمالي المصروفات', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('$total ج.س', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildDailyLimitCard(provider, today, limit),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('توزيع المصروفات', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: catTotals.entries.toList().asMap().entries.map((e) {
                            final i = e.key;
                            final entry = e.value;
                            return PieChartSectionData(
                              color: colors[i % colors.length],
                              value: entry.value,
                              title: '${entry.key}\n${(entry.value / total * 100).toStringAsFixed(0)}%',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...catTotals.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(_categoryIcons[e.key] ?? Icons.more_horiz, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                          Text('${e.value} ج.س', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              _buildDailyComparison(provider),
              const SizedBox(height: 16),
              _buildStatsRow(provider),
              const SizedBox(height: 16),
              ...provider.expenses.map((e) => Dismissible(
                key: ValueKey(e.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deleteExpense(e.id!),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(_categoryIcons[e.category] ?? Icons.more_horiz, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${e.category} • ${e.date}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text('${e.amount} ج.س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent)),
                    ],
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

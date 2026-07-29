import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/daily_goal.dart';
import '../providers/daily_goal_provider.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({super.key});

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  String _filter = 'يومي';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyGoalProvider>().loadGoals();
    });
  }

  static const _categoryColors = {
    'صحة': AppColors.greenSoft,
    'تعلم': AppColors.blueSoft,
    'عبادة': AppColors.purpleSoft,
    'عمل': AppColors.orangeSoft,
    'شخصي': AppColors.pinkSoft,
  };

  void _showDialog() {
    final titleCtrl = TextEditingController();
    String type = 'يومي';
    String category = 'صحة';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final weekStart = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('إضافة هدف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'الهدف', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                  items: ['يومي', 'أسبوعي'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDState(() => type = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: _categoryColors.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDState(() => category = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                final g = DailyGoal(
                  title: titleCtrl.text,
                  type: type,
                  category: category,
                  date: type == 'أسبوعي' ? weekStart : today,
                  weekStart: type == 'أسبوعي' ? weekStart : null,
                );
                context.read<DailyGoalProvider>().addGoal(g);
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎯 الأهداف')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<DailyGoalProvider>(
        builder: (context, provider, child) {
          final filtered = provider.goals.where((g) => g.type == _filter).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = 'يومي'),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('يومي', style: TextStyle(fontWeight: FontWeight.bold, color: _filter == 'يومي' ? AppColors.primary : AppColors.textSecondary)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = 'أسبوعي'),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('أسبوعي', style: TextStyle(fontWeight: FontWeight.bold, color: _filter == 'أسبوعي' ? AppColors.primary : AppColors.textSecondary)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('لا توجد أهداف', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final g = filtered[index];
                          final catColor = _categoryColors[g.category] ?? AppColors.blueSoft;
                          return Dismissible(
                            key: ValueKey(g.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => provider.deleteGoal(g.id!),
                            child: GlassCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: Checkbox(
                                  value: g.isDone,
                                  onChanged: (_) => provider.toggleDone(g.id!),
                                  activeColor: AppColors.primary,
                                ),
                                title: Text(
                                  g.title,
                                  style: TextStyle(
                                    decoration: g.isDone ? TextDecoration.lineThrough : null,
                                    color: g.isDone ? AppColors.textLight : AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(6)),
                                      child: Text(g.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                trailing: GestureDetector(
                                  onTap: () => provider.deleteGoal(g.id!),
                                  child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

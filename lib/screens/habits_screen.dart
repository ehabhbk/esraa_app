import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/daily_habit.dart';
import '../providers/habit_provider.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadToday();
    });
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    String icon = '⭐';
    int target = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('☕ عادة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم العادة', isDense: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(labelText: 'الوحدة (كوب, دقيقة, مرة)', isDense: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: icon,
                  decoration: const InputDecoration(labelText: 'الأيقونة', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: ['☕', '💧', '🚶', '📖', '🧘', '⭐', '🏋️', '🥗', '🎯', '📝'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 24)))).toList(),
                  onChanged: (v) => setDialogState(() => icon = v ?? '⭐'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('الهدف: '),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setDialogState(() {
                        if (target > 1) target--;
                      }),
                    ),
                    Text('$target', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setDialogState(() => target++),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || unitCtrl.text.trim().isEmpty) return;
                final habit = DailyHabit(
                  name: nameCtrl.text,
                  icon: icon,
                  unit: unitCtrl.text,
                  target: target,
                  date: DateTime.now().toIso8601String().substring(0, 10),
                );
                context.read<HabitProvider>().addHabit(habit);
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('☕ عاداتي اليومية')),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.habits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('☕', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('لا توجد عادات اليوم', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('أضيفي عادة جديدة 🌸', style: TextStyle(color: AppColors.textLight)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.habits.length,
            itemBuilder: (context, index) {
              final habit = provider.habits[index];
              final isComplete = habit.current >= habit.target;
              return GlassCard(
                backgroundColor: isComplete ? AppColors.greenSoft : null,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(habit.icon, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text(
                      habit.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habit.current}/${habit.target} ${habit.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isComplete ? AppColors.success : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: habit.target > 0 ? habit.current / habit.target : 0.0,
                        minHeight: 6,
                        backgroundColor: AppColors.purpleSoft,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isComplete)
                      const Text('🌟', style: TextStyle(fontSize: 20))
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => provider.decrement(habit.id!),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.pinkSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.remove, size: 18, color: AppColors.error),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => provider.increment(habit.id!),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.greenSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, size: 18, color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

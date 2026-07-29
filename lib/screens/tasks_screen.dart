import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    String category = 'عام';
    TimeOfDay? selectedTime;
    int reminderMin = 30;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة مهمة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'المهمة', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['عام', 'عمل', 'منزل', 'صحة', 'دراسة', 'أخرى'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                    if (t != null) setDialogState(() => selectedTime = t);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'الوقت',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    child: Text(selectedTime != null ? selectedTime!.format(context) : 'اختياري'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: reminderMin,
                  decoration: const InputDecoration(labelText: 'التذكير قبل', border: OutlineInputBorder()),
                  items: [5, 10, 15, 30, 60].map((m) => DropdownMenuItem(value: m, child: Text('$m دقيقة'))).toList(),
                  onChanged: (v) => setDialogState(() => reminderMin = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final task = Task(
                  title: titleCtrl.text.trim(),
                  date: DateTime.now(),
                  category: category,
                  scheduledTime: selectedTime != null ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}' : null,
                  reminderMinutes: reminderMin,
                );
                context.read<TaskProvider>().addTask(task);
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetail(Task task) {
    int progress = task.progress;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(task.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.scheduledTime != null)
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('🕐 ${task.scheduledTime}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              const SizedBox(height: 8),
              Row(children: [Icon(Icons.category, size: 16, color: AppColors.textSecondary), const SizedBox(width: 8), Text(task.category, style: const TextStyle(color: AppColors.textSecondary))]),
              const SizedBox(height: 16),
              const Text('نسبة التقدم', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Slider(
                value: progress.toDouble(),
                min: 0, max: 100, divisions: 20,
                label: '$progress%',
                activeColor: progress >= 100 ? AppColors.success : AppColors.primary,
                onChanged: (v) => setDialogState(() => progress = v.round()),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100, minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(progress >= 100 ? AppColors.success : AppColors.primary),
                ),
              ),
              const SizedBox(height: 4),
              Text('$progress%', style: TextStyle(color: progress >= 100 ? AppColors.success : AppColors.textSecondary)),
              if (progress >= 100) ...[
                const SizedBox(height: 8),
                const Text('✅ مكتمل!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                context.read<TaskProvider>().updateTask(task.copyWith(progress: progress));
                Navigator.pop(ctx);
              },
              child: const Text('حفظ التقدم'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 المهام')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.todayTasks;
          final completed = tasks.where((t) => t.isDone).length;
          final avgProgress = tasks.isEmpty ? 0 : tasks.fold(0, (sum, t) => sum + t.progress) ~/ tasks.length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('✅', 'مكتمل', '$completed', AppColors.success),
                          _statItem('📋', 'إجمالي', '${tasks.length}', AppColors.primary),
                          _statItem('📊', 'التقدم', '$avgProgress%', avgProgress >= 100 ? AppColors.success : AppColors.warning),
                        ],
                      ),
                      if (tasks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: tasks.isEmpty ? 0 : completed / tasks.length,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation(AppColors.success),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                        child: Text('🎉 لا توجد مهام اليوم', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return GestureDetector(
                            onTap: () => _showTaskDetail(task),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isDone,
                                    onChanged: (_) => taskProvider.toggleTask(task.id!),
                                    activeColor: AppColors.primary,
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                                      color: task.isDone ? AppColors.textLight : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(task.category, style: const TextStyle(fontSize: 12)),
                                          if (task.scheduledTime != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(Icons.access_time, size: 12, color: AppColors.primary),
                                            const SizedBox(width: 2),
                                            Text(task.scheduledTime!, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: task.progress / 100,
                                          minHeight: 4,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation(task.progress >= 100 ? AppColors.success : AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () => taskProvider.deleteTask(task.id!),
                                    child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  ),
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

  Widget _statItem(String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
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
  String _category = 'عام';

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

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final task = Task(
      title: text,
      date: DateTime.now(),
      category: _category,
    );
    context.read<TaskProvider>().addTask(task);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 المهام')),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.todayTasks;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'أضف مهمة جديدة...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _addTask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add_circle,
                            color: AppColors.primary, size: 32),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('مهام اليوم',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '${taskProvider.completedCount}/${taskProvider.tasks.length}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                        child: Text(
                          '🎉 لا توجد مهام اليوم',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.isDone,
                                  onChanged: (_) =>
                                      taskProvider.toggleTask(task.id!),
                                  activeColor: AppColors.primary,
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isDone
                                        ? AppColors.textLight
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                subtitle:
                                    Text(task.category, style: const TextStyle(fontSize: 12)),
                                trailing: GestureDetector(
                                  onTap: () => taskProvider.deleteTask(task.id!),
                                  child: const Icon(Icons.delete_outline,
                                      color: AppColors.error, size: 20),
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

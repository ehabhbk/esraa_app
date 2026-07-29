import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/dream_provider.dart';
import '../models/dream.dart';

class DreamsScreen extends StatefulWidget {
  const DreamsScreen({super.key});

  @override
  State<DreamsScreen> createState() => _DreamsScreenState();
}

class _DreamsScreenState extends State<DreamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DreamProvider>().loadDreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 قائمة أحلام'),
        centerTitle: true,
      ),
      body: Consumer<DreamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.dreams.isEmpty) {
            return const Center(
              child: Text('لا توجد أحلام بعد 🌟', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.dreams.length,
            itemBuilder: (context, index) {
              final dream = provider.dreams[index];
              return _buildDreamCard(dream, provider);
            },
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

  Widget _buildDreamCard(Dream dream, DreamProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        backgroundColor: dream.isAchieved ? AppColors.greenSoft : null,
        child: InkWell(
          onTap: () => provider.toggleAchieved(dream.id!),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(dream.isAchieved ? '🎉' : '🌟', style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dream.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: dream.isAchieved ? TextDecoration.lineThrough : null,
                            color: dream.isAchieved ? AppColors.textLight : AppColors.textPrimary,
                          ),
                        ),
                        if (dream.description.isNotEmpty)
                          Text(
                            dream.description,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(dream.category, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dream.isAchieved ? AppColors.success : AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        '${dream.priority}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dream.isAchieved ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('الأولوية: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('${dream.priority}/10', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: dream.priority / 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              dream.isAchieved ? AppColors.success : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, dream.id!),
                    child: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  ),
                ],
              ),
              if (dream.isAchieved && dream.achievedDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'تم التحقيق في ${dream.achievedDate!.substring(0, 10)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'شخصي';
    double priority = 5;
    DateTime? targetDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة حلم جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان الحلم', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()), maxLines: 3, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['سفر', 'تعلم', 'مهني', 'شخصي', 'عبادة'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: targetDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                    if (picked != null) setDialogState(() => targetDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'التاريخ المستهدف (اختياري)', border: OutlineInputBorder()),
                    child: Text(targetDate != null ? targetDate.toString().substring(0, 10) : 'اختر تاريخ', textAlign: TextAlign.right),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('الأولوية: '),
                    Expanded(
                      child: Slider(
                        value: priority,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: priority.round().toString(),
                        onChanged: (v) => setDialogState(() => priority = v),
                      ),
                    ),
                    Text('${priority.round()}/10'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                context.read<DreamProvider>().addDream(Dream(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  category: category,
                  targetDate: targetDate?.toIso8601String(),
                  priority: priority.round(),
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

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحلم'),
        content: const Text('هل أنت متأكدة من الحذف؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              context.read<DreamProvider>().deleteDream(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

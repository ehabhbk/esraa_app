import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/daily_impact.dart';
import '../providers/impact_provider.dart';

final Map<String, String> categoryEmoji = {
  'كلمة طيبة': '💬',
  'مساعدة': '🤝',
  'تشخيص': '🩺',
  'علاج': '💊',
  'أخرى': '✨',
};

final Map<String, String> emotionEmoji = {
  'فرح': '😊',
  'فخر': '🎓',
  'امتنان': '🙏',
  'أمل': '🌟',
};

class ImpactsScreen extends StatefulWidget {
  const ImpactsScreen({super.key});

  @override
  State<ImpactsScreen> createState() => _ImpactsScreenState();
}

class _ImpactsScreenState extends State<ImpactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImpactProvider>().loadImpacts();
    });
  }

  String _dateGroup(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(DateTime(date.year, date.month, date.day)).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    if (diff <= 7) return 'هذا الأسبوع';
    if (diff <= 30) return 'هذا الشهر';
    return 'سابقاً';
  }

  void _showAddDialog() {
    DateTime selectedDate = DateTime.now();
    String category = 'كلمة طيبة';
    String emotion = 'فرح';
    final patientCtrl = TextEditingController();
    final impactCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('🌟 بصمة يومية جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'التاريخ', isDense: true),
                    child: Text(DateFormat('yyyy-MM-dd', 'ar').format(selectedDate)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: patientCtrl,
                  decoration: const InputDecoration(labelText: 'وصف المريض أو الموقف', isDense: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: impactCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'الأثر الذي تركته'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: ['كلمة طيبة', 'مساعدة', 'تشخيص', 'علاج', 'أخرى'].map((c) => DropdownMenuItem(value: c, child: Text('${categoryEmoji[c] ?? ''} $c'))).toList(),
                  onChanged: (v) => setDialogState(() => category = v ?? 'كلمة طيبة'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: emotion,
                  decoration: const InputDecoration(labelText: 'الشعور', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: ['فرح', 'فخر', 'امتنان', 'أمل'].map((e) => DropdownMenuItem(value: e, child: Text('${emotionEmoji[e] ?? ''} $e'))).toList(),
                  onChanged: (v) => setDialogState(() => emotion = v ?? 'فرح'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (patientCtrl.text.trim().isEmpty || impactCtrl.text.trim().isEmpty) return;
                final impact = DailyImpact(
                  date: DateFormat('yyyy-MM-dd', 'ar').format(selectedDate),
                  patientDescription: patientCtrl.text,
                  impactDescription: impactCtrl.text,
                  category: category,
                  emotion: emotion,
                );
                context.read<ImpactProvider>().addImpact(impact);
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
      appBar: AppBar(title: const Text('🌟 بصمة يومية')),
      body: Consumer<ImpactProvider>(
        builder: (context, provider, child) {
          if (provider.impacts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🌟', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('لا توجد بصمات بعد', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('أضيفي أول بصمة لك 🌸', style: TextStyle(color: AppColors.textLight)),
                ],
              ),
            );
          }
          final grouped = <String, List<DailyImpact>>{};
          for (final i in provider.impacts) {
            final group = _dateGroup(i.date);
            grouped.putIfAbsent(group, () => []).add(i);
          }
          final groupOrder = ['اليوم', 'أمس', 'هذا الأسبوع', 'هذا الشهر', 'سابقاً'];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupOrder.length,
            itemBuilder: (context, index) {
              final group = groupOrder[index];
              if (!grouped.containsKey(group)) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      group,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  ...grouped[group]!.map((i) => _ImpactCard(impact: i)),
                ],
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

class _ImpactCard extends StatelessWidget {
  final DailyImpact impact;
  const _ImpactCard({required this.impact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emotionEmoji[impact.emotion] ?? '🌟', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purpleSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${categoryEmoji[impact.category] ?? ''} ${impact.category}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(impact.date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              impact.patientDescription,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              impact.impactDescription,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => context.read<ImpactProvider>().deleteImpact(impact.id!),
                  child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/skincare_routine.dart';
import '../providers/skincare_provider.dart';

class SkincareScreen extends StatefulWidget {
  const SkincareScreen({super.key});

  @override
  State<SkincareScreen> createState() => _SkincareScreenState();
}

class _SkincareScreenState extends State<SkincareScreen> {
  final _categoryColors = {
    'منظف': Color(0xFFE8F5E9),
    'تونر': Color(0xFFE3F2FD),
    'سيروم': Color(0xFFFCE4EC),
    'مرطب': Color(0xFFFFF3E0),
    'واقي شمس': Color(0xFFFFF8E1),
    'ماسك': Color(0xFFF3E5F5),
  };

  final _categoryEmojis = {
    'منظف': '🧼',
    'تونر': '💧',
    'سيروم': '✨',
    'مرطب': '🧴',
    'واقي شمس': '☀️',
    'ماسك': '🧖',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkincareProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧴 روتين العناية'),
        centerTitle: true,
      ),
      body: Consumer<SkincareProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final morning = provider.morningItems;
          final evening = provider.eveningItems;
          final progress = provider.totalCount > 0 ? provider.doneCount / provider.totalCount : 0.0;

          return RefreshIndicator(
            onRefresh: provider.loadToday,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressBar(progress, provider),
                  const SizedBox(height: 20),
                  _buildSection('☀️ صباح', morning, provider),
                  const SizedBox(height: 16),
                  _buildSection('🌙 مساء', evening, provider),
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

  Widget _buildProgressBar(double progress, SkincareProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🍃', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'تم ${provider.doneCount} من ${provider.totalCount}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<SkincareRoutine> items, SkincareProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ...items.map((item) => _buildRoutineItem(item, provider)),
        ],
      ),
    );
  }

  Widget _buildRoutineItem(SkincareRoutine item, SkincareProvider provider) {
    final bgColor = _categoryColors[item.category] ?? AppColors.blueSoft;
    final emoji = _categoryEmojis[item.category] ?? '✨';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: item.isDone ? bgColor.withValues(alpha: 0.5) : bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        value: item.isDone,
        onChanged: (_) => provider.toggleDone(item.id!),
        title: Text(
          '$emoji ${item.productName}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.isDone ? TextDecoration.lineThrough : null,
            color: item.isDone ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        subtitle: item.notes.isNotEmpty
            ? Text(item.notes, style: const TextStyle(fontSize: 12))
            : null,
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.category,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedCat = 'منظف';
    String selectedTime = 'صباح';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة منتج جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['منظف', 'تونر', 'سيروم', 'مرطب', 'واقي شمس', 'ماسك']
                      .map((c) => DropdownMenuItem(value: c, child: Text('${_categoryEmojis[c] ?? ''} $c')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCat = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedTime,
                  decoration: const InputDecoration(labelText: 'الوقت', border: OutlineInputBorder()),
                  items: ['صباح', 'مساء', 'صباح ومساء']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedTime = v!),
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
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<SkincareProvider>().addItem(SkincareRoutine(
                  productName: nameCtrl.text.trim(),
                  category: selectedCat,
                  time: selectedTime,
                  date: DateTime.now(),
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

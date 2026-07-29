import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/cme_hour.dart';
import '../providers/cme_provider.dart';

class CmeScreen extends StatefulWidget {
  const CmeScreen({super.key});

  @override
  State<CmeScreen> createState() => _CmeScreenState();
}

class _CmeScreenState extends State<CmeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CmeProvider>().loadCmeHours();
    });
  }

  void _showDialog() {
    final titleCtrl = TextEditingController();
    final hoursCtrl = TextEditingController();
    final providerCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String type = 'مؤتمر';
    String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('إضافة ساعة تعليم طبي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: hoursCtrl, decoration: const InputDecoration(labelText: 'عدد الساعات', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                  items: ['مؤتمر', 'دورة', 'محاضرة', 'ورشة', 'دراسة'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDState(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: providerCtrl, decoration: const InputDecoration(labelText: 'الجهة المقدمة', border: OutlineInputBorder()), textAlign: TextAlign.right),
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
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 3, textAlign: TextAlign.right),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || hoursCtrl.text.isEmpty) return;
                final c = CmeHour(
                  title: titleCtrl.text,
                  hours: double.parse(hoursCtrl.text),
                  type: type,
                  provider: providerCtrl.text,
                  date: dateStr,
                  notes: notesCtrl.text,
                );
                context.read<CmeProvider>().addCmeHour(c);
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  static const _typeColors = {
    'مؤتمر': AppColors.blueSoft,
    'دورة': AppColors.greenSoft,
    'محاضرة': AppColors.purpleSoft,
    'ورشة': AppColors.orangeSoft,
    'دراسة': AppColors.pinkSoft,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 ساعات التعليم الطبي')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<CmeProvider>(
        builder: (context, provider, child) {
          if (provider.cmeHours.isEmpty) {
            return const Center(
              child: Text('لا توجد ساعات تعليم طبي', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('إجمالي ساعات التعليم الطبي', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('${provider.totalHours}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...provider.cmeHours.map((c) => Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deleteCmeHour(c.id!),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(c.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          Text('${c.hours} س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(c.type, _typeColors[c.type] ?? AppColors.orangeSoft),
                          if (c.provider.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(c.provider, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                          const Spacer(),
                          Text(c.date, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                      if (c.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(c.notes, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

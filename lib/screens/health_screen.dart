import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadRecords();
    });
  }

  void _showDialog() {
    final systolicCtrl = TextEditingController();
    final diastolicCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final heartRateCtrl = TextEditingController();
    final sleepCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('إضافة سجل صحي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Row(
                  children: [
                    Expanded(child: TextField(controller: systolicCtrl, decoration: const InputDecoration(labelText: 'الانقباضي', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: diastolicCtrl, decoration: const InputDecoration(labelText: 'الانبساطي', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'الوزن (كجم)', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: heartRateCtrl, decoration: const InputDecoration(labelText: 'معدل ضربات القلب', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: sleepCtrl, decoration: const InputDecoration(labelText: 'ساعات النوم', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 3, textAlign: TextAlign.right),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                final r = HealthRecord(
                  date: dateStr,
                  systolic: systolicCtrl.text.isNotEmpty ? int.tryParse(systolicCtrl.text) : null,
                  diastolic: diastolicCtrl.text.isNotEmpty ? int.tryParse(diastolicCtrl.text) : null,
                  weight: weightCtrl.text.isNotEmpty ? double.tryParse(weightCtrl.text) : null,
                  heartRate: heartRateCtrl.text.isNotEmpty ? int.tryParse(heartRateCtrl.text) : null,
                  sleepHours: sleepCtrl.text.isNotEmpty ? int.tryParse(sleepCtrl.text) : null,
                  notes: notesCtrl.text,
                );
                context.read<HealthProvider>().addRecord(r);
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
      appBar: AppBar(title: const Text('❤️ السجل الصحي')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          if (provider.records.isEmpty) {
            return const Center(
              child: Text('لا توجد سجلات صحية', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.records.length,
            itemBuilder: (context, index) {
              final r = provider.records[index];
              return Dismissible(
                key: ValueKey(r.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deleteRecord(r.id!),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (r.systolic != null && r.diastolic != null)
                            _healthItem(Icons.favorite, 'ضغط الدم', '${r.systolic}/${r.diastolic}', AppColors.accent),
                          if (r.weight != null)
                            _healthItem(Icons.monitor_weight, 'الوزن', '${r.weight} كجم', AppColors.success),
                          if (r.heartRate != null)
                            _healthItem(Icons.favorite_border, 'النبض', '${r.heartRate} نبضة/د', AppColors.primary),
                          if (r.sleepHours != null)
                            _healthItem(Icons.bedtime, 'النوم', '${r.sleepHours} س', AppColors.purpleSoft),
                        ],
                      ),
                      if (r.notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(r.notes, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _healthItem(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

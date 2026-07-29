import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  void _showDialog({Medicine? med}) {
    final nameCtrl = TextEditingController(text: med?.name ?? '');
    final dosageCtrl = TextEditingController(text: med?.dosage ?? '');
    final notesCtrl = TextEditingController(text: med?.notes ?? '');
    String frequency = med?.frequency ?? 'مرة';
    String time = med?.time ?? 'صباح';
    final isEdit = med != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(isEdit ? 'تعديل دواء' : 'إضافة دواء'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الدواء', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'الجرعة (مثال: 500mg)', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: frequency,
                  decoration: const InputDecoration(labelText: 'التكرار', border: OutlineInputBorder()),
                  items: ['مرة', 'مرتين', 'ثلاث مرات', 'حسب الحاجة'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) => setDState(() => frequency = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: time,
                  decoration: const InputDecoration(labelText: 'الوقت', border: OutlineInputBorder()),
                  items: ['صباح', 'مساء', 'قبل النوم'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDState(() => time = v!),
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
                if (nameCtrl.text.isEmpty || dosageCtrl.text.isEmpty) return;
                final m = Medicine(
                  id: med?.id,
                  name: nameCtrl.text,
                  dosage: dosageCtrl.text,
                  frequency: frequency,
                  time: time,
                  notes: notesCtrl.text,
                );
                if (isEdit) {
                  context.read<MedicineProvider>().updateMedicine(m);
                } else {
                  context.read<MedicineProvider>().addMedicine(m);
                }
                Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'تحديث' : 'إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💊 الأدوية')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          if (provider.medicines.isEmpty) {
            return const Center(
              child: Text('لا توجد أدوية', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.medicines.length,
            itemBuilder: (context, index) {
              final m = provider.medicines[index];
              return Dismissible(
                key: ValueKey(m.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deleteMedicine(m.id!),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(m.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: m.isActive ? AppColors.textPrimary : AppColors.textLight)),
                                ),
                                GestureDetector(
                                  onTap: () => provider.updateMedicine(Medicine(id: m.id, name: m.name, dosage: m.dosage, frequency: m.frequency, time: m.time, notes: m.notes, isActive: !m.isActive)),
                                  child: Icon(
                                    m.isActive ? Icons.toggle_on : Icons.toggle_off_outlined,
                                    color: m.isActive ? AppColors.success : AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTag(m.dosage, AppColors.blueSoft),
                                const SizedBox(width: 8),
                                _buildTag(m.frequency, AppColors.purpleSoft),
                                const SizedBox(width: 8),
                                _buildTag(m.time, AppColors.orangeSoft),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

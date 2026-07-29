import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/shift.dart';
import '../providers/shift_provider.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().loadShifts();
    });
  }

  static const shiftTypes = ['صباحي', 'مسائي', 'ليلي', 'إجازة'];

  static const shiftColors = {
    'صباحي': AppColors.orangeSoft,
    'مسائي': AppColors.purpleSoft,
    'ليلي': AppColors.blueSoft,
    'إجازة': AppColors.greenSoft,
  };

  static const shiftIcons = {
    'صباحي': Icons.wb_sunny_outlined,
    'مسائي': Icons.nights_stay_outlined,
    'ليلي': Icons.nightlight_round,
    'إجازة': Icons.beach_access,
  };

  void _showAddShiftDialog() {
    DateTime selectedDate = DateTime.now();
    String selectedType = 'صباحي';
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('إضافة شفت'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(DateFormat('yyyy/MM/dd', 'ar').format(selectedDate)),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setDState(() => selectedDate = picked);
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'نوع الشفت', border: OutlineInputBorder()),
                items: shiftTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setDState(() => selectedType = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()),
                maxLines: 3,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                context.read<ShiftProvider>().addShift(Shift(
                  date: DateFormat('yyyy-MM-dd').format(selectedDate),
                  shiftType: selectedType,
                  notes: notesCtrl.text,
                ));
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
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('⏰ الشفتات')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddShiftDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ShiftProvider>(
        builder: (context, provider, child) {
          if (provider.shifts.isEmpty) {
            return const Center(
              child: Text('لا توجد شفتات بعد', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          final grouped = <String, List<Shift>>{};
          for (final shift in provider.shifts) {
            final dt = DateTime.parse(shift.date);
            final monthKey = DateFormat('MMMM yyyy', 'ar').format(dt);
            grouped.putIfAbsent(monthKey, () => []);
            grouped[monthKey]!.add(shift);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  ...entry.value.map((shift) {
                    final isToday = shift.date == todayStr;
                    final color = shiftColors[shift.shiftType] ?? AppColors.blueSoft;
                    final icon = shiftIcons[shift.shiftType] ?? Icons.work_outline;
                    final dt = DateTime.parse(shift.date);
                    return Dismissible(
                      key: ValueKey(shift.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => provider.deleteShift(shift.id!),
                      child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: isToday ? color : null,
                        child: Row(
                          children: [
                            Icon(icon, color: AppColors.textPrimary, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(shift.shiftType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      if (isToday) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                                          child: const Text('اليوم', style: TextStyle(color: Colors.white, fontSize: 10)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(DateFormat('EEEE, d MMMM', 'ar').format(dt), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  if (shift.notes.isNotEmpty) Text(shift.notes, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

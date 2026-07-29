import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAppointments();
    });
  }

  void _showDialog({Appointment? a}) {
    final nameCtrl = TextEditingController(text: a?.patientName ?? '');
    final notesCtrl = TextEditingController(text: a?.notes ?? '');
    String dateStr = a?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    String timeStr = a?.time ?? DateFormat('HH:mm').format(DateTime.now());
    String type = a?.type ?? 'كشف';
    String status = a?.status ?? 'قادم';
    final isEdit = a != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(isEdit ? 'تعديل موعد' : 'إضافة موعد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المريض', border: OutlineInputBorder()), textAlign: TextAlign.right),
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
                GestureDetector(
                  onTap: () async {
                    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(timeStr)));
                    if (t != null) setDState(() => timeStr = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                  },
                  child: AbsorbPointer(
                    child: TextField(decoration: InputDecoration(labelText: 'الوقت', border: const OutlineInputBorder(), hintText: timeStr), textAlign: TextAlign.right),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                  items: ['كشف', 'متابعة', 'إجراء'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDState(() => type = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'الحالة', border: OutlineInputBorder()),
                  items: ['قادم', 'تم', 'ملغي'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setDState(() => status = v!),
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
                if (nameCtrl.text.isEmpty) return;
                final appointment = Appointment(
                  id: a?.id,
                  patientName: nameCtrl.text,
                  date: dateStr,
                  time: timeStr,
                  type: type,
                  notes: notesCtrl.text,
                  status: status,
                );
                if (isEdit) {
                  context.read<AppointmentProvider>().updateAppointment(appointment);
                } else {
                  context.read<AppointmentProvider>().addAppointment(appointment);
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

  Color _statusColor(String status) {
    switch (status) {
      case 'قادم': return AppColors.blueSoft;
      case 'تم': return AppColors.greenSoft;
      case 'ملغي': return AppColors.pinkSoft;
      default: return AppColors.orangeSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📅 المواعيد')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.appointments.isEmpty) {
            return const Center(
              child: Text('لا توجد مواعيد', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          final grouped = <String, List<Appointment>>{};
          for (final a in provider.appointments) {
            grouped.putIfAbsent(a.date, () => []).add(a);
          }
          final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, i) {
              final date = sortedDates[i];
              final items = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                  ...items.map((a) => Dismissible(
                    key: ValueKey(a.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => provider.deleteAppointment(a.id!),
                    child: GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(a.patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              GestureDetector(
                                onTap: () => _showDialog(a: a),
                                child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(a.time, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(width: 16),
                              _buildTag(a.type, AppColors.purpleSoft),
                              const SizedBox(width: 8),
                              _buildTag(a.status, _statusColor(a.status)),
                            ],
                          ),
                          if (a.notes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(a.notes, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                  )),
                ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  void _showPatientDialog({Patient? patient}) {
    final nameCtrl = TextEditingController(text: patient?.name ?? '');
    final ageCtrl = TextEditingController(text: patient?.age.toString() ?? '');
    final diagnosisCtrl = TextEditingController(text: patient?.diagnosis ?? '');
    final notesCtrl = TextEditingController(text: patient?.notes ?? '');
    String gender = patient?.gender ?? 'أنثى';
    final isEdit = patient != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(isEdit ? 'تعديل مريض' : 'إضافة مريض'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'العمر', border: OutlineInputBorder()), keyboardType: TextInputType.number, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: const InputDecoration(labelText: 'الجنس', border: OutlineInputBorder()),
                  items: ['ذكر', 'أنثى'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setDState(() => gender = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: diagnosisCtrl, decoration: const InputDecoration(labelText: 'التشخيص', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 3, textAlign: TextAlign.right),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || ageCtrl.text.isEmpty || diagnosisCtrl.text.isEmpty) return;
                final p = Patient(
                  id: patient?.id,
                  name: nameCtrl.text,
                  age: int.parse(ageCtrl.text),
                  gender: gender,
                  diagnosis: diagnosisCtrl.text,
                  notes: notesCtrl.text,
                );
                if (isEdit) {
                  context.read<PatientProvider>().updatePatient(p);
                } else {
                  context.read<PatientProvider>().addPatient(p);
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
      appBar: AppBar(title: const Text('📋 المرضى')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPatientDialog(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, child) {
          if (provider.patients.isEmpty) {
            return const Center(
              child: Text('لا يوجد مرضى بعد', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.patients.length,
            itemBuilder: (context, index) {
              final patient = provider.patients[index];
              return Dismissible(
                key: ValueKey(patient.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deletePatient(patient.id!),
                child: _PatientCard(
                  patient: patient,
                  onEdit: () => _showPatientDialog(patient: patient),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatefulWidget {
  final Patient patient;
  final VoidCallback onEdit;
  const _PatientCard({required this.patient, required this.onEdit});

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                GestureDetector(
                  onTap: widget.onEdit,
                  child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag('${p.age} سنة', AppColors.blueSoft),
                const SizedBox(width: 8),
                _buildTag(p.gender, AppColors.purpleSoft),
                const SizedBox(width: 8),
                _buildTag(p.diagnosis, AppColors.orangeSoft),
              ],
            ),
            if (_expanded && p.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              Text(p.notes, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ],
        ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/medical_note.dart';
import '../providers/medical_note_provider.dart';

class MedicalNotesScreen extends StatefulWidget {
  const MedicalNotesScreen({super.key});

  @override
  State<MedicalNotesScreen> createState() => _MedicalNotesScreenState();
}

class _MedicalNotesScreenState extends State<MedicalNotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalNoteProvider>().loadNotes();
    });
  }

  static const _categoryColors = {
    'محاضرة': AppColors.blueSoft,
    'مؤتمر': AppColors.purpleSoft,
    'بحث': AppColors.greenSoft,
    'أخرى': AppColors.orangeSoft,
  };

  void _showDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final sourceCtrl = TextEditingController();
    String category = 'محاضرة';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('إضافة ملاحظة طبية'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'المحتوى', border: OutlineInputBorder()), maxLines: 5, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: _categoryColors.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDState(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: sourceCtrl, decoration: const InputDecoration(labelText: 'المصدر', border: OutlineInputBorder()), textAlign: TextAlign.right),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
                final n = MedicalNote(
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  category: category,
                  source: sourceCtrl.text,
                );
                context.read<MedicalNoteProvider>().addNote(n);
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
      appBar: AppBar(title: const Text('📝 ملاحظات طبية')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<MedicalNoteProvider>(
        builder: (context, provider, child) {
          if (provider.notes.isEmpty) {
            return const Center(
              child: Text('لا توجد ملاحظات طبية', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notes.length,
            itemBuilder: (context, index) {
              final n = provider.notes[index];
              final catColor = _categoryColors[n.category] ?? AppColors.orangeSoft;
              return _NoteCard(note: n, catColor: catColor, onDelete: () => provider.deleteNote(n.id!));
            },
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatefulWidget {
  final MedicalNote note;
  final Color catColor;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.catColor, required this.onDelete});

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.note;
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
                Expanded(child: Text(n.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag(n.category, widget.catColor),
                if (n.source.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(n.source, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(),
              Text(n.content, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
              const SizedBox(height: 8),
              Text(n.createdAt.substring(0, 10), style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
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

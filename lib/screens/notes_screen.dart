import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
    });
  }

  void _showNoteDialog({Note? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController =
        TextEditingController(text: existing?.content ?? '');
    String category = existing?.category ?? 'عام';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing != null ? 'تعديل ملاحظة' : 'ملاحظة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'العنوان (اختياري)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'اكتبي ملاحظاتك...',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  isDense: true,
                ),
                items: ['عام', 'طبي', 'شخصي', 'أهداف', 'مواقف', 'الامتنان']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => category = v ?? 'عام',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.trim().isEmpty) return;
              final note = Note(
                id: existing?.id,
                title: titleController.text,
                content: contentController.text,
                category: category,
                createdAt: existing?.createdAt,
              );
              if (existing != null) {
                context.read<NoteProvider>().updateNote(note);
              } else {
                context.read<NoteProvider>().addNote(note);
              }
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📓 دفتر الملاحظات')),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.notes;
          if (notes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📓', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد ملاحظات بعد',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اضغطي على + لإضافة ملاحظة جديدة',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Text('📝 جميع الملاحظات',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${notes.length} ملاحظة',
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              final note = notes[index - 1];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: ListTile(
                    title: Text(
                      note.title.isNotEmpty ? note.title : 'بدون عنوان',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.content.length > 80
                              ? '${note.content.substring(0, 80)}...'
                              : note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.purpleSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                note.category,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MM/dd', 'ar').format(note.createdAt),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _showNoteDialog(existing: note),
                          child: const Icon(Icons.edit_outlined,
                              size: 20, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              noteProvider.deleteNote(note.id!),
                          child: const Icon(Icons.delete_outline,
                              size: 20, color: AppColors.error),
                        ),
                      ],
                    ),
                    onTap: () => _showNoteDialog(existing: note),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

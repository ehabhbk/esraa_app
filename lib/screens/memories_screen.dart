import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/memory_capsule.dart';
import '../providers/memory_provider.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryProvider>().loadMemories();
    });
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    File? imageFile;
    final picker = ImagePicker();
    bool initialized = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (!initialized) {
            initialized = true;
          }
          return AlertDialog(
            title: const Text('🎞️ ذكريات جديدة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'العنوان', isDense: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'المحتوى'),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final source = await showModalBottomSheet<ImageSource>(
                        context: ctx,
                        builder: (_) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                                title: const Text('اختيار من المعرض'),
                                onTap: () => Navigator.pop(_, ImageSource.gallery),
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                                title: const Text('التقاط صورة'),
                                onTap: () => Navigator.pop(_, ImageSource.camera),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (source != null) {
                        final picked = await picker.pickImage(source: source, imageQuality: 85);
                        if (picked != null) {
                          imageFile = File(picked.path);
                          setDialogState(() {});
                        }
                      }
                    },
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(imageFile!, width: double.infinity, height: 150, fit: BoxFit.cover),
                          )
                        : Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Center(child: Text('➕ إضافة صورة (اختياري)', style: TextStyle(color: AppColors.textLight))),
                          ),
                  ),
                  const SizedBox(height: 12),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                  final capsule = MemoryCapsule(
                    title: titleCtrl.text,
                    content: contentCtrl.text,
                    imagePath: imageFile?.path,
                    date: DateFormat('yyyy-MM-dd', 'ar').format(selectedDate),
                  );
                  context.read<MemoryProvider>().addMemory(capsule);
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎞️ كبسولة الذكريات')),
      body: Consumer<MemoryProvider>(
        builder: (context, provider, child) {
          if (provider.memories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎞️', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد ذكريات بعد',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'أضيفي أول ذكرى لك 🌸',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            );
          }
          final grouped = <String, List<MemoryCapsule>>{};
          for (final m in provider.memories) {
            final month = m.date.substring(0, 7);
            grouped.putIfAbsent(month, () => []).add(m);
          }
          final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final items = grouped[month]!;
              final dateParts = month.split('-');
              final monthName = DateFormat('MMMM yyyy', 'ar').format(DateTime(int.parse(dateParts[0]), int.parse(dateParts[1])));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ...items.map((m) => _MemoryCard(memory: m)),
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

class _MemoryCard extends StatelessWidget {
  final MemoryCapsule memory;
  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              if (memory.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: memory.imagePath!.startsWith('assets/')
                      ? Image.asset(memory.imagePath!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: AppColors.textLight))
                      : Image.file(File(memory.imagePath!), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: AppColors.textLight)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memory.date,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memory.content.length > 60 ? '${memory.content.substring(0, 60)}...' : memory.content,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.content,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  if (memory.imagePath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: memory.imagePath!.startsWith('assets/')
                          ? Image.asset(memory.imagePath!, width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, size: 48, color: AppColors.textLight))))
                          : Image.file(File(memory.imagePath!), width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, size: 48, color: AppColors.textLight)))),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => context.read<MemoryProvider>().deleteMemory(memory.id!),
                        child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

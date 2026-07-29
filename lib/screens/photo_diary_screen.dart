import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/photo_diary.dart';
import '../providers/photodiary_provider.dart';

class PhotoDiaryScreen extends StatefulWidget {
  const PhotoDiaryScreen({super.key});

  @override
  State<PhotoDiaryScreen> createState() => _PhotoDiaryScreenState();
}

class _PhotoDiaryScreenState extends State<PhotoDiaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoDiaryProvider>().loadEntries();
    });
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _AddPhotoPage()),
    );
  }

  void _viewFullScreen(PhotoDiary entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(entry.date, style: const TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: entry.imagePath.startsWith('assets/')
                      ? Image.asset(entry.imagePath, width: double.infinity, height: 300, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.white54))
                      : Image.file(File(entry.imagePath), width: double.infinity, height: 300, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.white54)),
                ),
                if (entry.caption.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      entry.caption,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📸 يوميات بالصور')),
      body: Consumer<PhotoDiaryProvider>(
        builder: (context, provider, child) {
          if (provider.entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📸', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('لا توجد صور بعد', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('أضيفي أول صورة لك 🌸', style: TextStyle(color: AppColors.textLight)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              return GestureDetector(
                onTap: () => _viewFullScreen(entry),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: entry.imagePath.startsWith('assets/')
                          ? Image.asset(entry.imagePath, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, size: 40, color: AppColors.textLight))))
                          : Image.file(File(entry.imagePath), width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, size: 40, color: AppColors.textLight)))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.caption.isNotEmpty)
                              Text(
                                entry.caption.length > 30 ? '${entry.caption.substring(0, 30)}...' : entry.caption,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 2),
                            Text(
                              entry.date,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AddPhotoPage extends StatefulWidget {
  const _AddPhotoPage();

  @override
  State<_AddPhotoPage> createState() => _AddPhotoPageState();
}

class _AddPhotoPageState extends State<_AddPhotoPage> {
  File? _imageFile;
  final _captionCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('اختيار من المعرض'),
              onTap: () { Navigator.pop(ctx); _pickFromGallery(); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقاط صورة'),
              onTap: () { Navigator.pop(ctx); _takePhoto(); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📸 إضافة صورة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: const Center(child: Icon(Icons.broken_image, size: 48, color: AppColors.textLight)),
                              ),
                            ),
                          )
                        : Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 64, color: AppColors.textLight),
                                  SizedBox(height: 8),
                                  Text('اضغطي لاختيار صورة', style: TextStyle(color: AppColors.textLight)),
                                ],
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.image),
                      label: const Text('تغيير الصورة'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _captionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'التعليق (اختياري)'),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'التاريخ', isDense: true),
                      child: Text(DateFormat('yyyy-MM-dd', 'ar').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_imageFile == null) return;
                        final entry = PhotoDiary(
                          imagePath: _imageFile!.path,
                          caption: _captionCtrl.text,
                          date: DateFormat('yyyy-MM-dd', 'ar').format(_selectedDate),
                        );
                        context.read<PhotoDiaryProvider>().addEntry(entry);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('حفظ', style: TextStyle(fontSize: 16)),
                    ),
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

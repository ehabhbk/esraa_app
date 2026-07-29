import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/my_look.dart';
import '../models/wardrobe_item.dart';
import '../providers/look_provider.dart';
import '../providers/wardrobe_provider.dart';

class LooksScreen extends StatefulWidget {
  const LooksScreen({super.key});

  @override
  State<LooksScreen> createState() => _LooksScreenState();
}

class _LooksScreenState extends State<LooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LookProvider>().loadLooks();
      context.read<WardrobeProvider>().loadItems();
    });
  }

  List<MyLook> _recentLooks(List<MyLook> looks) {
    final now = DateTime.now();
    return looks.where((l) {
      final diff = now.difference(l.date).inDays;
      return diff >= 1 && diff <= 4;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎀 إطلالاتي'), centerTitle: true),
      body: Consumer2<LookProvider, WardrobeProvider>(
        builder: (context, lookProv, wardrobeProv, child) {
          if (lookProv.isLoading) return const Center(child: CircularProgressIndicator());
          if (lookProv.looks.isEmpty) {
            return const Center(child: Text('لا توجد إطلالات بعد 🌸', style: TextStyle(color: AppColors.textSecondary)));
          }
          final recent = _recentLooks(lookProv.looks);
          return RefreshIndicator(
            onRefresh: lookProv.loadLooks,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (recent.isNotEmpty) ...[
                  _buildRecentLooksSection(recent, wardrobeProv.items),
                  const SizedBox(height: 16),
                ],
                ...lookProv.looks.map((look) => _buildLookCard(look, wardrobeProv.items, lookProv)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRecentLooksSection(List<MyLook> looks, List<WardrobeItem> wardrobe) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔄', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('إطلالات آخر 4 أيام', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${looks.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ...looks.map((look) {
            final dateStr = DateFormat('EEEE', 'ar').format(look.date);
            final items = _getWardrobeItems(look, wardrobe);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text('📅', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      if (look.description.isNotEmpty) Text(look.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      if (items.isNotEmpty) Text(items.map((i) => i.name).join('، '), style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLookCard(MyLook look, List<WardrobeItem> wardrobe, LookProvider provider) {
    final dateStr = DateFormat('EEEE, d MMMM y', 'ar').format(look.date);
    final items = _getWardrobeItems(look, wardrobe);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('حذف الإطلالة'),
                      content: const Text('هل تريد حذف هذه الإطلالة؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                        ElevatedButton(
                          onPressed: () {
                            provider.deleteLook(look.id!);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('حذف', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (look.imagePath != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: look.imagePath!.startsWith('assets/')
                  ? Image.asset(look.imagePath!, width: double.infinity, height: 200, fit: BoxFit.cover)
                  : Image.file(File(look.imagePath!), width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
          ],
          if (look.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(look.description, style: const TextStyle(fontSize: 14)),
          ],
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 4,
              children: items.map((i) => _buildWardrobeTag(i)).toList(),
            ),
          ],
          if (look.makeupNotes.isNotEmpty || look.hairStyle.isNotEmpty || look.accessories.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 4,
              children: [
                if (look.makeupNotes.isNotEmpty) _buildTag('💄 ${look.makeupNotes}'),
                if (look.hairStyle.isNotEmpty) _buildTag('💇 ${look.hairStyle}'),
                if (look.accessories.isNotEmpty) _buildTag('💍 ${look.accessories}'),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (i) => Icon(i < look.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)),
            ],
          ),
        ],
      ),
    );
  }

  List<WardrobeItem> _getWardrobeItems(MyLook look, List<WardrobeItem> wardrobe) {
    if (look.wardrobeItemIds.isEmpty) return [];
    final ids = look.wardrobeItemIds.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
    return wardrobe.where((w) => ids.contains(w.id)).toList();
  }

  Widget _buildWardrobeTag(WardrobeItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('${item.name} (${item.category})', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _AddLookPage()));
  }
}

class _AddLookPage extends StatefulWidget {
  const _AddLookPage();
  @override
  State<_AddLookPage> createState() => _AddLookPageState();
}

class _AddLookPageState extends State<_AddLookPage> {
  final _descCtrl = TextEditingController();
  final _makeupCtrl = TextEditingController();
  final _hairCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _rating = 3;
  File? _imageFile;
  final _picker = ImagePicker();
  final Map<String, int> _selectedByCategory = {};
  final Set<int> _selectedAccessories = {};
  static const _categoryOrder = ['فستان', 'بلوزة', 'تيشيرت', 'بنطلون', 'جاكيت', 'عباءة', 'حذاء', 'اكسسوار'];
  static const _categoryEmoji = {
    'فستان': '👗', 'بلوزة': '👚', 'تيشيرت': '👕', 'بنطلون': '👖',
    'جاكيت': '🧥', 'عباءة': '🧣', 'حذاء': '👟', 'اكسسوار': '💎',
  };

  Widget _buildWardrobeSection(List<WardrobeItem> items) {
    final grouped = <String, List<WardrobeItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final displayed = _categoryOrder.where((c) => grouped.containsKey(c)).toList();
    final others = grouped.keys.where((c) => !_categoryOrder.contains(c)).toList();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ماذا سترتدين؟', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('لا توجد قطع في الخزانة', style: TextStyle(color: AppColors.textLight, fontSize: 12))
          else ...[
            for (final cat in [...displayed, ...others]) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(_categoryEmoji[cat] ?? '📁', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    const SizedBox(width: 6),
                    Text('(اختيار واحد)', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    if (cat == 'اكسسوار') Text('(اختيار متعدد)', style: const TextStyle(fontSize: 10, color: AppColors.warning)),
                  ],
                ),
              ),
              for (final item in grouped[cat]!) ...[
                if (cat == 'اكسسوار')
                  CheckboxListTile(
                    value: _selectedAccessories.contains(item.id),
                    onChanged: (v) {
                      setState(() { if (v == true) _selectedAccessories.add(item.id!); else _selectedAccessories.remove(item.id!); });
                    },
                    title: Text(item.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(item.color, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    dense: true, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
                  )
                else
                  ListTile(
                    leading: Icon(
                      _selectedByCategory[cat] == item.id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: AppColors.primary, size: 22,
                    ),
                    title: Text(item.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(item.color, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    dense: true, contentPadding: EdgeInsets.zero,
                    onTap: () => setState(() => _selectedByCategory[cat] = item.id!),
                  ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _makeupCtrl.dispose();
    _hairCtrl.dispose();
    _accCtrl.dispose();
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
    final wardrobe = context.watch<WardrobeProvider>().items;
    return Scaffold(
      appBar: AppBar(title: const Text('🎀 إضافة إطلالة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, width: double.infinity, height: 200, fit: BoxFit.cover),
                    )
                  : Container(
                      height: 150,
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                      child: const Center(child: Text('➕ إضافة صورة (اختياري)', style: TextStyle(color: AppColors.textLight))),
                    ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'التاريخ', isDense: true),
                      child: Text(DateFormat('yyyy/MM/dd', 'ar').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'وصف الإطلالة', border: OutlineInputBorder()), maxLines: 2),
                  const SizedBox(height: 12),
                  TextField(controller: _makeupCtrl, decoration: const InputDecoration(labelText: 'ملاحظات المكياج', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: _hairCtrl, decoration: const InputDecoration(labelText: 'تصفيفة الشعر', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: _accCtrl, decoration: const InputDecoration(labelText: 'الإكسسوارات', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('التقييم: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      ...List.generate(5, (i) => IconButton(
                        onPressed: () => setState(() => _rating = i + 1),
                        icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildWardrobeSection(wardrobe),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<LookProvider>().addLook(MyLook(
                    date: _selectedDate,
                    description: _descCtrl.text.trim(),
                    makeupNotes: _makeupCtrl.text.trim(),
                    hairStyle: _hairCtrl.text.trim(),
                    accessories: _accCtrl.text.trim(),
                    rating: _rating,
                    imagePath: _imageFile?.path,
                    wardrobeItemIds: {..._selectedByCategory.values, ..._selectedAccessories}.join(','),
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('💾 حفظ الإطلالة', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
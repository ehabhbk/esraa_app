import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  String _selectedCategory = 'الكل';

  final _categories = ['الكل', 'فستان', 'بلوزة', 'تيشيرت', 'بنطلون', 'جاكيت', 'عباءة', 'حذاء', 'إكسسوار'];

  final _categoryEmojis = {
    'فستان': '👗',
    'بلوزة': '👚',
    'تيشيرت': '👕',
    'بنطلون': '👖',
    'جاكيت': '🧥',
    'عباءة': '🧕',
    'حذاء': '👠',
    'إكسسوار': '💍',
  };

  final _colorOptions = [
    'أحمر', 'وردي', 'برتقالي', 'أصفر', 'أخضر', 'زيتي', 'أزرق', 'كحلي', 'نيلي', 'بنفسجي', 'موف',
    'أسود', 'أبيض', 'رمادي', 'فضي', 'بيج', 'سكري', 'بني', 'ذهبي', 'خمري', 'عسلي', 'فيروزي', 'لافندر',
  ];

  List<WardrobeItem> _filtered(List<WardrobeItem> items) {
    if (_selectedCategory == 'الكل') return items;
    return items.where((i) => i.category == _selectedCategory).toList();
  }

  Color _parseColor(String colorName) {
    switch (colorName) {
      case 'أحمر': return Colors.red;
      case 'وردي': return Colors.pink;
      case 'برتقالي': return Colors.orange;
      case 'أصفر': return Colors.yellow;
      case 'أخضر': return Colors.green;
      case 'زيتي': return Color(0xFF4A5D23);
      case 'أزرق': return Colors.blue;
      case 'كحلي': return Color(0xFF1B2A4A);
      case 'نيلي': return Colors.indigo;
      case 'بنفسجي': return Colors.purple;
      case 'موف': return Color(0xFF8B6FA0);
      case 'أسود': return Colors.black;
      case 'أبيض': return Colors.grey[200]!;
      case 'رمادي': return Colors.grey;
      case 'فضي': return Colors.grey[400]!;
      case 'بيج': return Color(0xFFF5E6CC);
      case 'سكري': return Color(0xFFFFF8E7);
      case 'بني': return Colors.brown;
      case 'ذهبي': return Colors.amber;
      case 'خمري': return Color(0xFF800020);
      case 'عسلي': return Color(0xFFC68E17);
      case 'فيروزي': return Color(0xFF40E0D0);
      case 'لافندر': return Color(0xFFE6E6FA);
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👗 خزانتي'),
        centerTitle: true,
      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, provider, child) {
          final items = _filtered(provider.items);
          return Column(
            children: [
              _buildFilterTabs(),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('لا توجد قطع في الخزانة 🌸', style: TextStyle(color: AppColors.textSecondary)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _buildItemCard(items[index], provider),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.glassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  '${_categoryEmojis[cat] ?? ''} $cat',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(WardrobeItem item, WardrobeProvider provider) {
    final emoji = _categoryEmojis[item.category] ?? '👗';
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(item.color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.season,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => provider.toggleFavorite(item.id!),
            child: Icon(
              item.isFavorite ? Icons.star : Icons.star_border,
              color: item.isFavorite ? Colors.amber : AppColors.textLight,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    String selectedCat = 'فستان';
    String selectedSeason = 'كل المواسم';
    bool isFav = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة قطعة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم القطعة', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['فستان', 'بلوزة', 'تيشيرت', 'بنطلون', 'جاكيت', 'عباءة', 'حذاء', 'إكسسوار']
                      .map((c) => DropdownMenuItem(value: c, child: Text('${_categoryEmojis[c] ?? ''} $c')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCat = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSeason,
                  decoration: const InputDecoration(labelText: 'الموسم', border: OutlineInputBorder()),
                  items: ['صيفي', 'شتوي', 'كل المواسم']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedSeason = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _colorOptions.first,
                  decoration: const InputDecoration(labelText: 'اللون', border: OutlineInputBorder()),
                  items: _colorOptions
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _parseColor(c),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[400]!),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(c),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => colorCtrl.text = v!),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: isFav,
                  onChanged: (v) => setDialogState(() => isFav = v!),
                  title: const Text('مفضلة'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final color = colorCtrl.text.isEmpty ? 'أبيض' : colorCtrl.text;
                context.read<WardrobeProvider>().addItem(WardrobeItem(
                  name: nameCtrl.text.trim(),
                  category: selectedCat,
                  color: color,
                  season: selectedSeason,
                  isFavorite: isFav,
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/makeup_item.dart';
import '../providers/makeup_provider.dart';

class MakeupScreen extends StatefulWidget {
  const MakeupScreen({super.key});

  @override
  State<MakeupScreen> createState() => _MakeupScreenState();
}

class _MakeupScreenState extends State<MakeupScreen> {
  String _selectedCategory = 'الكل';

  final _categories = [
    'الكل', 'أساس', 'كونسيلر', 'بودرة', 'أحمر خدود', 'أحمر شفاه', 'ظلال عيون', 'كحل', 'ماسكارا',
  ];

  final _categoryEmojis = {
    'أساس': '🧴',
    'كونسيلر': '🔆',
    'بودرة': '☁️',
    'أحمر خدود': '🌸',
    'أحمر شفاه': '💄',
    'ظلال عيون': '🎨',
    'كحل': '🖤',
    'ماسكارا': '👁️',
  };

  List<MakeupItem> _filtered(List<MakeupItem> items) {
    if (_selectedCategory == 'الكل') return items;
    return items.where((i) => i.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💄 مكياجي'),
        centerTitle: true,
      ),
      body: Consumer<MakeupProvider>(
        builder: (context, provider, child) {
          final items = _filtered(provider.items);
          return Column(
            children: [
              _buildFilterTabs(),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('لا توجد منتجات مكياج 🌸', style: TextStyle(color: AppColors.textSecondary)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
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
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(MakeupItem item, MakeupProvider provider) {
    final emoji = _categoryEmojis[item.category] ?? '💄';
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف المنتج'),
            content: Text('هل تريد حذف ${item.productName}؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  provider.deleteItem(item.id!);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('حذف', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              item.productName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.brand.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.brand, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
            if (item.shade.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(item.shade, style: TextStyle(color: AppColors.textLight, fontSize: 11)),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () => provider.toggleFavorite(item.id!),
              child: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: item.isFavorite ? AppColors.accent : AppColors.textLight,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final shadeCtrl = TextEditingController();
    String selectedCat = 'أساس';
    bool isFav = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة منتج مكياج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['أساس', 'كونسيلر', 'بودرة', 'أحمر خدود', 'أحمر شفاه', 'ظلال عيون', 'كحل', 'ماسكارا']
                      .map((c) => DropdownMenuItem(value: c, child: Text('${_categoryEmojis[c] ?? ''} $c')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCat = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: brandCtrl,
                  decoration: const InputDecoration(labelText: 'العلامة التجارية', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: shadeCtrl,
                  decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
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
                context.read<MakeupProvider>().addItem(MakeupItem(
                  productName: nameCtrl.text.trim(),
                  category: selectedCat,
                  brand: brandCtrl.text.trim(),
                  shade: shadeCtrl.text.trim(),
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

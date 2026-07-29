import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/wishlist_provider.dart';
import '../models/wishlist_item.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 لستة الرغبات'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('الكل', 0),
                const SizedBox(width: 8),
                _buildFilterChip('المطلوب', 1),
                const SizedBox(width: 8),
                _buildFilterChip('تم الشراء', 2),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WishlistProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<WishlistItem> items;
                switch (_filterIndex) {
                  case 1:
                    items = provider.wanted;
                    break;
                  case 2:
                    items = provider.purchased;
                    break;
                  default:
                    items = provider.items;
                }
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      _filterIndex == 0 ? 'لا توجد رغبات بعد 🎀' : _filterIndex == 1 ? 'كل الرغبات متحققة 🎉' : 'لم يتم شراء شيء بعد',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(item, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final selected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'ملابس': return '👗';
      case 'إلكترونيات': return '📱';
      case 'هدية': return '🎁';
      case 'سفر': return '✈️';
      case 'كتب': return '📚';
      default: return '🎀';
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'عالي': return AppColors.error;
      case 'منخفض': return AppColors.success;
      default: return AppColors.warning;
    }
  }

  Widget _buildItemCard(WishlistItem item, WishlistProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => provider.togglePurchased(item.id!),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: item.isPurchased ? AppColors.success : AppColors.textLight),
                  color: item.isPurchased ? AppColors.success : Colors.transparent,
                ),
                child: item.isPurchased ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(_categoryEmoji(item.category), style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                      color: item.isPurchased ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                  if (item.price != null)
                    Text('${item.price!.toStringAsFixed(0)} ر.س', style: TextStyle(color: item.isPurchased ? AppColors.textLight : AppColors.primary, fontSize: 13)),
                  if (item.notes.isNotEmpty)
                    Text(item.notes, style: TextStyle(color: AppColors.textLight, fontSize: 12, decoration: item.isPurchased ? TextDecoration.lineThrough : null)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _priorityColor(item.priority).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(item.priority, style: TextStyle(fontSize: 11, color: _priorityColor(item.priority), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmDelete(context, item.id!),
              child: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String category = 'أخرى';
    String priority = 'متوسط';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة رغبة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الرغبة', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (اختياري)', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['ملابس', 'إلكترونيات', 'هدية', 'سفر', 'كتب', 'أخرى'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'الأولوية', border: OutlineInputBorder()),
                  items: ['عالي', 'متوسط', 'منخفض'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setDialogState(() => priority = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 2, textAlign: TextAlign.right),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<WishlistProvider>().addItem(WishlistItem(
                  name: nameCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text),
                  category: category,
                  notes: notesCtrl.text.trim(),
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

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الرغبة'),
        content: const Text('هل أنت متأكدة من الحذف؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              context.read<WishlistProvider>().deleteItem(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

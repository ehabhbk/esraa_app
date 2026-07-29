import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/hobby_provider.dart';
import '../models/hobby.dart';

class HobbiesScreen extends StatefulWidget {
  const HobbiesScreen({super.key});

  @override
  State<HobbiesScreen> createState() => _HobbiesScreenState();
}

class _HobbiesScreenState extends State<HobbiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HobbyProvider>().loadHobbies();
    });
  }

  final _commonEmojis = ['🎨', '🎵', '🎸', '📚', '✍️', '📷', '🎬', '🧘', '🏃‍♀️', '🚴‍♀️', '🏊‍♀️', '🧶', '🌱', '🍳', '🧹', '💃', '🎭', '🎪', '🎧', '🎹'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 هواياتي'),
        centerTitle: true,
      ),
      body: Consumer<HobbyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.hobbies.isEmpty) {
            return const Center(
              child: Text('لا توجد هوايات بعد 🎭', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.hobbies.length,
            itemBuilder: (context, index) {
              final hobby = provider.hobbies[index];
              return _buildHobbyCard(hobby, provider);
            },
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

  Widget _buildHobbyCard(Hobby hobby, HobbyProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _confirmDelete(context, hobby.id!),
                child: const Icon(Icons.delete_outline, size: 16, color: AppColors.textLight),
              ),
            ],
          ),
          Text(hobby.icon, style: TextStyle(fontSize: 40, color: hobby.isActive ? null : Colors.grey)),
          const SizedBox(height: 8),
          Text(
            hobby.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: hobby.isActive ? AppColors.textPrimary : AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(hobby.category, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          if (hobby.hoursPerWeek != null)
            Text('${hobby.hoursPerWeek} س/أسبوع', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hobby.isActive ? AppColors.greenSoft : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              boxShadow: hobby.isActive
                  ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 8)]
                  : null,
            ),
            child: GestureDetector(
              onTap: () => provider.toggleActive(hobby.id!),
              child: Text(
                hobby.isActive ? 'نشط' : 'غير نشط',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hobby.isActive ? AppColors.success : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final hoursCtrl = TextEditingController();
    String category = 'أخرى';
    String icon = '🎨';
    DateTime? startDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة هواية جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الهواية', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['فنية', 'رياضية', 'ثقافية', 'يدوية', 'موسيقية', 'أخرى'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                const Text('اختيار أيقونة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _commonEmojis.map((e) {
                      final selected = icon == e;
                      return GestureDetector(
                        onTap: () => setDialogState(() => icon = e),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withValues(alpha: 0.2) : null,
                            borderRadius: BorderRadius.circular(8),
                            border: selected ? Border.all(color: AppColors.primary) : null,
                          ),
                          child: Text(e, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setDialogState(() => startDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'تاريخ البداية (اختياري)', border: OutlineInputBorder()),
                    child: Text(startDate != null ? DateFormat('d MMMM y', 'ar').format(startDate!) : 'اختر تاريخ', textAlign: TextAlign.right),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: hoursCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ساعات في الأسبوع (اختياري)', border: OutlineInputBorder()), textAlign: TextAlign.right),
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
                context.read<HobbyProvider>().addHobby(Hobby(
                  name: nameCtrl.text.trim(),
                  category: category,
                  icon: icon,
                  startDate: startDate,
                  hoursPerWeek: int.tryParse(hoursCtrl.text),
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
        title: const Text('حذف الهواية'),
        content: const Text('هل أنت متأكدة من الحذف؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              context.read<HobbyProvider>().deleteHobby(id);
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

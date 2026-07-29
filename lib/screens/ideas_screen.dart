import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/idea_provider.dart';
import '../models/my_idea.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});

  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdeaProvider>().loadIdeas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 أفكاري'),
        centerTitle: true,
      ),
      body: Consumer<IdeaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.ideas.isEmpty) {
            return const Center(
              child: Text('لا توجد أفكار بعد 💭', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.ideas.length,
            itemBuilder: (context, index) {
              final idea = provider.ideas[index];
              return _buildIdeaCard(idea, provider);
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

  Color _statusColor(String status) {
    switch (status) {
      case 'جديد': return AppColors.blueSoft;
      case 'قيد التنفيذ': return AppColors.orangeSoft;
      case 'منفذ': return AppColors.greenSoft;
      case 'ملغي': return Colors.grey[200]!;
      default: return AppColors.blueSoft;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'جديد': return Colors.blue;
      case 'قيد التنفيذ': return Colors.orange;
      case 'منفذ': return Colors.green;
      case 'ملغي': return Colors.grey;
      default: return Colors.blue;
    }
  }

  Widget _buildIdeaCard(MyIdea idea, IdeaProvider provider) {
    final statusBg = _statusColor(idea.status);
    final statusTextColor = _statusTextColor(idea.status);
    return GestureDetector(
      onTap: () => _showProgressDialog(context, idea, provider),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purpleSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(idea.category, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _confirmDelete(context, idea.id!),
                  child: const Icon(Icons.close, size: 16, color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              idea.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                idea.content,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            if (idea.progress > 0 || idea.status == 'منفذ') ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (idea.status == 'منفذ' ? 1.0 : idea.progress / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(idea.progress >= 100 || idea.status == 'منفذ' ? AppColors.success : AppColors.primary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                idea.status == 'منفذ' ? 'مكتمل ✅' : '${idea.progress}%',
                style: TextStyle(fontSize: 10, color: idea.progress >= 100 ? AppColors.success : AppColors.textSecondary),
              ),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  idea.status,
                  style: TextStyle(fontSize: 11, color: statusTextColor, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context, MyIdea idea, IdeaProvider provider) {
    int progress = idea.progress;
    String status = idea.status;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(idea.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('نسبة التقدم: $progress%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Slider(
                value: progress.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '$progress%',
                activeColor: progress >= 100 ? AppColors.success : AppColors.primary,
                onChanged: (v) {
                  setDialogState(() {
                    progress = v.round();
                    if (progress >= 100) status = 'منفذ';
                    else if (progress > 0) status = 'قيد التنفيذ';
                    else status = 'جديد';
                  });
                },
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(progress >= 100 ? AppColors.success : AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text('الحالة: $status', style: TextStyle(color: _statusTextColor(status))),
              if (progress >= 100) const SizedBox(height: 4),
              if (progress >= 100) const Text('✅ مكتمل!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                provider.updateIdea(MyIdea(
                  id: idea.id,
                  title: idea.title,
                  content: idea.content,
                  category: idea.category,
                  status: status,
                  progress: progress,
                  createdAt: idea.createdAt,
                  updatedAt: DateTime.now(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String category = 'أخرى';
    String status = 'جديد';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة فكرة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'المحتوى', border: OutlineInputBorder()), maxLines: 4, textAlign: TextAlign.right),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: ['مشروع', 'تطوير', 'إبداع', 'حل', 'أخرى'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'الحالة', border: OutlineInputBorder()),
                  items: ['جديد', 'قيد التنفيذ', 'منفذ', 'ملغي'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                context.read<IdeaProvider>().addIdea(MyIdea(
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  category: category,
                  status: status,
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
        title: const Text('حذف الفكرة'),
        content: const Text('هل أنت متأكدة من الحذف؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              context.read<IdeaProvider>().deleteIdea(id);
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

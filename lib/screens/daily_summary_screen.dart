import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/evaluation_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/task_provider.dart';
import '../providers/look_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/place_provider.dart';
import '../providers/note_provider.dart';
import '../models/mood.dart';
import '../models/daily_evaluation.dart';
import '../models/wardrobe_item.dart';
import '../services/notification_service.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.clearPendingSummary();
      context.read<EvaluationProvider>().loadEvaluations();
      context.read<MoodProvider>().loadMoods();
      context.read<ExpenseProvider>().loadExpenses();
      context.read<TaskProvider>().loadTasks();
      context.read<LookProvider>().loadLooks();
      context.read<WardrobeProvider>().loadItems();
      context.read<PlaceProvider>().loadPlaces();
      context.read<NoteProvider>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 الملخص اليومي'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          final eval = context.watch<EvaluationProvider>();
          final mood = context.watch<MoodProvider>();
          final expense = context.watch<ExpenseProvider>();
          final task = context.watch<TaskProvider>();
          final look = context.watch<LookProvider>();
          final wardrobe = context.watch<WardrobeProvider>();
          final place = context.watch<PlaceProvider>();
          final notes = context.watch<NoteProvider>();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(today, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 16),
                _moodSection(mood.todayEntry),
                const SizedBox(height: 12),
                _evaluationSection(eval.todayEvaluation),
                const SizedBox(height: 12),
                _expenseSection(expense.todayTotal, expense.dailyLimit),
                const SizedBox(height: 12),
                _tasksSection(task.todayTasks),
                const SizedBox(height: 12),
                _lookSection(look.todayLook, wardrobe.items),
                const SizedBox(height: 12),
                _placesSection(place.todayPlaces),
                const SizedBox(height: 12),
                _notesSection(notes.todayNotes),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String emoji, String title, {Widget? trailing}) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _moodSection(MoodEntry? entry) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('💭', 'كيف تشعرين اليوم؟'),
          const SizedBox(height: 12),
          if (entry != null) ...[
            Center(
              child: Column(
                children: [
                  Text(_moodEmoji(entry.mood), style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 4),
                  Text(_moodLabel(entry.mood), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ] else
            const Center(child: Text('لم يتم تسجيل المزاج اليوم', style: TextStyle(color: AppColors.textLight))),
        ],
      ),
    );
  }

  Widget _evaluationSection(DailyEvaluation? eval) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('📝', 'تقييم اليوم'),
          const SizedBox(height: 12),
          if (eval != null) ...[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => Icon(i < eval.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 28)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _checkItem('تعلمت جديد', eval.learnedSomething),
                _checkItem('ساعدت مريض', eval.helpedPatient),
                _checkItem('راضية عن نفسي', eval.satisfied),
              ],
            ),
            if (eval.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Text(eval.notes, style: const TextStyle(fontSize: 13, height: 1.5)),
              ),
            ],
          ] else
            const Center(child: Text('لم يتم التقييم اليوم', style: TextStyle(color: AppColors.textLight))),
        ],
      ),
    );
  }

  Widget _checkItem(String label, bool value) {
    return Column(
      children: [
        Icon(value ? Icons.check_circle : Icons.cancel, color: value ? AppColors.success : AppColors.textLight, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: value ? AppColors.success : AppColors.textLight)),
      ],
    );
  }

  Widget _expenseSection(double todayTotal, double limit) {
    final hasLimit = limit > 0;
    final ratio = hasLimit && limit > 0 ? (todayTotal / limit).clamp(0.0, 1.0) : 0.0;
    final exceeded = hasLimit && todayTotal >= limit;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('💰', 'مصروفات اليوم', trailing: Text('$todayTotal ج.س', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: exceeded ? AppColors.error : AppColors.primary))),
          if (hasLimit) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(exceeded ? AppColors.error : AppColors.success)),
            ),
            const SizedBox(height: 4),
            Text('الحد: $limit ج.س${exceeded ? ' ⚠️ تم التجاوز' : ''}', style: TextStyle(fontSize: 11, color: exceeded ? AppColors.error : AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _tasksSection(List<dynamic> tasks) {
    final done = tasks.where((t) => t.isDone).toList();
    final pending = tasks.where((t) => !t.isDone).toList();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('📋', 'مهام اليوم', trailing: Text('${done.length}/${tasks.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            const Center(child: Text('لا توجد مهام اليوم', style: TextStyle(color: AppColors.textLight)))
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: tasks.isEmpty ? 0 : done.length / tasks.length, minHeight: 6, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(AppColors.success)),
            ),
            const SizedBox(height: 12),
            if (done.isNotEmpty) ...[
              const Text('المكتملة ✅', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
              const SizedBox(height: 4),
              ...done.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [const Text('😊 ', style: TextStyle(fontSize: 14)), Expanded(child: Text(t.title, style: const TextStyle(fontSize: 13, decoration: TextDecoration.lineThrough, color: AppColors.textLight)))]),
              )),
              const SizedBox(height: 8),
            ],
            if (pending.isNotEmpty) ...[
              const Text('غير المكتملة ❌', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
              const SizedBox(height: 4),
              ...pending.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [const Text('😢 ', style: TextStyle(fontSize: 14)), Expanded(child: Text(t.title, style: const TextStyle(fontSize: 13)))]),
              )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _lookSection(dynamic look, List<WardrobeItem> wardrobeItems) {
    List<WardrobeItem> _getItems() {
      if (look == null || look.wardrobeItemIds.isEmpty) return [];
      final ids = look.wardrobeItemIds.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
      return wardrobeItems.where((w) => ids.contains(w.id)).toList();
    }
    final items = _getItems();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('👗', 'إطلالة اليوم'),
          const SizedBox(height: 12),
          if (look != null) ...[
            if (look.description.isNotEmpty) _detailRow('الوصف', look.description),
            if (items.isNotEmpty) _detailRow('👗 الخزانة', items.map((i) => i.name).join(' | ')),
            if (look.makeupNotes.isNotEmpty) _detailRow('💄 المكياج', look.makeupNotes),
            if (look.hairStyle.isNotEmpty) _detailRow('💇 الشعر', look.hairStyle),
            if (look.accessories.isNotEmpty) _detailRow('💍 الإكسسوارات', look.accessories),
            _detailRow('التقييم', '${'⭐' * look.rating}'),
          ] else
            const Center(child: Text('لم يتم تسجيل إطلالة اليوم', style: TextStyle(color: AppColors.textLight))),
        ],
      ),
    );
  }

  Widget _placesSection(List<dynamic> places) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('📍', 'الأماكن التي زرتها اليوم'),
          const SizedBox(height: 12),
          if (places.isEmpty)
            const Center(child: Text('لم تزوري أي مكان اليوم', style: TextStyle(color: AppColors.textLight)))
          else
            ...places.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                const Text('📍', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(child: Text(p.name, style: const TextStyle(fontSize: 13))),
                if (p.city.isNotEmpty) Text(p.city, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            )),
        ],
      ),
    );
  }

  Widget _notesSection(List<dynamic> notes) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('📝', 'ملاحظات اليوم'),
          const SizedBox(height: 12),
          if (notes.isEmpty)
            const Center(child: Text('لا توجد ملاحظات اليوم', style: TextStyle(color: AppColors.textLight)))
          else
            ...notes.map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (n.title.isNotEmpty) Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(n.content, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                  const Divider(height: 12),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _moodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.excellent: return '😊';
      case MoodType.good: return '🙂';
      case MoodType.tired: return '😐';
      case MoodType.exhausted: return '😔';
    }
  }

  String _moodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.excellent: return 'ممتازة';
      case MoodType.good: return 'جيدة';
      case MoodType.tired: return 'متعبة';
      case MoodType.exhausted: return 'مرهقة';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/mood_selector.dart';
import '../widgets/water_tracker_widget.dart';
import '../widgets/prayer_tracker_widget.dart';
import '../widgets/section_header.dart';
import '../models/mood.dart';
import '../providers/mood_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/water_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/task_provider.dart';
import '../providers/evaluation_provider.dart';
import '../data/motivational_messages.dart';
import 'evaluation_screen.dart';
import 'prayer_screen.dart';
import 'dua_screen.dart';
import 'water_screen.dart';
import 'tasks_screen.dart';
import 'notes_screen.dart';
import 'achievements_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'letter_to_father_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<MoodProvider>().loadMoods(),
      context.read<PrayerProvider>().loadToday(),
      context.read<WaterProvider>().loadToday(),
      context.read<MealProvider>().loadToday(),
      context.read<TaskProvider>().loadTasks(),
      context.read<EvaluationProvider>().loadEvaluations(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM y', 'ar').format(now);
    final greetingHour = now.hour;
    String greeting;
    if (greetingHour < 12) {
      greeting = '☀️ صباح الخير يا دكتورة';
    } else if (greetingHour < 17) {
      greeting = '🌤 مساء الخير يا دكتورة';
    } else {
      greeting = '🌙 مساء النور يا دكتورة';
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(greeting, dateStr),
                const SizedBox(height: 16),
                const QuoteCard(),
                const SizedBox(height: 16),
                const _MoodSection(),
                const SizedBox(height: 16),
                const _QuickActions(),
                const SizedBox(height: 16),
                const _PrayerWaterRow(),
                const SizedBox(height: 16),
                const _TodayTasks(),
                const SizedBox(height: 16),
                const _DuaSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String greeting, String dateStr) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: const Icon(Icons.settings_outlined,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StatisticsScreen())),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}

class _MoodSection extends StatelessWidget {
  const _MoodSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('💭', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'كيف تشعرين اليوم؟',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MoodSelector(
                selectedMood: moodProvider.todayEntry?.mood,
                onMoodSelected: (mood) {
                  moodProvider.saveMood(MoodEntry(
                    date: DateTime.now(),
                    mood: mood,
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem('📝', 'تقييم اليوم', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EvaluationScreen()));
      }),
      _ActionItem('🕌', 'الصلاة', AppColors.greenSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PrayerScreen()));
      }),
      _ActionItem('🤲', 'الدعاء', AppColors.blueSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DuaScreen(title: '🤲 دعاء لأبي')));
      }),
      _ActionItem('💧', 'الماء', AppColors.blueSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WaterScreen()));
      }),
      _ActionItem('📋', 'المهام', AppColors.orangeSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TasksScreen()));
      }),
      _ActionItem('📓', 'ملاحظات', AppColors.pinkSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NotesScreen()));
      }),
      _ActionItem('🏆', 'الإنجازات', AppColors.greenSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AchievementsScreen()));
      }),
      _ActionItem('✉️', 'لأبي', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LetterToFatherScreen()));
      }),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اختصارات سريعة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((action) {
              return GestureDetector(
                onTap: action.onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: action.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(action.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        action.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;
  _ActionItem(this.emoji, this.title, this.color, this.onTap);
}

class _PrayerWaterRow extends StatelessWidget {
  const _PrayerWaterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: const PrayerTrackerWidget(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: const WaterTrackerWidget(),
          ),
        ),
      ],
    );
  }
}

class _TodayTasks extends StatelessWidget {
  const _TodayTasks();

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final todayTasks = taskProvider.todayTasks;
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    'مهام اليوم',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (todayTasks.isNotEmpty)
                    Text(
                      '${todayTasks.where((t) => t.isDone).length}/${todayTasks.length}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (todayTasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'لا توجد مهام اليوم 🌸',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...todayTasks.take(5).map((task) {
                  return CheckboxListTile(
                    value: task.isDone,
                    onChanged: (_) => taskProvider.toggleTask(task.id!),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _DuaSection extends StatelessWidget {
  const _DuaSection();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.purpleSoft,
      child: Column(
        children: [
          Row(
            children: [
              const Text('🤲', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'دعاء لأبي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DuaScreen(title: '🤲 دعاء لأبي'))),
                child: const Text(
                  'المزيد',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'اللهم اغفر لإبراهيم مضوي وارحمه، واجعل قبره روضة من رياض الجنة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}



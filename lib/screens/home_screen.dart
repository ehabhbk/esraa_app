import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/mood_selector.dart';
import '../widgets/water_tracker_widget.dart';
import '../models/mood.dart';
import '../widgets/prayer_tracker_widget.dart';
import '../providers/mood_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/water_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/task_provider.dart';
import '../providers/evaluation_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/shift_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/medicine_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/daily_goal_provider.dart';
import '../providers/medical_note_provider.dart';
import '../providers/contact_provider.dart';
import '../providers/health_provider.dart';
import '../providers/cme_provider.dart';
import '../providers/memory_provider.dart';
import '../providers/impact_provider.dart';
import '../providers/tree_provider.dart';
import '../providers/photodiary_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/skincare_provider.dart';
import '../providers/makeup_provider.dart';
import '../providers/look_provider.dart';
import '../providers/measurement_provider.dart';
import '../providers/place_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/idea_provider.dart';
import '../providers/dream_provider.dart';
import '../providers/hobby_provider.dart';
import '../services/notification_service.dart';
import 'evaluation_screen.dart';
import 'prayer_screen.dart';
import 'dua_screen.dart';
import 'water_screen.dart';
import 'tasks_screen.dart';
import 'notes_screen.dart';
import 'achievements_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'letter_to_father_screen.dart';
import 'patients_screen.dart';
import 'shifts_screen.dart';
import 'relaxation_screen.dart';
import 'appointments_screen.dart';
import 'medicines_screen.dart';
import 'expenses_screen.dart';
import 'daily_goals_screen.dart';
import 'medical_notes_screen.dart';
import 'contacts_screen.dart';
import 'health_screen.dart';
import 'cme_screen.dart';
import 'memories_screen.dart';
import 'impacts_screen.dart';
import 'success_tree_screen.dart';
import 'photo_diary_screen.dart';
import 'adhkar_screen.dart';
import 'habits_screen.dart';
import 'wardrobe_screen.dart';
import 'skincare_screen.dart';
import 'makeup_screen.dart';
import 'looks_screen.dart';
import 'measurements_screen.dart';
import 'places_screen.dart';
import 'wishlist_screen.dart';
import 'ideas_screen.dart';
import 'dreams_screen.dart';
import 'hobbies_screen.dart';
import 'drawing_screen.dart';
import 'daily_summary_screen.dart';

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
      if (NotificationService.pendingSummary) {
        NotificationService.clearPendingSummary();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySummaryScreen()));
      }
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
      context.read<PatientProvider>().loadPatients(),
      context.read<ShiftProvider>().loadShifts(),
      context.read<AchievementProvider>().loadAchievements(),
      context.read<AppointmentProvider>().loadAppointments(),
      context.read<MedicineProvider>().loadMedicines(),
      context.read<ExpenseProvider>().loadExpenses(),
      context.read<DailyGoalProvider>().loadGoals(),
      context.read<MedicalNoteProvider>().loadNotes(),
      context.read<ContactProvider>().loadContacts(),
      context.read<HealthProvider>().loadRecords(),
      context.read<CmeProvider>().loadCmeHours(),
      context.read<MemoryProvider>().loadMemories(),
      context.read<ImpactProvider>().loadImpacts(),
      context.read<TreeProvider>().loadProgress(),
      context.read<PhotoDiaryProvider>().loadEntries(),
      context.read<HabitProvider>().loadToday(),
      context.read<WardrobeProvider>().loadItems(),
      context.read<SkincareProvider>().loadToday(),
      context.read<MakeupProvider>().loadItems(),
      context.read<LookProvider>().loadLooks(),
      context.read<MeasurementProvider>().loadRecords(),
      context.read<PlaceProvider>().loadPlaces(),
      context.read<WishlistProvider>().loadItems(),
      context.read<IdeaProvider>().loadIdeas(),
      context.read<DreamProvider>().loadDreams(),
      context.read<HobbyProvider>().loadHobbies(),
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
                        builder: (_) => const StatsScreen())),
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
      _ActionItem('📊', 'ملخص اليوم', AppColors.orangeSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DailySummaryScreen()));
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
      _ActionItem('📋', 'المرضى', AppColors.pinkSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PatientsScreen()));
      }),
      _ActionItem('⏰', 'الشفتات', AppColors.orangeSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ShiftsScreen()));
      }),
      _ActionItem('🧘', 'استرخاء', AppColors.blueSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RelaxationScreen()));
      }),
      _ActionItem('📅', 'المواعيد', AppColors.blueSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
      }),
      _ActionItem('💊', 'الأدوية', AppColors.greenSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MedicinesScreen()));
      }),
      _ActionItem('💰', 'المصروفات', AppColors.orangeSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ExpensesScreen()));
      }),
      _ActionItem('🎯', 'الأهداف', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DailyGoalsScreen()));
      }),
      _ActionItem('📝', 'ملاحظات طبية', AppColors.pinkSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MedicalNotesScreen()));
      }),
      _ActionItem('📞', 'جهات الاتصال', AppColors.greenSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ContactsScreen()));
      }),
      _ActionItem('❤️', 'السجل الصحي', AppColors.pinkSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HealthScreen()));
      }),
      _ActionItem('📚', 'التعليم الطبي', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CmeScreen()));
      }),
      _ActionItem('🎞️', 'كبسولة الذكريات', AppColors.pinkSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MemoriesScreen()));
      }),
      _ActionItem('🌟', 'بصمة يومية', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ImpactsScreen()));
      }),
      _ActionItem('🌱', 'شجرة النجاح', AppColors.greenSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SuccessTreeScreen()));
      }),
      _ActionItem('📸', 'يوميات بالصور', AppColors.blueSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PhotoDiaryScreen()));
      }),
      _ActionItem('🌙', 'الأذكار', AppColors.orangeSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdhkarScreen()));
      }),
      _ActionItem('👗', 'خزانتي', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WardrobeScreen()));
      }),
      _ActionItem('🧴', 'العناية', AppColors.pinkSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SkincareScreen()));
      }),
      _ActionItem('💄', 'مكياجي', AppColors.orangeSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MakeupScreen()));
      }),
      _ActionItem('🎀', 'إطلالاتي', AppColors.blueSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LooksScreen()));
      }),
      _ActionItem('📏', 'قياساتي', AppColors.greenSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MeasurementsScreen()));
      }),
      _ActionItem('☕', 'عاداتي اليومية', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HabitsScreen()));
      }),
      _ActionItem('🗺️', 'أماكن زرتها', AppColors.greenSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlacesScreen()));
      }),
      _ActionItem('🎁', 'لستة الرغبات', AppColors.pinkSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WishlistScreen()));
      }),
      _ActionItem('💡', 'أفكاري', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const IdeasScreen()));
      }),
      _ActionItem('🌍', 'قائمة أحلام', AppColors.blueSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DreamsScreen()));
      }),
      _ActionItem('🎨', 'هواياتي', AppColors.orangeSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HobbiesScreen()));
      }),
      _ActionItem('✏️', 'الرسم', AppColors.purpleSoft, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DrawingScreen()));
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



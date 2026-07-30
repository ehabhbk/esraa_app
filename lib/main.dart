import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/mood_provider.dart';
import 'providers/evaluation_provider.dart';
import 'providers/task_provider.dart';
import 'providers/water_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/note_provider.dart';
import 'providers/letters_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/shift_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/medicine_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/daily_goal_provider.dart';
import 'providers/medical_note_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/health_provider.dart';
import 'providers/cme_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/impact_provider.dart';
import 'providers/tree_provider.dart';
import 'providers/photodiary_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/skincare_provider.dart';
import 'providers/makeup_provider.dart';
import 'providers/look_provider.dart';
import 'providers/measurement_provider.dart';
import 'providers/place_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/idea_provider.dart';
import 'providers/dream_provider.dart';
import 'providers/hobby_provider.dart';
import 'providers/drawing_provider.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await DatabaseService.database;
  try {
    await NotificationService.init();
    await NotificationService.requestPermissions();
    await NotificationService.scheduleAllDayReminders();
  } catch (_) {}
  final settings = SettingsProvider();
  await settings.loadSettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => EvaluationProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => LettersProvider()),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DailyGoalProvider()),
        ChangeNotifierProvider(create: (_) => MedicalNoteProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => CmeProvider()),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => ImpactProvider()),
        ChangeNotifierProvider(create: (_) => TreeProvider()),
        ChangeNotifierProvider(create: (_) => PhotoDiaryProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider(create: (_) => SkincareProvider()),
        ChangeNotifierProvider(create: (_) => MakeupProvider()),
        ChangeNotifierProvider(create: (_) => LookProvider()),
        ChangeNotifierProvider(create: (_) => MeasurementProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => IdeaProvider()),
        ChangeNotifierProvider(create: (_) => DreamProvider()),
        ChangeNotifierProvider(create: (_) => HobbyProvider()),
        ChangeNotifierProvider(create: (_) => DrawingProvider()),
      ],
      child: const EsraaApp(),
    ),
  );
}

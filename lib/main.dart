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
import 'services/notification_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await DatabaseService.database;
  await NotificationService.init();
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
      ],
      child: const EsraaApp(),
    ),
  );
}

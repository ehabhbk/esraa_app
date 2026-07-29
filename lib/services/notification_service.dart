import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import '../data/motivational_messages.dart';
import '../data/prayer_duas.dart';
import 'database_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _tzInitialized = false;

  static Future<void> init() async {
    if (!_tzInitialized) {
      tzData.initializeTimeZones();
      _tzInitialized = true;
    }
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload?.startsWith('task_check_') ?? false) {
      _pendingTaskPayload = response.payload;
    }
    if (response.payload == 'daily_summary') {
      _pendingSummary = true;
    }
    if (response.actionId?.startsWith('yes_') ?? false) {
      final taskIdStr = response.actionId!.substring(4);
      final taskId = int.tryParse(taskIdStr);
      if (taskId != null) {
        _updateTaskAfterNotification(taskId, true);
      }
    }
    if (response.actionId?.startsWith('no_') ?? false) {
      final taskIdStr = response.actionId!.substring(3);
      final taskId = int.tryParse(taskIdStr);
      if (taskId != null) {
        _updateTaskAfterNotification(taskId, false);
      }
    }
  }

  static void _updateTaskAfterNotification(int taskId, bool completed) async {
    final db = await DatabaseService.database;
    await db.update(
      'tasks',
      {'isDone': completed ? 1 : 0, 'progress': completed ? 100 : 0, 'hasCompleted': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  static String? _pendingTaskPayload;
  static String? get pendingTaskPayload => _pendingTaskPayload;
  static void clearPendingTaskPayload() => _pendingTaskPayload = null;

  static bool _pendingSummary = false;
  static bool get pendingSummary => _pendingSummary;
  static void clearPendingSummary() => _pendingSummary = false;

  static Future<void> scheduleTaskCheckNotification({
    required int id,
    required String taskTitle,
    required int taskId,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'esraa_tasks_channel',
      'تذكيرات المهام',
      channelDescription: 'إشعارات تتبع المهام',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('yes_$taskId', 'نعم ✅', showsUserInterface: true, cancelNotification: true),
        AndroidNotificationAction('no_$taskId', 'لا ❌', showsUserInterface: true, cancelNotification: true),
      ],
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final location = tz.getLocation('Asia/Riyadh');
    final tzDate = tz.TZDateTime.from(scheduledDate, location);
    await _plugin.zonedSchedule(
      id,
      '❓ هل أكملتي المهمة؟',
      'هل أكملتي مهمة "$taskTitle" يا دكتورة إسراء؟',
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task_check_$taskId',
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'esraa_channel',
      'تذكيرات إسراء',
      channelDescription: 'إشعارات التذكير والتحفيز',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'esraa_channel',
      'تذكيرات إسراء',
      channelDescription: 'إشعارات التذكير والتحفيز',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final location = tz.getLocation('Asia/Riyadh');
    final tzDate = tz.TZDateTime.from(scheduledDate, location);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> scheduleDailyMorningMessage() async {
    final now = DateTime.now();
    final scheduledDate = DateTime(now.year, now.month, now.day, 6, 0);
    final scheduleTime = scheduledDate.isAfter(now)
        ? scheduledDate
        : scheduledDate.add(const Duration(days: 1));
    final msg = _getTodaysMessage();
    await scheduleNotification(
      id: 100,
      title: '☀️ صباح الخير يا دكتورة',
      body: msg,
      scheduledDate: scheduleTime,
    );
  }

  static Future<void> scheduleDailyEveningEvaluation() async {
    final now = DateTime.now();
    final scheduledDate = DateTime(now.year, now.month, now.day, 21, 0);
    final scheduleTime = scheduledDate.isAfter(now)
        ? scheduledDate
        : scheduledDate.add(const Duration(days: 1));
    await scheduleNotification(
      id: 200,
      title: '🌙 كيف كان يومك؟',
      body: 'حان وقت تقييم اليوم، كيف تشعرين؟',
      scheduledDate: scheduleTime,
      payload: 'evaluation',
    );
  }

  static Future<void> schedulePrayerReminder(
      String prayerName, int hour, int minute) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final id = 400 + prayerName.hashCode;
    await scheduleNotification(
      id: id,
      title: '🕌 حان وقت الصلاة',
      body: 'حان وقت صلاة $prayerName، لا تنسيها يا دكتورة',
      scheduledDate: scheduledDate,
      payload: 'prayer',
    );
  }

  static Future<void> scheduleDuaReminder() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 21, 30);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final dua = PrayerDuas.getRandomDuaForFather();
    await scheduleNotification(
      id: 500,
      title: '🤲 دعاء لأبي',
      body: dua,
      scheduledDate: scheduledDate,
      payload: 'dua',
    );
  }

  static Future<void> scheduleMealReminder(
      String mealName, int hour, int minute) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final id = 600 + mealName.hashCode;
    await scheduleNotification(
      id: id,
      title: '🍽 تذكير بالوجبة',
      body: 'حان وقت $mealName، لا تنسي تناول الطعام',
      scheduledDate: scheduledDate,
    );
  }

  static Future<void> scheduleFutureMessage() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 20, 0);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final messages = [
      'مرحبًا يا دكتورة إسراء... تخيلي نفسك بعد خمس سنوات، طبيبة ناجحة، تنظرين إلى هذه الأيام وتستسمين لأنك لم تستسلمي.',
      'بعد سنوات ستنظرين إلى اليوم وستفتخرين بكل خطوة خطوتها. أنت تصنعين مستقبلك الآن.',
      'هذه الأيام الصعبة هي قصة نجاحك المستقبلية. كل يوم يمضي يقرّبك من حلمك.',
    ];
    final msg = messages[now.day % messages.length];
    await scheduleNotification(
      id: 700,
      title: '✉️ رسالة من المستقبل',
      body: msg,
      scheduledDate: scheduledDate,
    );
  }

  static String _getTodaysMessage() {
    final messages = MotivationalMessages.all;
    final day = DateTime.now().day;
    return messages[day % messages.length].text;
  }

  static Future<void> scheduleDailySummary(int hour, int minute) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    await scheduleNotification(
      id: 800,
      title: '📊 الملخص اليومي',
      body: 'ملخص يومك جاهز، اضغطي للعرض',
      scheduledDate: scheduledDate,
      payload: 'daily_summary',
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancelDailySummary() async {
    await _plugin.cancel(800);
  }

  static Future<void> scheduleAllDayReminders() async {
    await cancelAll();
    await scheduleDailyMorningMessage();
    await schedulePrayerReminder('الفجر', 5, 30);
    await scheduleMealReminder('🍳 الإفطار', 6, 30);
    await schedulePrayerReminder('الظهر', 12, 30);
    await scheduleMealReminder('🍽 الغداء', 13, 0);
    await schedulePrayerReminder('العصر', 15, 30);
    await schedulePrayerReminder('المغرب', 18, 0);
    await schedulePrayerReminder('العشاء', 19, 30);
    await scheduleMealReminder('🥗 العشاء', 20, 0);
    await scheduleFutureMessage();
    await scheduleDailyEveningEvaluation();
    await scheduleDuaReminder();
    final prefs = await SharedPreferences.getInstance();
    final summaryEnabled = prefs.getBool('summaryEnabled') ?? true;
    if (summaryEnabled) {
      final hour = prefs.getInt('summaryHour') ?? 20;
      final minute = prefs.getInt('summaryMinute') ?? 0;
      await scheduleDailySummary(hour, minute);
    }
  }
}

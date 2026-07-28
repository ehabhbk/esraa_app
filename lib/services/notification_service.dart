import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/motivational_messages.dart';
import '../data/prayer_duas.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
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

  static void _onNotificationTap(NotificationResponse response) {}

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

  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<bool> _shouldNotifyToday(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(key);
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (lastDate == today) return false;
    await prefs.setString(key, today);
    return true;
  }

  static Future<void> scheduleMorningMessage() async {
    if (!await _shouldNotifyToday('morning_msg_date')) return;
    final msg = MotivationalMessages.getRandom();
    await showNotification(
      id: 100,
      title: '☀️ صباح الخير يا دكتورة',
      body: msg.text,
    );
  }

  static Future<void> scheduleEveningEvaluation() async {
    if (!await _shouldNotifyToday('evaluation_date')) return;
    await showNotification(
      id: 200,
      title: '🌙 كيف كان يومك؟',
      body: 'حان وقت تقييم اليوم، كيف تشعرين؟',
      payload: 'evaluation',
    );
  }

  static Future<void> scheduleWaterReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final cupKey = 'water_cups_$today';
    final cups = prefs.getInt(cupKey) ?? 0;
    if (cups >= 8) return;
    await showNotification(
      id: 300,
      title: '💧 حان وقت شرب الماء',
      body: 'اشربي كوب ماء الآن 💙 (${cups}/8)',
    );
    await prefs.setInt(cupKey, cups + 1);
  }

  static Future<void> schedulePrayerReminder(String prayerName) async {
    await showNotification(
      id: 400 + prayerName.hashCode,
      title: '🕌 حان وقت الصلاة',
      body: 'حان وقت صلاة $prayerName، لا تنسيها يا دكتورة',
      payload: 'prayer',
    );
  }

  static Future<void> scheduleDuaReminder() async {
    if (!await _shouldNotifyToday('dua_date')) return;
    final dua = PrayerDuas.getRandomDuaForFather();
    await showNotification(
      id: 500,
      title: '🤲 دعاء لأبي',
      body: dua,
      payload: 'dua',
    );
  }

  static Future<void> scheduleMealReminder(String mealName) async {
    await showNotification(
      id: 600 + mealName.hashCode,
      title: '🍽 تذكير بالوجبة',
      body: 'حان وقت $mealName، لا تنسي تناول الطعام',
    );
  }

  static Future<void> scheduleFutureMessage() async {
    if (!await _shouldNotifyToday('future_msg_date')) return;
    final messages = [
      'مرحبًا يا دكتورة إسراء... تخيلي نفسك بعد خمس سنوات، طبيبة ناجحة، تنظرين إلى هذه الأيام وتستسمين لأنك لم تستسلمي.',
      'بعد سنوات ستنظرين إلى اليوم وستفتخرين بكل خطوة خطوتها. أنت تصنعين مستقبلك الآن.',
      'هذه الأيام الصعبة هي قصة نجاحك المستقبلية. كل يوم يمضي يقرّبك من حلمك.',
    ];
    final msg = messages[DateTime.now().day % messages.length];
    await showNotification(
      id: 700,
      title: '✉️ رسالة من المستقبل',
      body: msg,
    );
  }

  static Future<void> scheduleAllDayReminders() async {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 7) {
      await scheduleMorningMessage();
    }
    if (hour >= 6 && hour < 8) {
      await schedulePrayerReminder('الفجر');
      await scheduleMealReminder('🍳 الإفطار');
    }
    if (hour >= 9 && hour < 22) {
      await scheduleWaterReminder();
    }
    if (hour >= 12 && hour < 14) {
      await schedulePrayerReminder('الظهر');
      await scheduleMealReminder('🍽 الغداء');
    }
    if (hour >= 15 && hour < 17) {
      await schedulePrayerReminder('العصر');
    }
    if (hour >= 17 && hour < 19) {
      await schedulePrayerReminder('المغرب');
    }
    if (hour >= 19 && hour < 21) {
      await schedulePrayerReminder('العشاء');
      await scheduleMealReminder('🥗 العشاء');
      await scheduleFutureMessage();
    }
    if (hour >= 20 && hour < 23) {
      await scheduleEveningEvaluation();
      await scheduleDuaReminder();
    }
  }
}

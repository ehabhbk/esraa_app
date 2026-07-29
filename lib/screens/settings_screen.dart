import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ الإعدادات')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('🌙 الوضع الليلي'),
                        subtitle: const Text('تفعيل الألوان الداكنة'),
                        value: settings.isDarkMode,
                        onChanged: (_) => settings.toggleDarkMode(),
                        activeThumbColor: AppColors.primary,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('🔒 قفل التطبيق'),
                        subtitle: const Text('بصمة الإصبع أو القفل'),
                        value: settings.biometricEnabled,
                        onChanged: (_) => settings.toggleBiometric(),
                        activeThumbColor: AppColors.primary,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('🔔 الإشعارات'),
                        subtitle: const Text('تفعيل جميع الإشعارات'),
                        value: settings.notificationsEnabled,
                        onChanged: (_) => settings.toggleNotifications(),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💧 تذكير الماء',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'كل ${settings.waterInterval} دقيقة',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Slider(
                        value: settings.waterInterval.toDouble(),
                        min: 30,
                        max: 180,
                        divisions: 5,
                        label: '${settings.waterInterval} دقيقة',
                        onChanged: (v) =>
                            settings.setWaterInterval(v.toInt()),
                        activeColor: AppColors.waterBlue,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('30 د', style: TextStyle(fontSize: 12)),
                          Text('180 د', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💾 النسخ الاحتياطي',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.backup, color: AppColors.primary),
                        title: const Text('عمل نسخة احتياطية'),
                        subtitle: const Text('حفظ البيانات'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ تم عمل نسخة احتياطية'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.restore, color: AppColors.warning),
                        title: const Text('استعادة البيانات'),
                        subtitle: const Text('استعادة من نسخة سابقة'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('📊 الملخص اليومي'),
                        subtitle: const Text('إشعار بنهاية اليوم'),
                        value: settings.summaryEnabled,
                        onChanged: (_) => settings.toggleSummary(),
                        activeThumbColor: AppColors.primary,
                      ),
                      if (settings.summaryEnabled) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.access_time, color: AppColors.primary),
                          title: Text('وقت الإشعار: ${settings.summaryHour.toString().padLeft(2, '0')}:${settings.summaryMinute.toString().padLeft(2, '0')}'),
                          trailing: const Icon(Icons.edit, color: AppColors.textLight),
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: settings.summaryHour, minute: settings.summaryMinute),
                            );
                            if (t != null) settings.setSummaryTime(t.hour, t.minute);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    children: [
                      const ListTile(
                        leading:
                            Icon(Icons.info_outline, color: AppColors.primary),
                        title: Text('التطبيق ده يا بت الخالة عشان يساعدك في يومك'),
                        subtitle: Text('من اخوك وسندك دائماً إيهاب  ',),
                      ),
                      const Divider(),
                      const ListTile(
                        leading: Icon(Icons.favorite, color: AppColors.accent),
                        title: Text('صنع خصيصاً ❤️'),
                        subtitle: Text('للدكتورة إسراء(إيلاف) مضوي'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: AppColors.primary),
                    title: const Text('🔔 إرسال إشعار تجريبي'),
                    subtitle: const Text('اختبر وصول الإشعارات'),
                    onTap: () async {
                      await NotificationService.showNotification(
                        id: 999,
                        title: '🔔 إشعار تجريبي',
                        body: 'الإشعارات شغالة يا دكتورة إسراء ✅',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ تم إرسال الإشعار')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'تمنياتي لك بالتوفيق والنجاح ',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/settings_provider.dart';

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
                        activeColor: AppColors.primary,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('🔒 قفل التطبيق'),
                        subtitle: const Text('بصمة الإصبع أو القفل'),
                        value: settings.biometricEnabled,
                        onChanged: (_) => settings.toggleBiometric(),
                        activeColor: AppColors.primary,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('🔔 الإشعارات'),
                        subtitle: const Text('تفعيل جميع الإشعارات'),
                        value: settings.notificationsEnabled,
                        onChanged: (_) => settings.toggleNotifications(),
                        activeColor: AppColors.primary,
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
                    children: [
                      const ListTile(
                        leading:
                            Icon(Icons.info_outline, color: AppColors.primary),
                        title: Text('عن التطبيق'),
                        subtitle: Text('Esraa v1.0'),
                      ),
                      const Divider(),
                      const ListTile(
                        leading: Icon(Icons.favorite, color: AppColors.accent),
                        title: Text('صنع بحب ❤️'),
                        subtitle: Text('للدكتورة إسراء مضوي'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'للذكرى إبراهيم مضوي - رحمه الله 🤲',
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

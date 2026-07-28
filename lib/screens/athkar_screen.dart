import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class AthkarScreen extends StatelessWidget {
  const AthkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📿 الأذكار')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAdhkarCard(
              '🌅 أذكار الصباح',
              'تقال بعد صلاة الفجر حتى شروق الشمس',
              AppColors.orangeSoft,
              [
                'اللهم بك أصبحنا وبك أمسينا',
                'رضيت بالله رباً وبالإسلام ديناً وبمحمد ﷺ نبياً',
                'سبحان الله وبحمده (100 مرة)',
                'أستغفر الله وأتوب إليه (100 مرة)',
                'اللهم أنت ربي لا إله إلا أنت خلقتني وأنا عبدك',
                'بسم الله الذي لا يضر مع اسمه شيء',
              ],
            ),
            const SizedBox(height: 12),
            _buildAdhkarCard(
              '🌇 أذكار المساء',
              'تقال بعد صلاة العصر حتى المغرب',
              AppColors.purpleSoft,
              [
                'اللهم بك أمسينا وبك أصبحنا',
                'أمسينا وأمسى الملك لله',
                'سبحان الله (33 مرة)',
                'الحمد لله (33 مرة)',
                'الله أكبر (33 مرة)',
                'اللهم أنت ربي لا إله إلا أنت',
              ],
            ),
            const SizedBox(height: 12),
            _buildAdhkarCard(
              '🌙 أذكار النوم',
              'تقال قبل النوم',
              AppColors.blueSoft,
              [
                'باسمك اللهم أموت وأحيا',
                'اللهم قني عذابك يوم تبعث عبادك',
                'اللهم أسلمت نفسي إليك',
                'قراءة آية الكرسي',
                'قراءة المعوذات (3 مرات)',
                'سورة الإخلاص والمعوذتين',
              ],
            ),
            const SizedBox(height: 12),
            _buildAdhkarCard(
              '☀️ أذكار الاستيقاظ',
              'تقال عند الاستيقاظ من النوم',
              AppColors.greenSoft,
              [
                'الحمد لله الذي أحيانا بعد ما أماتنا',
                'الحمد لله الذي عافاني في جسدي',
                'اللهم إني أسألك من خير هذا اليوم',
                'رب أعوذ بك من الكسل وسوء الكبر',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhkarCard(
    String title,
    String subtitle,
    Color bgColor,
    List<String> adhkar,
  ) {
    return GlassCard(
      backgroundColor: bgColor.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title.split(' ').first, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...adhkar.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

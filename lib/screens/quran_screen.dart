import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().day;
    final juzNumber = (today % 30) + 1;
    final pages = '${(juzNumber - 1) * 20 + 1} - ${juzNumber * 20}';
    return Scaffold(
      appBar: AppBar(title: const Text('📖 القرآن الكريم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GlassCard(
              backgroundColor: AppColors.greenSoft,
              child: Column(
                children: [
                  const Text('📖', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  const Text(
                    'الورد اليومي',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'الجزء $juzNumber',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الصفحات: $pages',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: juzNumber / 30,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'نسبة الإنجاز الشهري',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(juzNumber / 30 * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
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
                    '📚 السور المقترحة',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSurahItem('الفاتحة', 'أم الكتاب', '7'),
                  _buildSurahItem('يس', 'قلب القرآن', '36'),
                  _buildSurahItem('الرحمن', 'عروس القرآن', '55'),
                  _buildSurahItem('الواقعة', 'سورة الغنى', '56'),
                  _buildSurahItem('الملك', 'المانعة من عذاب القبر', '67'),
                  _buildSurahItem('الإخلاص', 'تعدل ثلث القرآن', '112'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🕌 فضل قراءة القرآن',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildVirtue('💎', 'القرآن يشفع لصاحبه يوم القيامة'),
                  _buildVirtue('💎', 'الحرف بحسنة والحسنة بعشر أمثالها'),
                  _buildVirtue('💎', 'يجلب السكينة والطمأنينة للقلب'),
                  _buildVirtue('💎', 'يرفع الدرجات في الجنة'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahItem(String name, String desc, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Text(desc,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVirtue(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

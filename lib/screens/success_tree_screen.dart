import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/tree_provider.dart';

class SuccessTreeScreen extends StatefulWidget {
  const SuccessTreeScreen({super.key});

  @override
  State<SuccessTreeScreen> createState() => _SuccessTreeScreenState();
}

class _SuccessTreeScreenState extends State<SuccessTreeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreeProvider>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌱 شجرة النجاح')),
      body: Consumer<TreeProvider>(
        builder: (context, provider, child) {
          final progress = provider.getProgress();
          final stage = provider.getTreeStage();
          final percentage = (progress * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        stage['emoji'] as String,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        stage['name'] as String,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stage['description'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 16,
                          backgroundColor: AppColors.greenSoft,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.unlockedAchievements}/${provider.totalAchievements} إنجاز',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'مراحل النجاح',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStageRow('🌱', 'بذرة', '0-10%', progress >= 0, progress < 0.1),
                _buildStageRow('🌿', 'شتلة', '10-25%', progress >= 0.1, progress < 0.25),
                _buildStageRow('🌳', 'شجرة صغيرة', '25-50%', progress >= 0.25, progress < 0.5),
                _buildStageRow('🌲', 'شجرة متوسطة', '50-75%', progress >= 0.5, progress < 0.75),
                _buildStageRow('🌴', 'شجرة مثمرة', '75-90%', progress >= 0.75, progress < 0.9),
                _buildStageRow('🌴🌲🌳', 'غابة', '90-100%', progress >= 0.9, progress <= 1.0),
                const SizedBox(height: 24),
                if (provider.recentAchievements.isNotEmpty) ...[
                  const Text(
                    'أحدث الإنجازات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...provider.recentAchievements.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      child: ListTile(
                        leading: Text(a['iconEmoji'] as String? ?? '🏆', style: const TextStyle(fontSize: 28)),
                        title: Text(a['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(a['description'] as String),
                        trailing: a['unlockedAt'] != null
                            ? Text(
                                DateFormat('MM/dd', 'ar').format(DateTime.parse(a['unlockedAt'] as String)),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              )
                            : null,
                      ),
                    ),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStageRow(String emoji, String name, String range, bool reached, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        backgroundColor: isCurrent ? AppColors.greenSoft : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: reached ? AppColors.textPrimary : AppColors.textLight,
                    ),
                  ),
                  Text(
                    range,
                    style: TextStyle(
                      fontSize: 12,
                      color: reached ? AppColors.textSecondary : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (reached)
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
          ],
        ),
      ),
    );
  }
}

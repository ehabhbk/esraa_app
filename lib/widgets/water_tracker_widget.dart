import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../theme/app_colors.dart';

class WaterTrackerWidget extends StatelessWidget {
  const WaterTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, water, child) {
        return Column(
          children: [
            Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                const Text(
                  'شرب الماء',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${water.todayCups}/${water.targetCups}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: water.progress,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: water.todayCups > 0 ? water.removeCup : null,
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  '${water.todayCups}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton.filled(
                  onPressed: water.todayCups < water.targetCups
                      ? water.addCup
                      : null,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.waterBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

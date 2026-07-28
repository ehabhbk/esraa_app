import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../theme/app_colors.dart';

class MoodSelector extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onMoodSelected;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodType.values.map((mood) {
        final isSelected = mood == selectedMood;
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? _getMoodColor(mood) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _getMoodColor(mood) : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mood.emoji,
                  style: TextStyle(fontSize: isSelected ? 32 : 28),
                ),
                const SizedBox(height: 4),
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.excellent:
        return AppColors.moodGreen;
      case MoodType.good:
        return AppColors.moodYellow;
      case MoodType.tired:
        return AppColors.moodOrange;
      case MoodType.exhausted:
        return AppColors.moodRed;
    }
  }
}

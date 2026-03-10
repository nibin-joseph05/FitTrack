import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MuscleGroupBadge extends StatelessWidget {
  final String muscleGroup;

  const MuscleGroupBadge({super.key, required this.muscleGroup});

  Color _colorFor(String group) {
    switch (group) {
      case 'Chest':
        return AppColors.muscleChest;
      case 'Back':
        return AppColors.muscleBack;
      case 'Shoulders':
        return AppColors.muscleShoulders;
      case 'Biceps':
        return AppColors.muscleBiceps;
      case 'Triceps':
        return AppColors.muscleTriceps;
      case 'Legs':
      case 'Glutes':
        return AppColors.muscleLegs;
      case 'Core':
        return AppColors.muscleCore;
      default:
        return AppColors.muscleOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(muscleGroup);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        muscleGroup,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

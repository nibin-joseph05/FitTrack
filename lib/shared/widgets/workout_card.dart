import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/format_utils.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final int exerciseCount;
  final int totalSets;
  final double totalVolume;
  final Duration? duration;
  final VoidCallback? onTap;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.date,
    required this.exerciseCount,
    required this.totalSets,
    required this.totalVolume,
    this.duration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (duration != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      FormatUtils.formatDuration(duration!),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppDateUtils.timeAgo(date),
              style: const TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _StatBubble(
                  icon: Icons.fitness_center_outlined,
                  value: '$exerciseCount',
                  label: 'exercises',
                ),
                const SizedBox(width: 16),
                _StatBubble(
                  icon: Icons.layers_outlined,
                  value: '$totalSets',
                  label: 'sets',
                ),
                const SizedBox(width: 16),
                _StatBubble(
                  icon: Icons.monitor_weight_outlined,
                  value: FormatUtils.formatVolume(totalVolume),
                  label: 'volume',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBubble({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

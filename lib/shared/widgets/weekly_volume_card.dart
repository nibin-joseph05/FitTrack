import 'package:flutter/material.dart';

class WeeklyVolumeCard extends StatelessWidget {
  final String volume;
  final int workouts;
  final double progressPercent;

  const WeeklyVolumeCard({
    super.key,
    required this.volume,
    required this.workouts,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Volume',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Icon(Icons.bar_chart, color: primary),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  volume,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 4),
                  child: Text('kg', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$workouts workouts this week',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: primary,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progressPercent * 100).toInt()}% of weekly goal',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

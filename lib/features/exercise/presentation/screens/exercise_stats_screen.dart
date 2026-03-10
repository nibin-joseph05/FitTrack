import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/exercise_provider.dart';
import '../../../workout/presentation/providers/workout_provider.dart';
import '../../../../core/theme/app_colors.dart';

class ExerciseStatsScreen extends ConsumerWidget {
  final String exerciseId;

  const ExerciseStatsScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exerciseProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Statistics')),
      body: exercisesAsync.when(
        data: (exercises) {
          final exercise = exercises.firstWhere(
            (e) => e.id == exerciseId,
            orElse: () => throw Exception('Exercise not found'),
          );

          return historyAsync.when(
            data: (history) {
              double bestWeight = 0;
              int totalSessions = 0;
              double totalVolume = 0;
              DateTime? lastWorkoutDate;
              List<FlSpot> progressSpots = [];

              final relevantSessions = history
                  .where((s) =>
                      s.exercises.any((we) => we.exerciseId == exerciseId))
                  .toList()
                ..sort((a, b) => a.date.compareTo(b.date));

              for (int i = 0; i < relevantSessions.length; i++) {
                final s = relevantSessions[i];
                final we =
                    s.exercises.firstWhere((e) => e.exerciseId == exerciseId);

                totalSessions++;
                if (lastWorkoutDate == null ||
                    s.date.isAfter(lastWorkoutDate)) {
                  lastWorkoutDate = s.date;
                }

                double sessionMaxWeight = 0;
                for (final set in we.sets) {
                  if (set.isCompleted) {
                    final setVol = set.weight * set.completedReps;
                    totalVolume += setVol;
                    if (set.weight > bestWeight) bestWeight = set.weight;
                    if (set.weight > sessionMaxWeight) {
                      sessionMaxWeight = set.weight;
                    }
                  }
                }

                if (sessionMaxWeight > 0) {
                  progressSpots.add(FlSpot(i.toDouble(), sessionMaxWeight));
                }
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatCard(
                          title: 'Best Weight',
                          value: '${bestWeight.toStringAsFixed(1)} kg'),
                      const SizedBox(width: 16),
                      _StatCard(title: 'Sessions', value: '$totalSessions'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard(
                          title: 'Total Volume',
                          value: '${totalVolume.toStringAsFixed(0)} kg'),
                      const SizedBox(width: 16),
                      _StatCard(
                          title: 'Last Workout',
                          value: lastWorkoutDate != null
                              ? DateFormat('MMM d, yyyy')
                                  .format(lastWorkoutDate)
                              : 'Never'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Strength Progress (Max Weight)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (progressSpots.isEmpty)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No progress data yet.')))
                  else
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: progressSpots,
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

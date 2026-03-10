import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_track/features/workout/presentation/providers/workout_provider.dart';
import 'package:fit_track/features/workout/domain/entities/workout_entities.dart';
import '../../../body_metrics/presentation/providers/body_metrics_provider.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
import '../../../../core/utils/date_utils.dart';

class ProgressData {
  final String exerciseName;
  final List<(DateTime, double)> maxWeightHistory;

  const ProgressData({
    required this.exerciseName,
    required this.maxWeightHistory,
  });
}

class VolumeData {
  final DateTime date;
  final double volume;

  const VolumeData({required this.date, required this.volume});
}

final strengthProgressProvider = FutureProvider.family<ProgressData?, String>((
  ref,
  exerciseId,
) async {
  final workouts = await ref.watch(workoutHistoryProvider.future);
  final history = <(DateTime, double)>[];
  for (final w in workouts.reversed) {
    for (final e in w.exercises) {
      if (e.exerciseId == exerciseId && e.maxWeight > 0) {
        history.add((w.date, e.maxWeight));
      }
    }
  }
  if (history.isEmpty) return null;
  final name = workouts
      .expand((w) => w.exercises)
      .firstWhere(
        (e) => e.exerciseId == exerciseId,
        orElse: () => const WorkoutExerciseEntity(
          exerciseId: '',
          exerciseName: 'Exercise',
          muscleGroup: '',
          sets: [],
        ),
      )
      .exerciseName;
  return ProgressData(exerciseName: name, maxWeightHistory: history);
});

final weeklyVolumeProvider = FutureProvider<List<VolumeData>>((ref) async {
  final workouts = await ref.watch(workoutHistoryProvider.future);
  final now = DateTime.now();
  final days = List.generate(
    7,
    (i) => DateTime(now.year, now.month, now.day - (6 - i)),
  );
  return days.map((day) {
    final dayWorkouts = workouts.where((w) {
      return w.date.year == day.year &&
          w.date.month == day.month &&
          w.date.day == day.day;
    });
    final vol = dayWorkouts.fold(0.0, (sum, w) => sum + w.totalVolume);
    return VolumeData(date: day, volume: vol);
  }).toList();
});

final uniqueExercisesInHistoryProvider = FutureProvider<List<(String, String)>>(
  (ref) async {
    final workouts = await ref.watch(workoutHistoryProvider.future);
    final seen = <String>{};
    final result = <(String, String)>[];
    for (final w in workouts) {
      for (final e in w.exercises) {
        if (seen.add(e.exerciseId)) {
          result.add((e.exerciseId, e.exerciseName));
        }
      }
    }
    return result;
  },
);

final selectedProgressExerciseProvider = StateProvider<String?>((ref) => null);

final bodyWeightProgressProvider = Provider<List<(DateTime, double)>>((ref) {
  final metricsAsync = ref.watch(bodyMetricsProvider);
  return metricsAsync.maybeWhen(
    data: (metrics) {
      final withWeight = metrics.where((m) => m.weightKg != null).toList();
      withWeight.sort((a, b) => a.date.compareTo(b.date));
      return withWeight.map((m) => (m.date, m.weightKg!)).toList();
    },
    orElse: () => [],
  );
});

class TrainingFrequencyData {
  final String label;
  final int count;
  TrainingFrequencyData(this.label, this.count);
}

final trainingFrequencyProvider = Provider<List<TrainingFrequencyData>>((ref) {
  final historyAsync = ref.watch(attendanceHistoryProvider);

  return historyAsync.maybeWhen(
    data: (history) {
      final List<TrainingFrequencyData> weeksData = [];

      for (int i = 3; i >= 0; i--) {
        final startOfWeek =
            AppDateUtils.startOfWeek().subtract(Duration(days: i * 7));
        final endOfWeek = startOfWeek
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

        int count = 0;
        for (final a in history) {
          if (a.attended &&
              a.date.isAfter(startOfWeek) &&
              a.date.isBefore(endOfWeek)) {
            count++;
          }
        }

        final label = i == 0 ? 'This Week' : '${i}w ago';
        weeksData.add(TrainingFrequencyData(label, count));
      }

      return weeksData;
    },
    orElse: () => [],
  );
});

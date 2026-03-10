import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/workout_provider.dart';
import '../../domain/entities/workout_entities.dart';

final _workoutDetailProvider = FutureProvider.family<WorkoutLogEntity?, String>(
  (ref, id) async {
    return ref.read(workoutRepositoryProvider).getWorkoutById(id);
  },
);

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(_workoutDetailProvider(workoutId));

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: workout.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (w) {
          if (w == null) {
            return const Center(child: Text('Workout not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _WorkoutHeader(workout: w),
              const SizedBox(height: 24),
              _StatsRow(workout: w),
              const SizedBox(height: 28),
              const _SectionTitle('Exercises'),
              const SizedBox(height: 12),
              ...w.exercises.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ExerciseDetailCard(exercise: e),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  final WorkoutLogEntity workout;
  const _WorkoutHeader({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workout.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          AppDateUtils.formatDateTime(workout.date),
          style: const TextStyle(color: AppColors.textHint, fontSize: 14),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final WorkoutLogEntity workout;
  const _StatsRow({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Duration',
            value: FormatUtils.formatDuration(workout.duration),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Exercises',
            value: '${workout.exercises.length}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Volume',
            value: FormatUtils.formatVolume(workout.totalVolume),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final WorkoutExerciseEntity exercise;
  const _ExerciseDetailCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                exercise.muscleGroup,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SetHeader('Set'),
              _SetHeader('Reps'),
              _SetHeader('Weight'),
              _SetHeader('Volume'),
            ],
          ),
          const Divider(height: 12),
          ...exercise.sets.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _SetCell(s.setNumber.toString()),
                  _SetCell(s.reps.toString()),
                  _SetCell(FormatUtils.formatWeightCompact(s.weight)),
                  _SetCell(FormatUtils.formatVolume(s.volume)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _SetCell('Total'),
              _SetCell('—'),
              _SetCell(
                FormatUtils.formatWeightCompact(exercise.maxWeight) + ' max',
              ),
              _SetCell(FormatUtils.formatVolume(exercise.totalVolume)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetHeader extends StatelessWidget {
  final String text;
  const _SetHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textHint,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SetCell extends StatelessWidget {
  final String text;
  const _SetCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

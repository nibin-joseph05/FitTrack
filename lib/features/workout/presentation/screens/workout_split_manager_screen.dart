import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_split_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/workout_split_entity.dart';
import '../../../../shared/widgets/split_card.dart';

class WorkoutSplitManagerScreen extends ConsumerWidget {
  const WorkoutSplitManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splitsAsync = ref.watch(workoutSplitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Splits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createSplit);
            },
          ),
        ],
      ),
      body: splitsAsync.when(
        data: (splits) {
          if (splits.isEmpty) {
            return const Center(child: Text('No workout splits created yet.'));
          }
          return ListView.builder(
            itemCount: splits.length,
            itemBuilder: (context, index) {
              final split = splits[index];
              return SplitCard(
                split: split,
                onTap: () {
                  _startWorkoutFromSplit(context, ref, split);
                },
                onEdit: () {
                  Navigator.pushNamed(context, AppRoutes.createSplit,
                      arguments: split);
                },
                onDelete: () {
                  ref.read(workoutSplitProvider.notifier).deleteSplit(split.id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _startWorkoutFromSplit(
      BuildContext context, WidgetRef ref, WorkoutSplitEntity split) {
    if (split.exerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add exercises to this split first!')));
      return;
    }
    Navigator.pushNamed(context, AppRoutes.workoutLog, arguments: split);
  }
}

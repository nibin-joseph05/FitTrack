import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_split_provider.dart';
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
            onPressed: () {},
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
                onTap: () {},
                onEdit: () {},
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
}

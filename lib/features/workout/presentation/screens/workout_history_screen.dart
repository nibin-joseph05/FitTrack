import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/workout_card.dart';
import '../providers/workout_provider.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: workouts.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history,
              title: 'No Workouts Yet',
              subtitle: 'Your completed workouts will appear here',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final w = list[index];
              return Dismissible(
                key: Key(w.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.cardDark,
                      title: const Text('Delete Workout?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) => ref
                    .read(workoutHistoryProvider.notifier)
                    .deleteWorkout(w.id),
                child: WorkoutCard(
                  title: w.title,
                  date: w.date,
                  exerciseCount: w.exercises.length,
                  totalSets: w.totalSets,
                  totalVolume: w.totalVolume,
                  duration: w.duration,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.workoutDetail,
                    arguments: w.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

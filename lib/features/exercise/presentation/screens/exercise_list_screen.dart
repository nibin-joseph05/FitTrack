import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_filter_chip.dart';
import '../widgets/muscle_group_badge.dart';

class ExerciseListScreen extends ConsumerWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(filteredExercisesProvider);
    final selectedFilter = ref.watch(exerciseFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createExercise),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(selectedFilter: selectedFilter),
          Expanded(
            child: exercises.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.fitness_center,
                    title: 'No Exercises',
                    subtitle: 'Add your first exercise to get started',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final exercise = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ExerciseListTile(
                        name: exercise.name,
                        muscleGroup: exercise.muscleGroup,
                        category: exercise.category,
                        isCustom: exercise.isCustom,
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.cardDark,
                              title: const Text('Delete Exercise?'),
                              content: Text(
                                'Delete "${exercise.name}"? This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                          if (confirm == true) {
                            ref
                                .read(exerciseProvider.notifier)
                                .deleteExercise(exercise.id);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createExercise),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Exercise',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final String selectedFilter;
  const _FilterBar({required this.selectedFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ['All', ...AppConstants.muscleGroups];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = filters[i];
          final selected = selectedFilter == filter;
          return ExerciseFilterChip(
            label: filter,
            selected: selected,
            onTap: () =>
                ref.read(exerciseFilterProvider.notifier).state = filter,
          );
        },
      ),
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  final String name;
  final String muscleGroup;
  final String category;
  final bool isCustom;
  final VoidCallback onDelete;

  const _ExerciseListTile({
    required this.name,
    required this.muscleGroup,
    required this.category,
    required this.isCustom,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isCustom)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Custom',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    MuscleGroupBadge(muscleGroup: muscleGroup),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCustom)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/workout_provider.dart';
import '../../domain/entities/workout_entities.dart';
import '../../../exercise/presentation/providers/exercise_provider.dart';
import '../../../exercise/domain/entities/exercise_entity.dart';
import '../widgets/set_input_row.dart';

class WorkoutLogScreen extends ConsumerStatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  ConsumerState<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends ConsumerState<WorkoutLogScreen> {
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final active = ref.read(activeWorkoutProvider);
    if (active != null) {
      _titleController.text = active.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _startWorkout() {
    final title = _titleController.text.trim().isEmpty
        ? 'Morning Workout'
        : _titleController.text.trim();
    ref.read(activeWorkoutProvider.notifier).startWorkout(title);
  }

  Future<void> _addExercise() async {
    final exercises = await ref.read(exerciseProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<ExerciseEntity>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _ExercisePickerSheet(exercises: exercises),
    );
    if (selected != null) {
      final exercise = WorkoutExerciseEntity(
        exerciseId: selected.id,
        exerciseName: selected.name,
        muscleGroup: selected.muscleGroup,
        sets: [
          const WorkoutSetEntity(
            setNumber: 1,
            targetReps: 10,
            completedReps: 0,
            weight: 0,
            isCompleted: false,
          ),
        ],
      );
      ref.read(activeWorkoutProvider.notifier).addExercise(exercise);
    }
  }

  Future<void> _finishWorkout() async {
    final active = ref.read(activeWorkoutProvider);
    if (active == null || active.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise!')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Finish Workout?'),
        content: Text(
          '${active.exercises.length} exercises • ${active.totalSets} sets • ${FormatUtils.formatVolume(active.totalVolume)} volume',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(activeWorkoutProvider.notifier).finishWorkout();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeWorkoutProvider);

    if (active == null) {
      return _StartWorkoutView(
        controller: _titleController,
        onStart: _startWorkout,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.cardDark,
            title: const Text('Discard Workout?'),
            content: const Text('Your workout progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Discard',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
        if (discard == true) {
          ref.read(activeWorkoutProvider.notifier).discardWorkout();
          if (mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(active.title),
          actions: [
            TextButton(
              onPressed: _finishWorkout,
              child: const Text(
                'Finish',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _WorkoutStatBar(
              exercises: active.exercises.length,
              sets: active.totalSets,
              volume: active.totalVolume,
            ),
            Expanded(
              child: active.exercises.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.add_circle_outline,
                      title: 'Add Exercises',
                      subtitle:
                          'Tap the button below to add exercises to your workout',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: active.exercises.length,
                      itemBuilder: (context, index) {
                        return _ExerciseCard(
                          exercise: active.exercises[index],
                          exerciseIndex: index,
                          onRemove: () => ref
                              .read(activeWorkoutProvider.notifier)
                              .removeExercise(index),
                          onSetsChanged: (sets) => ref
                              .read(activeWorkoutProvider.notifier)
                              .updateExerciseSets(index, sets),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addExercise,
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Exercise',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _StartWorkoutView extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onStart;

  const _StartWorkoutView({required this.controller, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workout Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Morning Workout',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Start Workout',
              icon: Icons.play_arrow_rounded,
              width: double.infinity,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutStatBar extends StatelessWidget {
  final int exercises;
  final int sets;
  final double volume;

  const _WorkoutStatBar({
    required this.exercises,
    required this.sets,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        border: Border(bottom: BorderSide(color: AppColors.borderDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '$exercises', label: 'Exercises'),
          _Divider(),
          _StatItem(value: '$sets', label: 'Sets'),
          _Divider(),
          _StatItem(value: FormatUtils.formatVolume(volume), label: 'Volume'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: AppColors.borderDark);
  }
}

class _ExerciseCard extends ConsumerStatefulWidget {
  final WorkoutExerciseEntity exercise;
  final int exerciseIndex;
  final VoidCallback onRemove;
  final ValueChanged<List<WorkoutSetEntity>> onSetsChanged;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.onRemove,
    required this.onSetsChanged,
  });

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  void _addSet() {
    final newSets = [
      ...widget.exercise.sets,
      WorkoutSetEntity(
        setNumber: widget.exercise.sets.length + 1,
        targetReps: widget.exercise.sets.isNotEmpty
            ? widget.exercise.sets.last.targetReps
            : 10,
        completedReps: 0,
        weight: widget.exercise.sets.isNotEmpty
            ? widget.exercise.sets.last.weight
            : 0,
        isCompleted: false,
      ),
    ];
    widget.onSetsChanged(newSets);
  }

  void _removeSet(int index) {
    final newSets = [...widget.exercise.sets];
    newSets.removeAt(index);
    widget.onSetsChanged(
      newSets
          .asMap()
          .entries
          .map((e) => e.value.copyWith(setNumber: e.key + 1))
          .toList(),
    );
  }

  void _updateSet(int index, WorkoutSetEntity updated) {
    final newSets = [...widget.exercise.sets];
    newSets[index] = updated;
    widget.onSetsChanged(newSets);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.exerciseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.exercise.muscleGroup,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textHint,
                ),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              SizedBox(width: 32),
              Expanded(child: _ColLabel('REPS')),
              Expanded(child: _ColLabel('WEIGHT (kg)')),
              SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 4),
          ...widget.exercise.sets.asMap().entries.map(
                (entry) => SetInputRow(
                  set: entry.value,
                  onRemove: () => _removeSet(entry.key),
                  onChanged: (updated) => _updateSet(entry.key, updated),
                ),
              ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addSet,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Set'),
          ),
        ],
      ),
    );
  }
}

class _ColLabel extends StatelessWidget {
  final String text;
  const _ColLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.textHint,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ExercisePickerSheet extends StatefulWidget {
  final List<ExerciseEntity> exercises;
  const _ExercisePickerSheet({required this.exercises});

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _query = '';

  List<ExerciseEntity> get _filtered => widget.exercises
      .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final e = _filtered[i];
                  return ListTile(
                    tileColor: AppColors.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      e.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      e.muscleGroup,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                    onTap: () => Navigator.pop(context, e),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

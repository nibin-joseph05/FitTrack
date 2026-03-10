import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_split_entity.dart';
import '../providers/workout_split_provider.dart';
import '../../../exercise/presentation/providers/exercise_provider.dart';
import '../../../../shared/widgets/exercise_picker_sheet.dart';
import '../../../../core/theme/app_colors.dart';

class CreateWorkoutSplitScreen extends ConsumerStatefulWidget {
  final WorkoutSplitEntity? existingSplit;
  const CreateWorkoutSplitScreen({super.key, this.existingSplit});

  @override
  ConsumerState<CreateWorkoutSplitScreen> createState() =>
      _CreateWorkoutSplitScreenState();
}

class _CreateWorkoutSplitScreenState
    extends ConsumerState<CreateWorkoutSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  int? _dayOfWeek;
  List<String> _exerciseIds = [];

  final _days = [
    {'value': null, 'label': 'Any Day'},
    {'value': 1, 'label': 'Monday'},
    {'value': 2, 'label': 'Tuesday'},
    {'value': 3, 'label': 'Wednesday'},
    {'value': 4, 'label': 'Thursday'},
    {'value': 5, 'label': 'Friday'},
    {'value': 6, 'label': 'Saturday'},
    {'value': 7, 'label': 'Sunday'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingSplit != null) {
      final s = widget.existingSplit!;
      _nameController.text = s.name;
      _notesController.text = s.notes ?? '';
      _dayOfWeek = s.dayOfWeek;
      _exerciseIds = List.from(s.exerciseIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.existingSplit != null) {
        final updated = widget.existingSplit!.copyWith(
          name: _nameController.text.trim(),
          dayOfWeek: _dayOfWeek,
          notes: _notesController.text.trim(),
          exerciseIds: _exerciseIds,
        );
        ref.read(workoutSplitProvider.notifier).updateSplit(updated);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Split updated')));
      } else {
        ref.read(workoutSplitProvider.notifier).createSplit(
              name: _nameController.text.trim(),
              dayOfWeek: _dayOfWeek,
              notes: _notesController.text.trim(),
              exerciseIds: _exerciseIds,
            );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Split created')));
      }
      Navigator.pop(context);
    }
  }

  Future<void> _pickExercises() async {
    final exercises = await ref.read(exerciseProvider.future);
    if (!mounted) return;

    final selected = await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => ExercisePickerSheet(exercises: exercises),
    );

    if (selected != null) {
      setState(() {
        _exerciseIds.add(selected.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existingSplit == null ? 'Create Split' : 'Edit Split'),
        actions: [
          TextButton(onPressed: _submit, child: const Text('SAVE')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Split Name*', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _dayOfWeek,
              decoration: const InputDecoration(
                  labelText: 'Day of Week', border: OutlineInputBorder()),
              items: _days
                  .map((d) => DropdownMenuItem(
                      value: d['value'] as int?,
                      child: Text(d['label'] as String)))
                  .toList(),
              onChanged: (v) => setState(() => _dayOfWeek = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                  labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Exercises',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                    onPressed: _pickExercises,
                    icon: const Icon(Icons.add),
                    label: const Text('Add')),
              ],
            ),
            const SizedBox(height: 8),
            if (_exerciseIds.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No exercises added.',
                          style: TextStyle(color: Colors.grey)))),
            ..._exerciseIds.asMap().entries.map((entry) {
              final idx = entry.key;
              final eid = entry.value;
              return exercisesAsync.maybeWhen(
                data: (exercises) {
                  final ex = exercises.firstWhere((e) => e.id == eid);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(ex.name),
                      subtitle: Text(ex.muscleGroup),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            setState(() => _exerciseIds.removeAt(idx)),
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

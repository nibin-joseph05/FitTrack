import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exercise_provider.dart';

class CreateCustomExerciseScreen extends ConsumerStatefulWidget {
  const CreateCustomExerciseScreen({super.key});

  @override
  ConsumerState<CreateCustomExerciseScreen> createState() =>
      _CreateCustomExerciseScreenState();
}

class _CreateCustomExerciseScreenState
    extends ConsumerState<CreateCustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();

  String _muscleGroup = 'Chest';
  String? _secondaryMuscleGroup;
  String _category = 'Strength';
  String _equipmentType = 'Bodyweight';
  String _difficulty = 'Beginner';

  final _muscles = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
    'Full Body'
  ];
  final _types = ['Strength', 'Cardio', 'Mobility', 'Timer Based'];
  final _equipment = [
    'Bodyweight',
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Kettlebell',
    'Band'
  ];
  final _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(exerciseProvider.notifier).createExercise(
            name: _nameController.text.trim(),
            muscleGroup: _muscleGroup,
            secondaryMuscleGroup: _secondaryMuscleGroup,
            category: _category,
            exerciseType: _category,
            equipmentType: _equipmentType,
            difficulty: _difficulty,
            instructions: _instructionsController.text.trim(),
            notes: _notesController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise created successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exercise'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('SAVE'),
          ),
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
                  labelText: 'Exercise Name*', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _muscleGroup,
              decoration: const InputDecoration(
                  labelText: 'Primary Muscle Group*',
                  border: OutlineInputBorder()),
              items: _muscles
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _muscleGroup = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _secondaryMuscleGroup,
              decoration: const InputDecoration(
                  labelText: 'Secondary Muscle Group',
                  border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<String>(
                    value: null, child: Text('None')),
                ..._muscles
                    .map((m) => DropdownMenuItem(value: m, child: Text(m))),
              ],
              onChanged: (v) => setState(() => _secondaryMuscleGroup = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                        labelText: 'Exercise Type*',
                        border: OutlineInputBorder()),
                    items: _types
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _equipmentType,
                    decoration: const InputDecoration(
                        labelText: 'Equipment*', border: OutlineInputBorder()),
                    items: _equipment
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _equipmentType = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              decoration: const InputDecoration(
                  labelText: 'Difficulty*', border: OutlineInputBorder()),
              items: _difficulties
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                  labelText: 'Instructions', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                  labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

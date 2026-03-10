import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/exercise_provider.dart';

import '../../domain/entities/exercise_entity.dart';

class CreateCustomExerciseScreen extends ConsumerStatefulWidget {
  final dynamic existingExercise;

  const CreateCustomExerciseScreen({super.key, this.existingExercise});

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
  File? _selectedImage;

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
  void initState() {
    super.initState();
    if (widget.existingExercise != null &&
        widget.existingExercise is ExerciseEntity) {
      final e = widget.existingExercise as ExerciseEntity;
      _nameController.text = e.name;
      _instructionsController.text = e.instructions ?? '';
      _notesController.text = e.notes ?? '';
      _muscleGroup = e.muscleGroup;
      _secondaryMuscleGroup = e.secondaryMuscleGroup;
      _category = e.category;
      _equipmentType = e.equipmentType ?? 'Bodyweight';
      if (e.difficulty != null && _difficulties.contains(e.difficulty)) {
        _difficulty = e.difficulty!;
      }
      if (e.imagePath != null && e.imagePath!.isNotEmpty) {
        _selectedImage = File(e.imagePath!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String? savedImagePath;

      if (_selectedImage != null) {
        try {
          final docDir = await getApplicationDocumentsDirectory();
          final fileName =
              'exercise_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final localImage =
              await _selectedImage!.copy('${docDir.path}/$fileName');
          savedImagePath = localImage.path;
        } catch (e) {
          debugPrint('Failed to save image locally: $e');
        }
      }

      if (widget.existingExercise != null &&
          widget.existingExercise is ExerciseEntity) {
        ref.read(exerciseProvider.notifier).updateExercise(
              widget.existingExercise as ExerciseEntity,
              name: _nameController.text.trim(),
              muscleGroup: _muscleGroup,
              secondaryMuscleGroup: _secondaryMuscleGroup,
              category: _category,
              exerciseType: _category,
              equipmentType: _equipmentType,
              difficulty: _difficulty,
              instructions: _instructionsController.text.trim(),
              notes: _notesController.text.trim(),
              imagePath: savedImagePath ??
                  (widget.existingExercise as ExerciseEntity).imagePath,
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise updated successfully')),
        );
      } else {
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
              imagePath: savedImagePath,
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise created successfully')),
        );
      }
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
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Optional: Select Exercise Image',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

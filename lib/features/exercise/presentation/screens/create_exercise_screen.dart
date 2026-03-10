import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/exercise_provider.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedMuscleGroup = AppConstants.muscleGroups.first;
  String _selectedCategory = AppConstants.exerciseCategories.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(exerciseProvider.notifier)
          .createExercise(
            name: _nameController.text.trim(),
            muscleGroup: _selectedMuscleGroup,
            category: _selectedCategory,
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exercise'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Exercise Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g. Bench Press',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2) return 'Name too short';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'How to perform this exercise...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Muscle Group'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.muscleGroups.map((group) {
                final selected = _selectedMuscleGroup == group;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMuscleGroup = group),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.borderDark,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      group,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Category'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.exerciseCategories.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent.withOpacity(0.12)
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent
                            : AppColors.borderDark,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

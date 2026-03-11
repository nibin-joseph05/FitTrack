import 'package:flutter/material.dart';
import '../../features/exercise/domain/entities/exercise_entity.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';

class ExercisePickerSheet extends StatefulWidget {
  final List<ExerciseEntity> exercises;
  const ExercisePickerSheet({super.key, required this.exercises});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
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
                itemCount: _filtered.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return ListTile(
                      tileColor: AppColors.primary.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                      ),
                      leading: const Icon(Icons.add_circle, color: AppColors.primary),
                      title: const Text(
                        'Create Custom Exercise',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      onTap: () async {
                        final newExercise = await Navigator.pushNamed(context, AppRoutes.createExercise);
                        if (newExercise != null && newExercise is ExerciseEntity && context.mounted) {
                          Navigator.pop(context, newExercise);
                        }
                      },
                    );
                  }
                  final e = _filtered[i - 1];
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

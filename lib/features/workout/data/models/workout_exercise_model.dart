import 'package:hive/hive.dart';
import 'workout_set_model.dart';
import '../../../../core/constants/hive_boxes.dart';

part 'workout_exercise_model.g.dart';

@HiveType(typeId: HiveTypeIds.workoutExerciseModel)
class WorkoutExerciseModel extends HiveObject {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final String exerciseName;

  @HiveField(2)
  final String muscleGroup;

  @HiveField(3)
  final List<WorkoutSetModel> sets;

  @HiveField(4)
  final String? notes;

  WorkoutExerciseModel({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    this.notes,
  });

  double get totalVolume =>
      sets.fold(0, (sum, s) => sum + (s.completedReps * s.weight));

  int get totalSets => sets.length;

  double get maxWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
}

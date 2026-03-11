import 'package:hive/hive.dart';
import 'workout_exercise_model.dart';
import '../../../../core/constants/hive_boxes.dart';

part 'workout_log_model.g.dart';

@HiveType(typeId: HiveTypeIds.workoutLogModel)
class WorkoutLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final List<WorkoutExerciseModel> exercises;

  @HiveField(4)
  final int durationSeconds;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? imagePath;

  WorkoutLogModel({
    required this.id,
    required this.title,
    required this.date,
    required this.exercises,
    required this.durationSeconds,
    this.notes,
    this.imagePath,
  });

  double get totalVolume => exercises.fold(0, (sum, e) => sum + e.totalVolume);

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.totalSets);

  Duration get duration => Duration(seconds: durationSeconds);
}

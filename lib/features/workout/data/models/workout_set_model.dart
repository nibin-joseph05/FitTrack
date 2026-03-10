import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';

part 'workout_set_model.g.dart';

@HiveType(typeId: HiveTypeIds.workoutSetModel)
class WorkoutSetModel extends HiveObject {
  @HiveField(0)
  final int setNumber;

  @HiveField(1)
  final int targetReps;

  @HiveField(2)
  final int completedReps;

  @HiveField(3)
  final double weight;

  @HiveField(4)
  final int? rir;

  @HiveField(5)
  final int? rpe;

  @HiveField(6)
  final int? restTimeSeconds;

  @HiveField(7)
  final bool isCompleted;

  WorkoutSetModel({
    required this.setNumber,
    required this.targetReps,
    required this.completedReps,
    required this.weight,
    this.rir,
    this.rpe,
    this.restTimeSeconds,
    required this.isCompleted,
  });
}

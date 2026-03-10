import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';

part 'workout_set_model.g.dart';

@HiveType(typeId: HiveTypeIds.workoutSetModel)
class WorkoutSetModel extends HiveObject {
  @HiveField(0)
  final int setNumber;

  @HiveField(1)
  final int reps;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final bool isCompleted;

  WorkoutSetModel({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.isCompleted,
  });
}

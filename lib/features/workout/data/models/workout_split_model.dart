import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../../domain/entities/workout_split_entity.dart';

part 'workout_split_model.g.dart';

@HiveType(typeId: HiveTypeIds.workoutSplitModel)
class WorkoutSplitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> exerciseIds;

  @HiveField(3)
  final int? dayOfWeek;

  @HiveField(4)
  final String? notes;

  WorkoutSplitModel({
    required this.id,
    required this.name,
    required this.exerciseIds,
    this.dayOfWeek,
    this.notes,
  });

  WorkoutSplitEntity toEntity() {
    return WorkoutSplitEntity(
      id: id,
      name: name,
      exerciseIds: exerciseIds,
      dayOfWeek: dayOfWeek,
      notes: notes,
    );
  }

  factory WorkoutSplitModel.fromEntity(WorkoutSplitEntity entity) {
    return WorkoutSplitModel(
      id: entity.id,
      name: entity.name,
      exerciseIds: entity.exerciseIds,
      dayOfWeek: entity.dayOfWeek,
      notes: entity.notes,
    );
  }
}

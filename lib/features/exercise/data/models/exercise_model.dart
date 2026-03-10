import 'package:hive/hive.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../../../core/constants/hive_boxes.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: HiveTypeIds.exerciseModel)
class ExerciseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String muscleGroup;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool isCustom;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.category,
    this.description,
    required this.createdAt,
    required this.isCustom,
  });

  ExerciseEntity toEntity() {
    return ExerciseEntity(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      category: category,
      description: description,
      createdAt: createdAt,
      isCustom: isCustom,
    );
  }

  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      muscleGroup: entity.muscleGroup,
      category: entity.category,
      description: entity.description,
      createdAt: entity.createdAt,
      isCustom: entity.isCustom,
    );
  }
}

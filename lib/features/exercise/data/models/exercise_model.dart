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

  @HiveField(7)
  final String? secondaryMuscleGroup;

  @HiveField(8)
  final String? exerciseType;

  @HiveField(9)
  final String? equipmentType;

  @HiveField(10)
  final String? difficulty;

  @HiveField(11)
  final String? instructions;

  @HiveField(12)
  final String? notes;

  @HiveField(13)
  final String? imagePath;

  @HiveField(14)
  final String? videoUrl;

  @HiveField(15)
  final bool isFavorite;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.category,
    this.description,
    required this.createdAt,
    required this.isCustom,
    this.secondaryMuscleGroup,
    this.exerciseType,
    this.equipmentType,
    this.difficulty,
    this.instructions,
    this.notes,
    this.imagePath,
    this.videoUrl,
    this.isFavorite = false,
  });

  ExerciseEntity toEntity() {
    return ExerciseEntity(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup,
      exerciseType: exerciseType,
      equipmentType: equipmentType,
      difficulty: difficulty,
      instructions: instructions,
      notes: notes,
      imagePath: imagePath,
      videoUrl: videoUrl,
      isFavorite: isFavorite,
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
      secondaryMuscleGroup: entity.secondaryMuscleGroup,
      exerciseType: entity.exerciseType,
      equipmentType: entity.equipmentType,
      difficulty: entity.difficulty,
      instructions: entity.instructions,
      notes: entity.notes,
      imagePath: entity.imagePath,
      videoUrl: entity.videoUrl,
      isFavorite: entity.isFavorite,
    );
  }
}

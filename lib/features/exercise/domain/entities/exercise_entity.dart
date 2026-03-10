class ExerciseEntity {
  final String id;
  final String name;
  final String muscleGroup;
  final String? secondaryMuscleGroup;
  final String? exerciseType;
  final String? equipmentType;
  final String? difficulty;
  final String? instructions;
  final String? notes;
  final String? imagePath;
  final String? videoUrl;
  final bool isFavorite;
  final String category;
  final String? description;
  final DateTime createdAt;
  final bool isCustom;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    this.exerciseType,
    this.equipmentType,
    this.difficulty,
    this.instructions,
    this.notes,
    this.imagePath,
    this.videoUrl,
    this.isFavorite = false,
    required this.category,
    this.description,
    required this.createdAt,
    required this.isCustom,
  });

  ExerciseEntity copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? secondaryMuscleGroup,
    String? exerciseType,
    String? equipmentType,
    String? difficulty,
    String? instructions,
    String? notes,
    String? imagePath,
    String? videoUrl,
    bool? isFavorite,
    String? category,
    String? description,
    DateTime? createdAt,
    bool? isCustom,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup ?? this.secondaryMuscleGroup,
      exerciseType: exerciseType ?? this.exerciseType,
      equipmentType: equipmentType ?? this.equipmentType,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      videoUrl: videoUrl ?? this.videoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExerciseEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

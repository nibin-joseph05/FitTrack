class ExerciseEntity {
  final String id;
  final String name;
  final String muscleGroup;
  final String category;
  final String? description;
  final DateTime createdAt;
  final bool isCustom;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.category,
    this.description,
    required this.createdAt,
    required this.isCustom,
  });

  ExerciseEntity copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? category,
    String? description,
    DateTime? createdAt,
    bool? isCustom,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
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

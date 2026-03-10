class WorkoutSplitEntity {
  final String id;
  final String name;
  final List<String> exerciseIds;
  final int? dayOfWeek;
  final String? notes;

  const WorkoutSplitEntity({
    required this.id,
    required this.name,
    required this.exerciseIds,
    this.dayOfWeek,
    this.notes,
  });

  WorkoutSplitEntity copyWith({
    String? id,
    String? name,
    List<String>? exerciseIds,
    int? dayOfWeek,
    String? notes,
  }) {
    return WorkoutSplitEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkoutSplitEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

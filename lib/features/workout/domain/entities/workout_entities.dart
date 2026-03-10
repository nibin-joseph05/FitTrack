class WorkoutSetEntity {
  final int setNumber;
  final int reps;
  final double weight;
  final bool isCompleted;

  const WorkoutSetEntity({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.isCompleted,
  });

  WorkoutSetEntity copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    bool? isCompleted,
  }) {
    return WorkoutSetEntity(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get volume => reps * weight;
}

class WorkoutExerciseEntity {
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final List<WorkoutSetEntity> sets;
  final String? notes;

  const WorkoutExerciseEntity({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    this.notes,
  });

  double get totalVolume => sets.fold(0, (sum, s) => sum + s.volume);
  int get totalSets => sets.length;
  double get maxWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  WorkoutExerciseEntity copyWith({
    List<WorkoutSetEntity>? sets,
    String? notes,
  }) {
    return WorkoutExerciseEntity(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }
}

class WorkoutLogEntity {
  final String id;
  final String title;
  final DateTime date;
  final List<WorkoutExerciseEntity> exercises;
  final int durationSeconds;
  final String? notes;

  const WorkoutLogEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.exercises,
    required this.durationSeconds,
    this.notes,
  });

  double get totalVolume => exercises.fold(0, (sum, e) => sum + e.totalVolume);
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.totalSets);
  Duration get duration => Duration(seconds: durationSeconds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkoutLogEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

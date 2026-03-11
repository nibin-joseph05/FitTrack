class WorkoutSetEntity {
  final int setNumber;
  final int targetReps;
  final int completedReps;
  final double weight;
  final int? rir;
  final int? rpe;
  final int? restTimeSeconds;
  final bool isCompleted;

  const WorkoutSetEntity({
    required this.setNumber,
    required this.targetReps,
    required this.completedReps,
    required this.weight,
    this.rir,
    this.rpe,
    this.restTimeSeconds,
    required this.isCompleted,
  });

  WorkoutSetEntity copyWith({
    int? setNumber,
    int? targetReps,
    int? completedReps,
    double? weight,
    int? rir,
    int? rpe,
    int? restTimeSeconds,
    bool? isCompleted,
  }) {
    return WorkoutSetEntity(
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      completedReps: completedReps ?? this.completedReps,
      weight: weight ?? this.weight,
      rir: rir ?? this.rir,
      rpe: rpe ?? this.rpe,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get volume => completedReps * weight;
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
  final String? imagePath;

  const WorkoutLogEntity({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkoutLogEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

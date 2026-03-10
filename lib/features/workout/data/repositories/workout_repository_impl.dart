import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_log_model.dart';
import '../models/workout_exercise_model.dart';
import '../models/workout_set_model.dart';
import '../../domain/entities/workout_entities.dart';
import '../../../../core/constants/hive_boxes.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutLogEntity>> getAllWorkouts();
  Future<WorkoutLogEntity?> getWorkoutById(String id);
  Future<void> saveWorkout(WorkoutLogEntity workout);
  Future<void> deleteWorkout(String id);
  Future<List<WorkoutLogEntity>> getWorkoutsForDateRange(
    DateTime start,
    DateTime end,
  );
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  Box<WorkoutLogModel> get _box =>
      Hive.box<WorkoutLogModel>(HiveBoxes.workoutLogs);

  WorkoutLogModel _toModel(WorkoutLogEntity entity) {
    return WorkoutLogModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      durationSeconds: entity.durationSeconds,
      notes: entity.notes,
      exercises: entity.exercises.map((e) {
        return WorkoutExerciseModel(
          exerciseId: e.exerciseId,
          exerciseName: e.exerciseName,
          muscleGroup: e.muscleGroup,
          notes: e.notes,
          sets: e.sets.map((s) {
            return WorkoutSetModel(
              setNumber: s.setNumber,
              reps: s.reps,
              weight: s.weight,
              isCompleted: s.isCompleted,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  WorkoutLogEntity _toEntity(WorkoutLogModel model) {
    return WorkoutLogEntity(
      id: model.id,
      title: model.title,
      date: model.date,
      durationSeconds: model.durationSeconds,
      notes: model.notes,
      exercises: model.exercises.map((e) {
        return WorkoutExerciseEntity(
          exerciseId: e.exerciseId,
          exerciseName: e.exerciseName,
          muscleGroup: e.muscleGroup,
          notes: e.notes,
          sets: e.sets.map((s) {
            return WorkoutSetEntity(
              setNumber: s.setNumber,
              reps: s.reps,
              weight: s.weight,
              isCompleted: s.isCompleted,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Future<List<WorkoutLogEntity>> getAllWorkouts() async {
    final list = _box.values.map(_toEntity).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<WorkoutLogEntity?> getWorkoutById(String id) async {
    final model = _box.get(id);
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<void> saveWorkout(WorkoutLogEntity workout) async {
    await _box.put(workout.id, _toModel(workout));
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<WorkoutLogEntity>> getWorkoutsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final all = await getAllWorkouts();
    return all
        .where(
          (w) =>
              w.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              w.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }
}

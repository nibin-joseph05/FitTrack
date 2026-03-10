import '../entities/workout_entities.dart';
import '../../data/repositories/workout_repository_impl.dart';

class SaveWorkoutUseCase {
  final WorkoutRepository _repository;
  SaveWorkoutUseCase(this._repository);
  Future<void> call(WorkoutLogEntity workout) =>
      _repository.saveWorkout(workout);
}

class GetWorkoutsUseCase {
  final WorkoutRepository _repository;
  GetWorkoutsUseCase(this._repository);
  Future<List<WorkoutLogEntity>> call() => _repository.getAllWorkouts();
}

class GetWorkoutByIdUseCase {
  final WorkoutRepository _repository;
  GetWorkoutByIdUseCase(this._repository);
  Future<WorkoutLogEntity?> call(String id) => _repository.getWorkoutById(id);
}

class DeleteWorkoutUseCase {
  final WorkoutRepository _repository;
  DeleteWorkoutUseCase(this._repository);
  Future<void> call(String id) => _repository.deleteWorkout(id);
}

class GetWorkoutsForRangeUseCase {
  final WorkoutRepository _repository;
  GetWorkoutsForRangeUseCase(this._repository);
  Future<List<WorkoutLogEntity>> call(DateTime start, DateTime end) =>
      _repository.getWorkoutsForDateRange(start, end);
}

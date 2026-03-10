import '../entities/exercise_entity.dart';
import '../../data/repositories/exercise_repository_impl.dart';

class GetExercisesUseCase {
  final ExerciseRepository _repository;

  GetExercisesUseCase(this._repository);

  Future<List<ExerciseEntity>> call() => _repository.getAllExercises();
}

class CreateExerciseUseCase {
  final ExerciseRepository _repository;

  CreateExerciseUseCase(this._repository);

  Future<void> call(ExerciseEntity exercise) =>
      _repository.saveExercise(exercise);
}

class DeleteExerciseUseCase {
  final ExerciseRepository _repository;

  DeleteExerciseUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteExercise(id);
}

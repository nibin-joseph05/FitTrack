import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/usecases/exercise_usecases.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl();
});

final getExercisesUseCaseProvider = Provider<GetExercisesUseCase>((ref) {
  return GetExercisesUseCase(ref.read(exerciseRepositoryProvider));
});

final createExerciseUseCaseProvider = Provider<CreateExerciseUseCase>((ref) {
  return CreateExerciseUseCase(ref.read(exerciseRepositoryProvider));
});

final deleteExerciseUseCaseProvider = Provider<DeleteExerciseUseCase>((ref) {
  return DeleteExerciseUseCase(ref.read(exerciseRepositoryProvider));
});

class ExerciseNotifier extends AsyncNotifier<List<ExerciseEntity>> {
  @override
  Future<List<ExerciseEntity>> build() async {
    return ref.read(getExercisesUseCaseProvider).call();
  }

  Future<void> createExercise({
    required String name,
    required String muscleGroup,
    required String category,
    String? description,
  }) async {
    const uuid = Uuid();
    final exercise = ExerciseEntity(
      id: uuid.v4(),
      name: name,
      muscleGroup: muscleGroup,
      category: category,
      description: description,
      createdAt: DateTime.now(),
      isCustom: true,
    );
    await ref.read(createExerciseUseCaseProvider).call(exercise);
    ref.invalidateSelf();
  }

  Future<void> deleteExercise(String id) async {
    await ref.read(deleteExerciseUseCaseProvider).call(id);
    ref.invalidateSelf();
  }
}

final exerciseProvider =
    AsyncNotifierProvider<ExerciseNotifier, List<ExerciseEntity>>(
      ExerciseNotifier.new,
    );

final exerciseFilterProvider = StateProvider<String>((ref) => 'All');

final filteredExercisesProvider = Provider<AsyncValue<List<ExerciseEntity>>>((
  ref,
) {
  final exercises = ref.watch(exerciseProvider);
  final filter = ref.watch(exerciseFilterProvider);
  return exercises.whenData((list) {
    if (filter == 'All') return list;
    return list.where((e) => e.muscleGroup == filter).toList();
  });
});

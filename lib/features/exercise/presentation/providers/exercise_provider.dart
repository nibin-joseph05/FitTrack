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
    String? secondaryMuscleGroup,
    String? exerciseType,
    String? equipmentType,
    String? difficulty,
    String? instructions,
    String? notes,
    String? imagePath,
    String? videoUrl,
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
      secondaryMuscleGroup: secondaryMuscleGroup,
      exerciseType: exerciseType,
      equipmentType: equipmentType,
      difficulty: difficulty,
      instructions: instructions,
      notes: notes,
      imagePath: imagePath,
      videoUrl: videoUrl,
      isFavorite: false,
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
final exerciseEquipmentFilterProvider = StateProvider<String?>((ref) => null);
final exerciseTypeFilterProvider = StateProvider<String?>((ref) => null);
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = Provider<AsyncValue<List<ExerciseEntity>>>((
  ref,
) {
  final exercises = ref.watch(exerciseProvider);
  final filter = ref.watch(exerciseFilterProvider);
  final equipmentFilter = ref.watch(exerciseEquipmentFilterProvider);
  final typeFilter = ref.watch(exerciseTypeFilterProvider);
  final search = ref.watch(exerciseSearchQueryProvider).toLowerCase();

  return exercises.whenData((list) {
    var filtered = list;

    if (filter != 'All') {
      filtered = filtered.where((e) => e.muscleGroup == filter).toList();
    }

    if (equipmentFilter != null && equipmentFilter != 'All') {
      filtered =
          filtered.where((e) => e.equipmentType == equipmentFilter).toList();
    }

    if (typeFilter != null && typeFilter != 'All') {
      filtered = filtered.where((e) => e.exerciseType == typeFilter).toList();
    }

    if (search.isNotEmpty) {
      filtered =
          filtered.where((e) => e.name.toLowerCase().contains(search)).toList();
    }

    return filtered;
  });
});

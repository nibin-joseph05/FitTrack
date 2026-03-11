import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/workout_entities.dart';
import '../../domain/usecases/workout_usecases.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl();
});

final saveWorkoutUseCaseProvider = Provider<SaveWorkoutUseCase>((ref) {
  return SaveWorkoutUseCase(ref.read(workoutRepositoryProvider));
});

final getWorkoutsUseCaseProvider = Provider<GetWorkoutsUseCase>((ref) {
  return GetWorkoutsUseCase(ref.read(workoutRepositoryProvider));
});

final deleteWorkoutUseCaseProvider = Provider<DeleteWorkoutUseCase>((ref) {
  return DeleteWorkoutUseCase(ref.read(workoutRepositoryProvider));
});

final getWorkoutsForRangeUseCaseProvider = Provider<GetWorkoutsForRangeUseCase>(
  (ref) {
    return GetWorkoutsForRangeUseCase(ref.read(workoutRepositoryProvider));
  },
);

class WorkoutHistoryNotifier extends AsyncNotifier<List<WorkoutLogEntity>> {
  @override
  Future<List<WorkoutLogEntity>> build() async {
    return ref.read(getWorkoutsUseCaseProvider).call();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> deleteWorkout(String id) async {
    await ref.read(deleteWorkoutUseCaseProvider).call(id);
    ref.invalidateSelf();
  }
}

final workoutHistoryProvider =
    AsyncNotifierProvider<WorkoutHistoryNotifier, List<WorkoutLogEntity>>(
  WorkoutHistoryNotifier.new,
);

class ActiveWorkoutState {
  final String title;
  final List<WorkoutExerciseEntity> exercises;
  final DateTime startTime;
  final bool isActive;
  final String? imagePath;

  const ActiveWorkoutState({
    required this.title,
    required this.exercises,
    required this.startTime,
    required this.isActive,
    this.imagePath,
  });

  ActiveWorkoutState copyWith({
    String? title,
    List<WorkoutExerciseEntity>? exercises,
    DateTime? startTime,
    bool? isActive,
    String? imagePath,
  }) {
    return ActiveWorkoutState(
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      startTime: startTime ?? this.startTime,
      isActive: isActive ?? this.isActive,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  double get totalVolume => exercises.fold(0, (sum, e) => sum + e.totalVolume);
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.totalSets);
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState?> {
  @override
  ActiveWorkoutState? build() => null;

  void startWorkout(String title) {
    state = ActiveWorkoutState(
      title: title,
      exercises: [],
      startTime: DateTime.now(),
      isActive: true,
    );
  }

  void addExercise(WorkoutExerciseEntity exercise) {
    if (state == null) return;
    state = state!.copyWith(exercises: [...state!.exercises, exercise]);
  }

  void removeExercise(int index) {
    if (state == null) return;
    final list = [...state!.exercises];
    list.removeAt(index);
    state = state!.copyWith(exercises: list);
  }

  void updateExerciseSets(int exerciseIndex, List<WorkoutSetEntity> sets) {
    if (state == null) return;
    final list = [...state!.exercises];
    list[exerciseIndex] = list[exerciseIndex].copyWith(sets: sets);
    state = state!.copyWith(exercises: list);
  }

  void updateTitle(String title) {
    if (state == null) return;
    state = state!.copyWith(title: title);
  }

  void setWorkoutImage(String path) {
    if (state == null) return;
    state = state!.copyWith(imagePath: path);
  }

  Future<void> finishWorkout({String? imagePath}) async {
    if (state == null || state!.exercises.isEmpty) return;
    const uuid = Uuid();
    final duration = DateTime.now().difference(state!.startTime);
    final workout = WorkoutLogEntity(
      id: uuid.v4(),
      title: state!.title,
      date: state!.startTime,
      exercises: state!.exercises,
      durationSeconds: duration.inSeconds,
      imagePath: imagePath ?? state!.imagePath,
    );
    await ref.read(saveWorkoutUseCaseProvider).call(workout);
    ref.invalidate(workoutHistoryProvider);
    state = null;
  }

  void discardWorkout() {
    state = null;
  }
}

final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState?>(
  ActiveWorkoutNotifier.new,
);

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  DateTimeRange({required this.start, required this.end});
}

final workoutDateFilterProvider = StateProvider<DateTimeRange?>((ref) => null);
final workoutExerciseFilterProvider = StateProvider<String?>((ref) => null);

final filteredWorkoutHistoryProvider =
    Provider<AsyncValue<List<WorkoutLogEntity>>>((ref) {
  final history = ref.watch(workoutHistoryProvider);
  final dateRange = ref.watch(workoutDateFilterProvider);
  final exerciseId = ref.watch(workoutExerciseFilterProvider);

  return history.whenData((list) {
    var filtered = list;

    if (dateRange != null) {
      filtered = filtered.where((w) {
        return w.date.isAfter(
                dateRange.start.subtract(const Duration(seconds: 1))) &&
            w.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (exerciseId != null) {
      filtered = filtered.where((w) {
        return w.exercises.any((e) => e.exerciseId == exerciseId);
      }).toList();
    }

    return filtered;
  });
});

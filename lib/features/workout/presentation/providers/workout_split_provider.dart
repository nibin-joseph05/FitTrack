import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_split_entity.dart';
import '../../data/repositories/workout_split_repository_impl.dart';
import 'package:uuid/uuid.dart';

class WorkoutSplitNotifier extends AsyncNotifier<List<WorkoutSplitEntity>> {
  @override
  Future<List<WorkoutSplitEntity>> build() async {
    final repo = ref.read(workoutSplitRepositoryProvider);
    return repo.getAllSplits();
  }

  Future<void> createSplit({
    required String name,
    required List<String> exerciseIds,
    int? dayOfWeek,
    String? notes,
  }) async {
    const uuid = Uuid();
    final split = WorkoutSplitEntity(
      id: uuid.v4(),
      name: name,
      exerciseIds: exerciseIds,
      dayOfWeek: dayOfWeek,
      notes: notes,
    );
    final repo = ref.read(workoutSplitRepositoryProvider);
    await repo.saveSplit(split);
    ref.invalidateSelf();
  }

  Future<void> updateSplit(WorkoutSplitEntity split) async {
    final repo = ref.read(workoutSplitRepositoryProvider);
    await repo.saveSplit(split);
    ref.invalidateSelf();
  }

  Future<void> deleteSplit(String id) async {
    final repo = ref.read(workoutSplitRepositoryProvider);
    await repo.deleteSplit(id);
    ref.invalidateSelf();
  }
}

final workoutSplitProvider =
    AsyncNotifierProvider<WorkoutSplitNotifier, List<WorkoutSplitEntity>>(
  WorkoutSplitNotifier.new,
);

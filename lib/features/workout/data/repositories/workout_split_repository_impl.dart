import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/workout_split_entity.dart';
import '../models/workout_split_model.dart';
import '../../../../core/constants/hive_boxes.dart';

abstract class WorkoutSplitRepository {
  Future<List<WorkoutSplitEntity>> getAllSplits();
  Future<WorkoutSplitEntity?> getSplitById(String id);
  Future<void> saveSplit(WorkoutSplitEntity split);
  Future<void> deleteSplit(String id);
}

class WorkoutSplitRepositoryImpl implements WorkoutSplitRepository {
  Box<WorkoutSplitModel> get _box =>
      Hive.box<WorkoutSplitModel>(HiveBoxes.workoutSplits);

  @override
  Future<List<WorkoutSplitEntity>> getAllSplits() async {
    return _box.values.map((m) => m.toEntity()).toList();
  }

  @override
  Future<WorkoutSplitEntity?> getSplitById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveSplit(WorkoutSplitEntity split) async {
    await _box.put(split.id, WorkoutSplitModel.fromEntity(split));
  }

  @override
  Future<void> deleteSplit(String id) async {
    await _box.delete(id);
  }
}

final workoutSplitRepositoryProvider = Provider<WorkoutSplitRepository>((ref) {
  return WorkoutSplitRepositoryImpl();
});

import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/exercise_entity.dart';
import '../models/exercise_model.dart';
import '../../../../core/constants/hive_boxes.dart';

abstract class ExerciseRepository {
  Future<List<ExerciseEntity>> getAllExercises();
  Future<void> saveExercise(ExerciseEntity exercise);
  Future<void> deleteExercise(String id);
  Future<ExerciseEntity?> getExerciseById(String id);
}

class ExerciseRepositoryImpl implements ExerciseRepository {
  Box<ExerciseModel> get _box => Hive.box<ExerciseModel>(HiveBoxes.exercises);

  @override
  Future<List<ExerciseEntity>> getAllExercises() async {
    return _box.values.map((m) => m.toEntity()).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> saveExercise(ExerciseEntity exercise) async {
    final model = ExerciseModel.fromEntity(exercise);
    await _box.put(exercise.id, model);
  }

  @override
  Future<void> deleteExercise(String id) async {
    await _box.delete(id);
  }

  @override
  Future<ExerciseEntity?> getExerciseById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }
}

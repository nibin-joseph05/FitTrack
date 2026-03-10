part of 'workout_exercise_model.dart';

class WorkoutExerciseModelAdapter extends TypeAdapter<WorkoutExerciseModel> {
  @override
  final int typeId = 2;

  @override
  WorkoutExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutExerciseModel(
      exerciseId: fields[0] as String,
      exerciseName: fields[1] as String,
      muscleGroup: fields[2] as String,
      sets: (fields[3] as List).cast<WorkoutSetModel>(),
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutExerciseModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.sets)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

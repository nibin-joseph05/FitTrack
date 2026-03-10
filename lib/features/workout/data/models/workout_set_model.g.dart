part of 'workout_set_model.dart';

class WorkoutSetModelAdapter extends TypeAdapter<WorkoutSetModel> {
  @override
  final int typeId = 3;

  @override
  WorkoutSetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSetModel(
      setNumber: fields[0] as int,
      reps: fields[1] as int,
      weight: fields[2] as double,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSetModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.setNumber)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_split_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSplitModelAdapter extends TypeAdapter<WorkoutSplitModel> {
  @override
  final int typeId = 6;

  @override
  WorkoutSplitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSplitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      exerciseIds: (fields[2] as List).cast<String>(),
      dayOfWeek: fields[3] as int?,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSplitModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exerciseIds)
      ..writeByte(3)
      ..write(obj.dayOfWeek)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSplitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final int typeId = 0;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseModel(
      id: fields[0] as String,
      name: fields[1] as String,
      muscleGroup: fields[2] as String,
      category: fields[3] as String,
      description: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      isCustom: fields[6] as bool,
      secondaryMuscleGroup: fields[7] as String?,
      exerciseType: fields[8] as String?,
      equipmentType: fields[9] as String?,
      difficulty: fields[10] as String?,
      instructions: fields[11] as String?,
      notes: fields[12] as String?,
      imagePath: fields[13] as String?,
      videoUrl: fields[14] as String?,
      isFavorite: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isCustom)
      ..writeByte(7)
      ..write(obj.secondaryMuscleGroup)
      ..writeByte(8)
      ..write(obj.exerciseType)
      ..writeByte(9)
      ..write(obj.equipmentType)
      ..writeByte(10)
      ..write(obj.difficulty)
      ..writeByte(11)
      ..write(obj.instructions)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.imagePath)
      ..writeByte(14)
      ..write(obj.videoUrl)
      ..writeByte(15)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_metric_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyMetricModelAdapter extends TypeAdapter<BodyMetricModel> {
  @override
  final int typeId = 4;

  @override
  BodyMetricModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyMetricModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      weightKg: fields[2] as double?,
      bodyFatPercent: fields[3] as double?,
      chestCm: fields[4] as double?,
      waistCm: fields[5] as double?,
      hipCm: fields[6] as double?,
      armCm: fields[7] as double?,
      thighCm: fields[8] as double?,
      calvesCm: fields[9] as double?,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMetricModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.bodyFatPercent)
      ..writeByte(4)
      ..write(obj.chestCm)
      ..writeByte(5)
      ..write(obj.waistCm)
      ..writeByte(6)
      ..write(obj.hipCm)
      ..writeByte(7)
      ..write(obj.armCm)
      ..writeByte(8)
      ..write(obj.thighCm)
      ..writeByte(9)
      ..write(obj.calvesCm)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMetricModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

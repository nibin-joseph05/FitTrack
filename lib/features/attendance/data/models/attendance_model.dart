import 'package:hive/hive.dart';
import '../../domain/entities/attendance_entity.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 9)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final bool attended;

  AttendanceModel({
    required this.date,
    required this.attended,
  });

  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    return AttendanceModel(
      date: entity.date,
      attended: entity.attended,
    );
  }

  AttendanceEntity toEntity() {
    return AttendanceEntity(
      date: date,
      attended: attended,
    );
  }
}

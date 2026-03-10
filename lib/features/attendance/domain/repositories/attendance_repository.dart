import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<void> markAttendance(DateTime date, bool attended);
  Future<bool> hasAttended(DateTime date);
  Future<List<AttendanceEntity>> getAttendanceHistory();
}

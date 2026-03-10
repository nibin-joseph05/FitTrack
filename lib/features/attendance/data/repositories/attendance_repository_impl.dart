import 'package:hive/hive.dart';
import '../models/attendance_model.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final Box<AttendanceModel> _box;

  AttendanceRepositoryImpl(this._box);

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> markAttendance(DateTime date, bool attended) async {
    final key = _formatDate(date);
    final model = AttendanceModel(date: date, attended: attended);
    await _box.put(key, model);
  }

  @override
  Future<bool> hasAttended(DateTime date) async {
    final key = _formatDate(date);
    final model = _box.get(key);
    return model?.attended ?? false;
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory() async {
    return _box.values.map((m) => m.toEntity()).toList();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/models/attendance_model.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/utils/date_utils.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final box = Hive.box<AttendanceModel>(HiveBoxes.attendance);
  return AttendanceRepositoryImpl(box);
});

final attendanceHistoryProvider = StateNotifierProvider<AttendanceNotifier,
    AsyncValue<List<AttendanceEntity>>>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceNotifier(repository);
});

final todayAttendanceProvider = Provider<bool>((ref) {
  final historyAsync = ref.watch(attendanceHistoryProvider);
  return historyAsync.maybeWhen(
    data: (history) {
      final today = DateTime.now();
      return history
          .any((a) => a.attended && AppDateUtils.isSameDay(a.date, today));
    },
    orElse: () => false,
  );
});

class AttendanceNotifier
    extends StateNotifier<AsyncValue<List<AttendanceEntity>>> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _repository.getAttendanceHistory();
      state = AsyncValue.data(history);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAttendance(DateTime date) async {
    try {
      await _repository.markAttendance(date, true);
      await _loadHistory();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/timer_entity.dart';
import '../models/timer_model.dart';
import '../../../../core/constants/hive_boxes.dart';

abstract class TimerRepository {
  Future<List<TimerEntity>> getAllTimers();
  Future<void> saveTimer(TimerEntity timer);
  Future<void> deleteTimer(String id);
}

class TimerRepositoryImpl implements TimerRepository {
  Box<TimerModel> get _box => Hive.box<TimerModel>(HiveBoxes.timers);

  @override
  Future<List<TimerEntity>> getAllTimers() async {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveTimer(TimerEntity timer) async {
    final model = TimerModel.fromEntity(timer);
    await _box.put(timer.id, model);
  }

  @override
  Future<void> deleteTimer(String id) async {
    await _box.delete(id);
  }
}

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepositoryImpl();
});

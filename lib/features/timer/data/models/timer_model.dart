import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../../domain/entities/timer_entity.dart';

part 'timer_model.g.dart';

@HiveType(typeId: HiveTypeIds.timerModel)
class TimerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int defaultDurationSeconds;

  TimerModel({
    required this.id,
    required this.name,
    required this.defaultDurationSeconds,
  });

  TimerEntity toEntity() {
    return TimerEntity(
      id: id,
      name: name,
      defaultDurationSeconds: defaultDurationSeconds,
    );
  }

  factory TimerModel.fromEntity(TimerEntity entity) {
    return TimerModel(
      id: entity.id,
      name: entity.name,
      defaultDurationSeconds: entity.defaultDurationSeconds,
    );
  }
}

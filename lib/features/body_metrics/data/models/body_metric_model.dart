import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';

part 'body_metric_model.g.dart';

@HiveType(typeId: HiveTypeIds.bodyMetricModel)
class BodyMetricModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double? weightKg;

  @HiveField(3)
  final double? bodyFatPercent;

  @HiveField(4)
  final double? chestCm;

  @HiveField(5)
  final double? waistCm;

  @HiveField(6)
  final double? hipCm;

  @HiveField(7)
  final double? armCm;

  @HiveField(8)
  final double? thighCm;

  @HiveField(9)
  final double? calvesCm;

  @HiveField(10)
  final String? notes;

  BodyMetricModel({
    required this.id,
    required this.date,
    this.weightKg,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.hipCm,
    this.armCm,
    this.thighCm,
    this.calvesCm,
    this.notes,
  });
}

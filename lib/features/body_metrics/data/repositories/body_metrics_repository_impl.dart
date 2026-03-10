import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/body_metric_entity.dart';
import '../models/body_metric_model.dart';
import '../../../../core/constants/hive_boxes.dart';

abstract class BodyMetricsRepository {
  Future<List<BodyMetricEntity>> getAllMetrics();
  Future<void> saveMetric(BodyMetricEntity metric);
  Future<void> deleteMetric(String id);
}

class BodyMetricsRepositoryImpl implements BodyMetricsRepository {
  Box<BodyMetricModel> get _box =>
      Hive.box<BodyMetricModel>(HiveBoxes.bodyMetrics);

  BodyMetricEntity _toEntity(BodyMetricModel m) => BodyMetricEntity(
    id: m.id,
    date: m.date,
    weightKg: m.weightKg,
    bodyFatPercent: m.bodyFatPercent,
    chestCm: m.chestCm,
    waistCm: m.waistCm,
    hipCm: m.hipCm,
    armCm: m.armCm,
    thighCm: m.thighCm,
    notes: m.notes,
  );

  BodyMetricModel _toModel(BodyMetricEntity e) => BodyMetricModel(
    id: e.id,
    date: e.date,
    weightKg: e.weightKg,
    bodyFatPercent: e.bodyFatPercent,
    chestCm: e.chestCm,
    waistCm: e.waistCm,
    hipCm: e.hipCm,
    armCm: e.armCm,
    thighCm: e.thighCm,
    notes: e.notes,
  );

  @override
  Future<List<BodyMetricEntity>> getAllMetrics() async {
    final list = _box.values.map(_toEntity).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> saveMetric(BodyMetricEntity metric) async {
    await _box.put(metric.id, _toModel(metric));
  }

  @override
  Future<void> deleteMetric(String id) async {
    await _box.delete(id);
  }
}

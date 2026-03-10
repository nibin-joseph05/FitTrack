import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/body_metrics_repository_impl.dart';
import '../../domain/entities/body_metric_entity.dart';
import '../../domain/usecases/body_metrics_usecases.dart';

final bodyMetricsRepositoryProvider = Provider<BodyMetricsRepository>((ref) {
  return BodyMetricsRepositoryImpl();
});

final saveBodyMetricUseCaseProvider = Provider<SaveBodyMetricUseCase>((ref) {
  return SaveBodyMetricUseCase(ref.read(bodyMetricsRepositoryProvider));
});

final getBodyMetricsUseCaseProvider = Provider<GetBodyMetricsUseCase>((ref) {
  return GetBodyMetricsUseCase(ref.read(bodyMetricsRepositoryProvider));
});

final deleteBodyMetricUseCaseProvider = Provider<DeleteBodyMetricUseCase>((
  ref,
) {
  return DeleteBodyMetricUseCase(ref.read(bodyMetricsRepositoryProvider));
});

class BodyMetricsNotifier extends AsyncNotifier<List<BodyMetricEntity>> {
  @override
  Future<List<BodyMetricEntity>> build() async {
    return ref.read(getBodyMetricsUseCaseProvider).call();
  }

  Future<void> addMetric({
    required DateTime date,
    double? weightKg,
    double? bodyFatPercent,
    double? chestCm,
    double? waistCm,
    double? hipCm,
    double? armCm,
    double? thighCm,
    String? notes,
  }) async {
    const uuid = Uuid();
    final metric = BodyMetricEntity(
      id: uuid.v4(),
      date: date,
      weightKg: weightKg,
      bodyFatPercent: bodyFatPercent,
      chestCm: chestCm,
      waistCm: waistCm,
      hipCm: hipCm,
      armCm: armCm,
      thighCm: thighCm,
      notes: notes,
    );
    await ref.read(saveBodyMetricUseCaseProvider).call(metric);
    ref.invalidateSelf();
  }

  Future<void> deleteMetric(String id) async {
    await ref.read(deleteBodyMetricUseCaseProvider).call(id);
    ref.invalidateSelf();
  }
}

final bodyMetricsProvider =
    AsyncNotifierProvider<BodyMetricsNotifier, List<BodyMetricEntity>>(
      BodyMetricsNotifier.new,
    );

final latestWeightProvider = Provider<double?>((ref) {
  final metrics = ref.watch(bodyMetricsProvider);
  return metrics.whenOrNull(
    data: (list) {
      final withWeight = list.where((m) => m.weightKg != null).toList();
      return withWeight.isEmpty ? null : withWeight.first.weightKg;
    },
  );
});

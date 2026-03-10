import '../entities/body_metric_entity.dart';
import '../../data/repositories/body_metrics_repository_impl.dart';

class SaveBodyMetricUseCase {
  final BodyMetricsRepository _repository;
  SaveBodyMetricUseCase(this._repository);
  Future<void> call(BodyMetricEntity metric) => _repository.saveMetric(metric);
}

class GetBodyMetricsUseCase {
  final BodyMetricsRepository _repository;
  GetBodyMetricsUseCase(this._repository);
  Future<List<BodyMetricEntity>> call() => _repository.getAllMetrics();
}

class DeleteBodyMetricUseCase {
  final BodyMetricsRepository _repository;
  DeleteBodyMetricUseCase(this._repository);
  Future<void> call(String id) => _repository.deleteMetric(id);
}

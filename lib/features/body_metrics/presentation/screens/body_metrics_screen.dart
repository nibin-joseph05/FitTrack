import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/body_metrics_provider.dart';
import '../widgets/metric_chart.dart';
import '../../domain/entities/body_metric_entity.dart';

class BodyMetricsScreen extends ConsumerWidget {
  const BodyMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(bodyMetricsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              subtitle: 'TRACK',
              title: 'Body Metrics',
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.addBodyMetric),
                ),
              ],
            ),
            Expanded(
              child: metrics.when(
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.monitor_weight_outlined,
                      title: 'No Metrics Yet',
                      subtitle: 'Start tracking your body measurements',
                      actionLabel: 'Add Entry',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.addBodyMetric),
                    );
                  }
                  final weightData = list
                      .where((m) => m.weightKg != null)
                      .toList()
                      .reversed
                      .toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      if (weightData.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SectionTitle('Weight Progress'),
                        const SizedBox(height: 12),
                        MetricChart(
                          data: weightData
                              .map(
                                (m) => MetricDataPoint(
                                  date: m.date,
                                  value: m.weightKg!,
                                ),
                              )
                              .toList(),
                          unit: 'kg',
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 24),
                      ],
                      _SectionTitle('History'),
                      const SizedBox(height: 12),
                      ...list.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MetricEntryCard(
                            metric: m,
                            onDelete: () => ref
                                .read(bodyMetricsProvider.notifier)
                                .deleteMetric(m.id),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addBodyMetric),
        icon: const Icon(Icons.add),
        label: const Text(
          'Log Metrics',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _MetricEntryCard extends StatelessWidget {
  final BodyMetricEntity metric;
  final VoidCallback onDelete;

  const _MetricEntryCard({required this.metric, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppDateUtils.formatDate(metric.date),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (metric.weightKg != null)
                _MetricBubble(
                  label: 'Weight',
                  value: FormatUtils.formatWeight(metric.weightKg!),
                  color: AppColors.accent,
                ),
              if (metric.bodyFatPercent != null)
                _MetricBubble(
                  label: 'Body Fat',
                  value: '${metric.bodyFatPercent!.toStringAsFixed(1)}%',
                  color: AppColors.warning,
                ),
              if (metric.chestCm != null)
                _MetricBubble(
                  label: 'Chest',
                  value: '${metric.chestCm!.toStringAsFixed(1)} cm',
                  color: AppColors.muscleChest,
                ),
              if (metric.waistCm != null)
                _MetricBubble(
                  label: 'Waist',
                  value: '${metric.waistCm!.toStringAsFixed(1)} cm',
                  color: AppColors.muscleCore,
                ),
              if (metric.hipCm != null)
                _MetricBubble(
                  label: 'Hip',
                  value: '${metric.hipCm!.toStringAsFixed(1)} cm',
                  color: AppColors.muscleLegs,
                ),
              if (metric.armCm != null)
                _MetricBubble(
                  label: 'Arm',
                  value: '${metric.armCm!.toStringAsFixed(1)} cm',
                  color: AppColors.muscleBiceps,
                ),
              if (metric.thighCm != null)
                _MetricBubble(
                  label: 'Thigh',
                  value: '${metric.thighCm!.toStringAsFixed(1)} cm',
                  color: AppColors.muscleLegs,
                ),
            ],
          ),
          if (metric.notes != null && metric.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              metric.notes!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricBubble extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricBubble({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

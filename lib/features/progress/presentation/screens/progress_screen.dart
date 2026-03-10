import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(uniqueExercisesInHistoryProvider);
    final selectedId = ref.watch(selectedProgressExerciseProvider);
    final weeklyVolume = ref.watch(weeklyVolumeProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(subtitle: 'ANALYTICS', title: 'Progress'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _SectionTitle('Weekly Volume'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: weeklyVolume.when(
                  loading: () =>
                      const SizedBox(height: 180, child: LoadingWidget()),
                  error: (e, _) => Text('Error: $e'),
                  data: (data) => _WeeklyVolumeChart(data: data),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _SectionTitle('Strength Progress'),
              ),
            ),
            SliverToBoxAdapter(
              child: exercises.when(
                loading: () =>
                    const SizedBox(height: 60, child: LoadingWidget()),
                error: (e, _) => Text('Error: $e'),
                data: (list) {
                  if (list.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.trending_up,
                      title: 'No Data Yet',
                      subtitle: 'Log workouts to see your strength progress',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final (id, name) = list[i];
                            final selected = selectedId == id;
                            return GestureDetector(
                              onTap: () =>
                                  ref
                                          .read(
                                            selectedProgressExerciseProvider
                                                .notifier,
                                          )
                                          .state =
                                      id,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.borderDark,
                                  ),
                                ),
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.black
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (selectedId != null)
                        _StrengthProgressChart(exerciseId: selectedId),
                    ],
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
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

class _WeeklyVolumeChart extends StatelessWidget {
  final List<VolumeData> data;
  const _WeeklyVolumeChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.map((d) => d.volume).fold(0.0, (a, b) => a > b ? a : b);
    final barMaxY = maxVal == 0 ? 100.0 : maxVal * 1.2;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: BarChart(
        BarChartData(
          maxY: barMaxY,
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.volume,
                  color: e.value.volume > 0
                      ? AppColors.primary
                      : AppColors.borderDark,
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.chartGrid, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      AppDateUtils.formatDayName(data[index].date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  FormatUtils.formatVolume(rod.toY),
                  const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StrengthProgressChart extends ConsumerWidget {
  final String exerciseId;
  const _StrengthProgressChart({required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(strengthProgressProvider(exerciseId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: progress.when(
        loading: () => const SizedBox(height: 180, child: LoadingWidget()),
        error: (e, _) => Text('Error: $e'),
        data: (data) {
          if (data == null || data.maxWeightHistory.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.trending_up,
              title: 'No Data',
              subtitle: 'Log this exercise to track progress',
            );
          }
          final spots = data.maxWeightHistory.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.$2);
          }).toList();
          final minY = data.maxWeightHistory
              .map((h) => h.$2)
              .reduce((a, b) => a < b ? a : b);
          final maxY = data.maxWeightHistory
              .map((h) => h.$2)
              .reduce((a, b) => a > b ? a : b);
          final pad = (maxY - minY) * 0.15 + 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.exerciseName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 180,
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: AppColors.chartGrid,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}kg',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: data.maxWeightHistory.length > 6
                              ? (data.maxWeightHistory.length / 4)
                                    .ceilToDouble()
                              : 1,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i >= data.maxWeightHistory.length || i < 0) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                AppDateUtils.formatShortDate(
                                  data.maxWeightHistory[i].$1,
                                ),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textHint,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: AppColors.chartLine1,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) =>
                              FlDotCirclePainter(
                                radius: 3,
                                color: AppColors.chartLine1,
                                strokeWidth: 1.5,
                                strokeColor: AppColors.backgroundDark,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.chartLine1.withOpacity(0.08),
                        ),
                      ),
                    ],
                    minY: minY - pad,
                    maxY: maxY + pad,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

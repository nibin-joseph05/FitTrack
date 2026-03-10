import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class MetricDataPoint {
  final DateTime date;
  final double value;

  const MetricDataPoint({required this.date, required this.value});
}

class MetricChart extends StatelessWidget {
  final List<MetricDataPoint> data;
  final String unit;
  final Color color;

  const MetricChart({
    super.key,
    required this.data,
    required this.unit,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1 + 1;

    return Container(
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
            horizontalInterval: (maxY - minY) / 4 + 0.5,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.chartGrid, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(1)}$unit',
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
                interval: data.length > 6
                    ? (data.length / 4).ceilToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= data.length || index < 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      AppDateUtils.formatShortDate(data[index].date),
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
              color: color,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 3,
                      color: color,
                      strokeWidth: 1.5,
                      strokeColor: AppColors.backgroundDark,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.08),
              ),
            ),
          ],
          minY: minY - padding,
          maxY: maxY + padding,
        ),
      ),
    );
  }
}

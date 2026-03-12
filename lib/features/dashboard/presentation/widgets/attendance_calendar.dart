import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class MonthlyAttendanceCalendar extends StatelessWidget {
  final int attendedDays;
  final int weeklyGoal;
  final AsyncValue attendanceHistory;

  const MonthlyAttendanceCalendar({
    super.key,
    required this.attendedDays,
    required this.weeklyGoal,
    required this.attendanceHistory,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final prefixDays = firstDayOfMonth.weekday - 1;
    final totalDays = lastDayOfMonth.day;

    final attendedDates = attendanceHistory.maybeWhen(
      data: (list) => Set<String>.from(
        (list as Iterable)
            .cast<dynamic>()
            .where((a) => a.attended == true)
            .map((a) {
          final d = a.date as DateTime;
          return '${d.year}-${d.month}-${d.day}';
        }),
      ),
      orElse: () => <String>{},
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildWeekdayLabels(),
          const SizedBox(height: 8),
          _buildCalendarGrid(now, prefixDays, totalDays, attendedDates),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Keep the streak alive',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text(
                '$attendedDays / $weeklyGoal days',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((label) => Expanded(
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(DateTime now, int prefixDays, int totalDays, Set<String> attendedDates) {
    final List<Widget> dayWidgets = [];

    for (int i = 0; i < prefixDays; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int i = 1; i <= totalDays; i++) {
      final dayDate = DateTime(now.year, now.month, i);
      final dateKey = '${dayDate.year}-${dayDate.month}-${dayDate.day}';
      final isToday = i == now.day;
      final attended = attendedDates.contains(dateKey);
      
      dayWidgets.add(_buildDayCell(i, isToday, attended));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 8.0;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          children: dayWidgets,
        );
      },
    );
  }

  Widget _buildDayCell(int day, bool isToday, bool attended) {
    return Container(
      decoration: BoxDecoration(
        color: attended 
            ? AppColors.primary.withValues(alpha: 0.1) 
            : isToday 
                ? AppColors.primary 
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday 
              ? AppColors.primary 
              : attended 
                  ? AppColors.primary.withValues(alpha: 0.5) 
                  : AppColors.borderDark,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: isToday 
                    ? Colors.black 
                    : attended 
                        ? AppColors.primary 
                        : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isToday || attended ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            if (attended && !isToday)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              'Weekly Progress',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${((attendedDays / weeklyGoal) * 100).toInt().clamp(0, 100)}%',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(
                begin: 0, end: (attendedDays / weeklyGoal).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.elasticOut,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.backgroundDark,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

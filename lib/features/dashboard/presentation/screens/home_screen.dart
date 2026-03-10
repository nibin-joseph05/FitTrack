import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/today_workout_card.dart';
import '../../../../shared/widgets/weekly_volume_card.dart';
import '../../../../shared/widgets/recent_workout_card.dart';
import '../../../../shared/widgets/quick_start_workout_card.dart';
import '../../../workout/presentation/providers/workout_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);
    final profileAsync = ref.watch(profileProvider);
    final hasAttendedToday = ref.watch(todayAttendanceProvider);
    final attendanceHistoryAsync = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: workoutsAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) {
            final todayWorkouts =
                list.where((w) => AppDateUtils.isToday(w.date)).toList();
            final weekWorkouts =
                list.where((w) => AppDateUtils.isThisWeek(w.date)).toList();
            final recent = list.take(5).toList();

            final weeklyVolume =
                weekWorkouts.fold(0.0, (sum, w) => sum + w.totalVolume);
            const targetVolume = 10000.0;
            final volumeProgress =
                (weeklyVolume / targetVolume).clamp(0.0, 1.0);

            final profile = profileAsync.valueOrNull;
            final weeklyGoal = profile?.weeklyGoal ?? 4;

            final attendedDaysThisWeek = attendanceHistoryAsync.maybeWhen(
              data: (history) => history
                  .where((a) => a.attended && AppDateUtils.isThisWeek(a.date))
                  .length,
              orElse: () => 0,
            );

            final activityProgress =
                (attendedDaysThisWeek / weeklyGoal).clamp(0.0, 1.0);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppHeader(
                    subtitle: _greeting(),
                    title: 'Dashboard',
                    actions: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          child: const Icon(Icons.person,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: InkWell(
                      onTap: hasAttendedToday
                          ? null
                          : () => ref
                              .read(attendanceHistoryProvider.notifier)
                              .markAttendance(DateTime.now()),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: hasAttendedToday
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasAttendedToday
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasAttendedToday
                                  ? Icons.check_circle
                                  : Icons.fitness_center,
                              color: hasAttendedToday
                                  ? AppColors.primary
                                  : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hasAttendedToday
                                  ? 'Gym Done Today'
                                  : 'I went to the gym today',
                              style: TextStyle(
                                color: hasAttendedToday
                                    ? AppColors.primary
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Weekly Activity Tracker',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$attendedDaysThisWeek / $weeklyGoal days',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: activityProgress,
                              minHeight: 8,
                              backgroundColor: AppColors.backgroundDark,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: WeeklyVolumeCard(
                    volume: weeklyVolume.toStringAsFixed(0),
                    workouts: weekWorkouts.length,
                    progressPercent: volumeProgress,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                if (todayWorkouts.isEmpty)
                  SliverToBoxAdapter(
                    child: QuickStartWorkoutCard(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.workoutLog),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final w = todayWorkouts[i];
                        return TodayWorkoutCard(
                          title: w.title,
                          duration: '${w.durationSeconds ~/ 60} min',
                          volume: '${w.totalVolume.toStringAsFixed(0)} kg',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.workoutDetail,
                              arguments: w.id),
                        );
                      },
                      childCount: todayWorkouts.length,
                    ),
                  ),
                if (recent.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Recent Workouts',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final w = recent[i];
                        return RecentWorkoutCard(
                          title: w.title,
                          date: '${w.date.day}/${w.date.month}/${w.date.year}',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.workoutDetail,
                              arguments: w.id),
                        );
                      },
                      childCount: recent.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Developed and Designed by Nibin Joseph',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.workoutLog),
        icon: const Icon(Icons.fitness_center),
        label: const Text('New Session',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

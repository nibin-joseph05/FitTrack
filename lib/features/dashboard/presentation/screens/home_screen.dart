import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/workout_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../workout/presentation/providers/workout_provider.dart';
import '../../../workout/domain/entities/workout_entities.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: workouts.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) {
            final todayWorkouts = list
                .where((w) => AppDateUtils.isToday(w.date))
                .toList();
            final weekWorkouts = list
                .where((w) => AppDateUtils.isThisWeek(w.date))
                .toList();
            final recent = list.take(5).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppHeader(
                    subtitle: _greeting(),
                    title: 'Dashboard',
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.workoutLog),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _WeeklyStatsRow(weekWorkouts: weekWorkouts),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      children: [
                        const Text(
                          "Today's Workout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (todayWorkouts.isEmpty)
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.workoutLog,
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (todayWorkouts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _QuickStartCard(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.workoutLog),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: WorkoutCard(
                          title: todayWorkouts[i].title,
                          date: todayWorkouts[i].date,
                          exerciseCount: todayWorkouts[i].exercises.length,
                          totalSets: todayWorkouts[i].totalSets,
                          totalVolume: todayWorkouts[i].totalVolume,
                          duration: todayWorkouts[i].duration,
                        ),
                      ),
                      childCount: todayWorkouts.length,
                    ),
                  ),
                if (recent.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          Text(
                            'Recent Workouts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: WorkoutCard(
                          title: recent[i].title,
                          date: recent[i].date,
                          exerciseCount: recent[i].exercises.length,
                          totalSets: recent[i].totalSets,
                          totalVolume: recent[i].totalVolume,
                          duration: recent[i].duration,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.workoutDetail,
                            arguments: recent[i].id,
                          ),
                        ),
                      ),
                      childCount: recent.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.workoutLog),
        icon: const Icon(Icons.fitness_center),
        label: const Text(
          'Log Workout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }
}

class _WeeklyStatsRow extends StatelessWidget {
  final List<WorkoutLogEntity> weekWorkouts;
  const _WeeklyStatsRow({required this.weekWorkouts});

  @override
  Widget build(BuildContext context) {
    final totalVolume = weekWorkouts.fold(0.0, (sum, w) => sum + w.totalVolume);
    final totalSets = weekWorkouts.fold(0, (sum, w) => sum + w.totalSets);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            value: weekWorkouts.length.toString(),
            label: 'Workouts',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.layers_outlined,
            value: totalSets.toString(),
            label: 'Sets',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.monitor_weight_outlined,
            value: FormatUtils.formatVolume(totalVolume),
            label: 'Volume',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickStartCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.accent.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Today\'s Workout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to log a new workout session',
                    style: TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

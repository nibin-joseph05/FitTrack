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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

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
            final targetVolume = 10000.0;
            final progressPercent =
                (weeklyVolume / targetVolume).clamp(0.0, 1.0);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppHeader(
                    subtitle: _greeting(),
                    title: 'Dashboard',
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.timer),
                        onPressed: () {
                          // This is handled by BottomNavigationBar, but adding quick access here
                          // The user can tap the timer tab.
                        },
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: WeeklyVolumeCard(
                    volume: weeklyVolume.toStringAsFixed(0),
                    workouts: weekWorkouts.length,
                    progressPercent: progressPercent,
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
                            context,
                            AppRoutes.workoutDetail,
                            arguments: w.id,
                          ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                            context,
                            AppRoutes.workoutDetail,
                            arguments: w.id,
                          ),
                        );
                      },
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

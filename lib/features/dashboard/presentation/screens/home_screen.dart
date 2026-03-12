import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/today_workout_card.dart';
import '../../../../shared/widgets/weekly_volume_card.dart';
import '../../../../shared/widgets/recent_workout_card.dart';
import '../../../workout/presentation/providers/workout_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../core/utils/personality_messages.dart';
import '../widgets/home_header.dart';
import '../widgets/custom_bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final AnimationController _cardsController;

  late final Animation<double> _cardsFade;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _cardsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _cardsController, curve: Curves.easeOut));

    _headerController.forward();
    Future.delayed(
        const Duration(milliseconds: 200), () => _cardsController.forward());
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);
    final profileAsync = ref.watch(profileProvider);
    final hasAttendedToday = ref.watch(todayAttendanceProvider);
    final attendanceHistoryAsync = ref.watch(attendanceHistoryProvider);

    final profile = profileAsync.valueOrNull;
    final userName = profile?.name ?? 'Champ';
    final weeklyGoal = profile?.weeklyGoal ?? 4;

    final attendedDaysThisWeek = attendanceHistoryAsync.maybeWhen(
      data: (history) => history
          .where((a) => a.attended && AppDateUtils.isThisWeek(a.date))
          .length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.workoutLog),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.fitness_center),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: _currentIndex == 1
            ? const ProfileScreen(isStandalone: false)
            : workoutsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (list) {
                  final todayWorkouts =
                      list.where((w) => AppDateUtils.isToday(w.date)).toList();
                  final weekWorkouts = list
                      .where((w) => AppDateUtils.isThisWeek(w.date))
                      .toList();
                  final recent = list.take(5).toList();
                  final weeklyVolume =
                      weekWorkouts.fold(0.0, (sum, w) => sum + w.totalVolume);
                  final volumeProgress =
                      (weeklyVolume / 10000.0).clamp(0.0, 1.0);

                  return Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _cardsFade,
                              child: Column(
                                children: [
                                  _WeeklyAttendanceGrid(
                                    attendedDays: attendedDaysThisWeek,
                                    weeklyGoal: weeklyGoal,
                                    attendanceHistory: attendanceHistoryAsync,
                                  ),
                                  const SizedBox(height: 12),
                                  _AttendanceButton(
                                    hasAttended: hasAttendedToday,
                                    userName: userName,
                                    onTap: () => ref
                                        .read(
                                            attendanceHistoryProvider.notifier)
                                        .markAttendance(DateTime.now()),
                                  ),
                                  const SizedBox(height: 12),
                                  WeeklyVolumeCard(
                                    volume: weeklyVolume.toStringAsFixed(0),
                                    workouts: weekWorkouts.length,
                                    progressPercent: volumeProgress,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          if (todayWorkouts.isEmpty)
                            SliverToBoxAdapter(
                              child: FadeTransition(
                                opacity: _cardsFade,
                                child:
                                    _PersonalityMessageCard(userName: userName),
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
                                    volume:
                                        '${w.totalVolume.toStringAsFixed(0)} kg',
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
                                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                                child: Text(
                                  'Recent Workouts',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  final w = recent[i];
                                  return _AnimatedCard(
                                    delay: i * 80,
                                    child: RecentWorkoutCard(
                                      title: w.title,
                                      date:
                                          '${w.date.day}/${w.date.month}/${w.date.year}',
                                      onTap: () => Navigator.pushNamed(
                                          context, AppRoutes.workoutDetail,
                                          arguments: w.id),
                                    ),
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
                                  'Designed & Developed by Nibin Joseph',
                                  style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 100)),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              color: AppColors.backgroundDark
                                  .withValues(alpha: 0.8),
                              child: HomeHeader(
                                userName: userName,
                                onProfileTap: () {
                                  setState(() {
                                    _currentIndex = 1;
                                  });
                                },
                                onMotivationTap: () => Navigator.pushNamed(
                                    context, AppRoutes.dailyMotivation),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _WeeklyAttendanceGrid extends StatelessWidget {
  final int attendedDays;
  final int weeklyGoal;
  final AsyncValue attendanceHistory;

  const _WeeklyAttendanceGrid({
    required this.attendedDays,
    required this.weeklyGoal,
    required this.attendanceHistory,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));

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

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                'This Week',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$attendedDays / $weeklyGoal days',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayDate = startOfWeek.add(Duration(days: i));
              final dateKey = '${dayDate.year}-${dayDate.month}-${dayDate.day}';
              final isToday = i + 1 == weekday;
              final attended = attendedDates.contains(dateKey);
              final isPast = dayDate.isBefore(now);

              return Column(
                children: [
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                        color: isToday ? AppColors.primary : AppColors.textHint,
                        fontSize: 12,
                        fontWeight:
                            isToday ? FontWeight.w800 : FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: attended
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : isPast
                                  ? AppColors.cardDark
                                  : AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? AppColors.primary
                            : attended
                                ? AppColors.primary
                                : AppColors.borderDark,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: attended
                          ? const Icon(Icons.check,
                              color: Colors.black, size: 16)
                          : Text(
                              '${dayDate.day}',
                              style: TextStyle(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.textHint,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                  begin: 0, end: (attendedDays / weeklyGoal).clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.backgroundDark,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final bool hasAttended;
  final String userName;
  final VoidCallback onTap;

  const _AttendanceButton({
    required this.hasAttended,
    required this.userName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: hasAttended ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: hasAttended ? AppColors.cardDark : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasAttended
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasAttended ? Icons.check_circle : Icons.fitness_center,
                color: hasAttended ? AppColors.primary : Colors.black,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasAttended
                      ? PersonalityMessages.attendanceCheckedIn(userName)
                      : 'I went to the gym today',
                  style: TextStyle(
                    color: hasAttended ? AppColors.primary : Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: hasAttended ? 13 : 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalityMessageCard extends StatelessWidget {
  final String userName;
  const _PersonalityMessageCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PersonalityMessages.skipWarning(userName),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.4),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.workoutLog),
                  child: const Text(
                    'Start a session →',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedCard({required this.child, required this.delay});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }
}

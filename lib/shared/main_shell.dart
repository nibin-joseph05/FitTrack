import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/workout/presentation/screens/workout_log_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/body_metrics/presentation/screens/body_metrics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/exercise/presentation/screens/exercise_library_screen.dart';
import '../../features/timer/presentation/screens/timer_screen.dart';

final _currentIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    HomeScreen(),
    ExerciseLibraryScreen(),
    WorkoutLogScreen(),
    ProgressScreen(),
    TimerScreen(),
    BodyMetricsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_currentIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(_currentIndexProvider.notifier).state = index,
      ),
    );
  }
}

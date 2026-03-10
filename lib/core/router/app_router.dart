import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/workout/presentation/screens/workout_log_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/exercise/presentation/screens/exercise_list_screen.dart';
import '../../features/exercise/presentation/screens/create_exercise_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/body_metrics/presentation/screens/body_metrics_screen.dart';
import '../../features/body_metrics/presentation/screens/add_body_metric_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String workoutLog = '/workout-log';
  static const String workoutHistory = '/workout-history';
  static const String workoutDetail = '/workout-detail';
  static const String exerciseList = '/exercises';
  static const String createExercise = '/create-exercise';
  static const String progress = '/progress';
  static const String bodyMetrics = '/body-metrics';
  static const String addBodyMetric = '/add-body-metric';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashScreen(), settings);
      case AppRoutes.home:
        return _fadeRoute(const HomeScreen(), settings);
      case AppRoutes.workoutLog:
        return _slideRoute(const WorkoutLogScreen(), settings);
      case AppRoutes.workoutHistory:
        return _slideRoute(const WorkoutHistoryScreen(), settings);
      case AppRoutes.workoutDetail:
        final id = settings.arguments as String;
        return _slideRoute(WorkoutDetailScreen(workoutId: id), settings);
      case AppRoutes.exerciseList:
        return _slideRoute(const ExerciseListScreen(), settings);
      case AppRoutes.createExercise:
        return _slideRoute(const CreateExerciseScreen(), settings);
      case AppRoutes.progress:
        return _fadeRoute(const ProgressScreen(), settings);
      case AppRoutes.bodyMetrics:
        return _fadeRoute(const BodyMetricsScreen(), settings);
      case AppRoutes.addBodyMetric:
        return _slideRoute(const AddBodyMetricScreen(), settings);
      case AppRoutes.settings:
        return _slideRoute(const SettingsScreen(), settings);
      case AppRoutes.profile:
        return _slideRoute(const ProfileScreen(), settings);
      default:
        return _fadeRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static PageRouteBuilder _slideRoute(
    Widget page,
    RouteSettings routeSettings,
  ) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

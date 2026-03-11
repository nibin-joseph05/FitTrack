import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/motivation/presentation/screens/daily_motivation_screen.dart';
import '../../features/workout/presentation/screens/workout_log_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/exercise/presentation/screens/exercise_list_screen.dart';
import '../../features/exercise/presentation/screens/create_custom_exercise_screen.dart';
import '../../features/exercise/presentation/screens/exercise_stats_screen.dart';
import '../../features/workout/presentation/screens/workout_split_manager_screen.dart';
import '../../features/workout/presentation/screens/create_workout_split_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/body_metrics/presentation/screens/body_metrics_screen.dart';
import '../../features/body_metrics/presentation/screens/add_body_metric_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/about_app_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/workout/domain/entities/workout_split_entity.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
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
  static const String exerciseStats = '/exercise-stats';
  static const String splitManager = '/split-manager';
  static const String createSplit = '/create-split';
  static const String dailyMotivation = '/daily-motivation';
  static const String aboutApp = '/about-app';
  static const String privacyPolicy = '/privacy-policy';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashScreen(), settings);
      case AppRoutes.onboarding:
        return _fadeRoute(const OnboardingScreen(), settings);
      case AppRoutes.home:
        return _fadeRoute(const HomeScreen(), settings);
      case AppRoutes.dailyMotivation:
        return _slideRoute(const DailyMotivationScreen(), settings);
      case AppRoutes.aboutApp:
        return _slideRoute(const AboutAppScreen(), settings);
      case AppRoutes.privacyPolicy:
        return _slideRoute(const PrivacyPolicyScreen(), settings);
      case AppRoutes.workoutLog:
        final split = settings.arguments as WorkoutSplitEntity?;
        return _slideRoute(WorkoutLogScreen(initialSplit: split), settings);
      case AppRoutes.workoutHistory:
        return _slideRoute(const WorkoutHistoryScreen(), settings);
      case AppRoutes.workoutDetail:
        final id = settings.arguments as String;
        return _slideRoute(WorkoutDetailScreen(workoutId: id), settings);
      case AppRoutes.exerciseList:
        return _slideRoute(const ExerciseListScreen(), settings);
      case AppRoutes.createExercise:
        final args = settings.arguments;
        return _slideRoute(
            CreateCustomExerciseScreen(existingExercise: args), settings);
      case AppRoutes.exerciseStats:
        final id = settings.arguments as String;
        return _slideRoute(ExerciseStatsScreen(exerciseId: id), settings);
      case AppRoutes.splitManager:
        return _slideRoute(const WorkoutSplitManagerScreen(), settings);
      case AppRoutes.createSplit:
        final existing = settings.arguments as WorkoutSplitEntity?;
        return _slideRoute(
            CreateWorkoutSplitScreen(existingSplit: existing), settings);
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

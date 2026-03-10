import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/hive_boxes.dart';

import 'features/exercise/data/models/exercise_model.dart';
import 'features/workout/data/models/workout_set_model.dart';
import 'features/workout/data/models/workout_exercise_model.dart';
import 'features/workout/data/models/workout_log_model.dart';
import 'features/body_metrics/data/models/body_metric_model.dart';
import 'features/workout/data/models/workout_split_model.dart';
import 'features/timer/data/models/timer_model.dart';
import 'features/profile/data/models/profile_model.dart';
import 'features/attendance/data/models/attendance_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();

  Hive.registerAdapter(ExerciseModelAdapter());
  Hive.registerAdapter(WorkoutSetModelAdapter());
  Hive.registerAdapter(WorkoutExerciseModelAdapter());
  Hive.registerAdapter(WorkoutLogModelAdapter());
  Hive.registerAdapter(BodyMetricModelAdapter());
  Hive.registerAdapter(WorkoutSplitModelAdapter());
  Hive.registerAdapter(TimerModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());

  await Hive.openBox<ExerciseModel>(HiveBoxes.exercises);
  await Hive.openBox<WorkoutLogModel>(HiveBoxes.workoutLogs);
  await Hive.openBox<BodyMetricModel>(HiveBoxes.bodyMetrics);
  await Hive.openBox<WorkoutSplitModel>(HiveBoxes.workoutSplits);
  await Hive.openBox<TimerModel>(HiveBoxes.timers);
  await Hive.openBox<ProfileModel>(HiveBoxes.profile);
  await Hive.openBox<AttendanceModel>(HiveBoxes.attendance);

  await _seedDefaultExercises();

  runApp(const ProviderScope(child: FitTrackApp()));
}

Future<void> _seedDefaultExercises() async {
  final box = Hive.box<ExerciseModel>(HiveBoxes.exercises);
  if (box.isNotEmpty) return;

  final defaults = [
    ('Bench Press', 'Chest', 'Strength'),
    ('Incline Bench Press', 'Chest', 'Strength'),
    ('Dumbbell Fly', 'Chest', 'Strength'),
    ('Pull-Up', 'Back', 'Strength'),
    ('Barbell Row', 'Back', 'Strength'),
    ('Lat Pulldown', 'Back', 'Strength'),
    ('Deadlift', 'Back', 'Strength'),
    ('Overhead Press', 'Shoulders', 'Strength'),
    ('Lateral Raise', 'Shoulders', 'Strength'),
    ('Barbell Curl', 'Biceps', 'Strength'),
    ('Dumbbell Curl', 'Biceps', 'Strength'),
    ('Tricep Dip', 'Triceps', 'Strength'),
    ('Tricep Pushdown', 'Triceps', 'Strength'),
    ('Squat', 'Legs', 'Strength'),
    ('Leg Press', 'Legs', 'Strength'),
    ('Romanian Deadlift', 'Legs', 'Strength'),
    ('Leg Curl', 'Legs', 'Strength'),
    ('Hip Thrust', 'Glutes', 'Strength'),
    ('Glute Bridge', 'Glutes', 'Strength'),
    ('Plank', 'Core', 'Strength'),
    ('Crunch', 'Core', 'Strength'),
    ('Treadmill Run', 'Cardio', 'Cardio'),
    ('Rowing Machine', 'Full Body', 'Cardio'),
  ];

  for (final (name, muscle, cat) in defaults) {
    final model = ExerciseModel(
      id: '${name.toLowerCase().replaceAll(' ', '_')}_default',
      name: name,
      muscleGroup: muscle,
      category: cat,
      createdAt: DateTime.now(),
      isCustom: false,
    );
    await box.put(model.id, model);
  }
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class AppConstants {
  static const String appName = 'FitTrack';
  static const String appVersion = '1.0.0';

  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Legs',
    'Glutes',
    'Core',
    'Full Body',
    'Cardio',
    'Other',
  ];

  static const List<String> exerciseCategories = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Balance',
    'Plyometrics',
  ];

  static const int maxSetsPerExercise = 20;
  static const int maxExercisesPerWorkout = 30;
  static const double maxWeightKg = 1000.0;
  static const int maxReps = 9999;
}

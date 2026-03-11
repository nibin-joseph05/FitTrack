class ProfileEntity {
  final String id;
  final String name;
  final double height;
  final double currentWeight;
  final double targetWeight;
  final int weeklyGoal;
  final bool onboardingComplete;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    required this.weeklyGoal,
    this.onboardingComplete = false,
  });

  ProfileEntity copyWith({
    String? name,
    double? height,
    double? currentWeight,
    double? targetWeight,
    int? weeklyGoal,
    bool? onboardingComplete,
  }) {
    return ProfileEntity(
      id: id,
      name: name ?? this.name,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

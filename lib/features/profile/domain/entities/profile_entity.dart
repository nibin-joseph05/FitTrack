class ProfileEntity {
  final String id;
  final String name;
  final double height;
  final double targetWeight;
  final int weeklyGoal;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.height,
    required this.targetWeight,
    required this.weeklyGoal,
  });

  ProfileEntity copyWith({
    String? name,
    double? height,
    double? targetWeight,
    int? weeklyGoal,
  }) {
    return ProfileEntity(
      id: id,
      name: name ?? this.name,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    );
  }
}

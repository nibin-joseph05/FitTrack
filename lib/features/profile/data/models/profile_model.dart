import 'package:hive/hive.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 8)
class ProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double height;

  @HiveField(3)
  final double targetWeight;

  @HiveField(4)
  final int weeklyGoal;

  @HiveField(5)
  final double currentWeight;

  @HiveField(6)
  final bool onboardingComplete;

  ProfileModel({
    required this.id,
    required this.name,
    required this.height,
    required this.targetWeight,
    required this.weeklyGoal,
    this.currentWeight = 0.0,
    this.onboardingComplete = false,
  });

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      height: entity.height,
      targetWeight: entity.targetWeight,
      weeklyGoal: entity.weeklyGoal,
      currentWeight: entity.currentWeight,
      onboardingComplete: entity.onboardingComplete,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      height: height,
      targetWeight: targetWeight,
      weeklyGoal: weeklyGoal,
      currentWeight: currentWeight,
      onboardingComplete: onboardingComplete,
    );
  }
}

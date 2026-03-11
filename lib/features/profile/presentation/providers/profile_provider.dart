import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/models/profile_model.dart';
import '../../../../core/constants/hive_boxes.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final box = Hive.box<ProfileModel>(HiveBoxes.profile);
  return ProfileRepositoryImpl(box);
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileEntity?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity?>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(ProfileEntity newProfile) async {
    try {
      await _repository.saveProfile(newProfile);
      state = AsyncValue.data(newProfile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeOnboarding({
    required String name,
    required double height,
    required double currentWeight,
    required double targetWeight,
    required int weeklyGoal,
  }) async {
    final profile = ProfileEntity(
      id: 'user',
      name: name,
      height: height,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      weeklyGoal: weeklyGoal,
      onboardingComplete: true,
    );
    await _repository.saveProfile(profile);
    state = AsyncValue.data(profile);
  }
}

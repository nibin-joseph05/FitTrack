import 'package:hive/hive.dart';
import '../models/profile_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Box<ProfileModel> _box;

  ProfileRepositoryImpl(this._box);

  @override
  Future<void> saveProfile(ProfileEntity profile) async {
    final model = ProfileModel.fromEntity(profile);
    await _box.put('user_profile', model);
  }

  @override
  Future<ProfileEntity?> getProfile() async {
    final model = _box.get('user_profile');
    return model?.toEntity();
  }
}

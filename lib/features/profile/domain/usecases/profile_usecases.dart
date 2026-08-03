import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class WatchProfile {
  const WatchProfile(this._repo);
  final ProfileRepository _repo;
  Stream<UserProfile> call(String uid, String email) =>
      _repo.watchProfile(uid, email);
}

class UpdateProfile {
  const UpdateProfile(this._repo);
  final ProfileRepository _repo;
  Future<Result<void>> call(
    String uid, {
    String? name,
    Gender? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? location,
    String? photoUrl,
  }) =>
      _repo.updateProfile(
        uid,
        name: name,
        gender: gender,
        dateOfBirth: dateOfBirth,
        bio: bio,
        location: location,
        photoUrl: photoUrl,
      );
}

class UpdateSettings {
  const UpdateSettings(this._repo);
  final ProfileRepository _repo;
  Future<Result<void>> call(
    String uid, {
    AppearanceMode? appearance,
    String? language,
    bool? notificationsEnabled,
    bool? remindersEnabled,
  }) =>
      _repo.updateSettings(
        uid,
        appearance: appearance,
        language: language,
        notificationsEnabled: notificationsEnabled,
        remindersEnabled: remindersEnabled,
      );
}

class SelectPlan {
  const SelectPlan(this._repo);
  final ProfileRepository _repo;
  Future<Result<void>> call(String uid, SubscriptionPlan plan) =>
      _repo.selectPlan(uid, plan);
}

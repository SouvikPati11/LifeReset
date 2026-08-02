import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

/// Streams the current user's `users/{uid}` profile, including their role.
class WatchUserProfile {
  const WatchUserProfile(this._repository);

  final UserRepository _repository;

  Stream<UserProfile?> call(String uid) => _repository.watchProfile(uid);
}

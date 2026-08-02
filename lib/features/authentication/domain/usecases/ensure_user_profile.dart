import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/user_repository.dart';

/// Ensures a `users/{uid}` document exists for the authenticated user,
/// creating it with safe defaults on first registration.
class EnsureUserProfile {
  const EnsureUserProfile(this._repository);

  final UserRepository _repository;

  Future<Result<void>> call(AuthUser user) => _repository.ensureProfile(user);
}

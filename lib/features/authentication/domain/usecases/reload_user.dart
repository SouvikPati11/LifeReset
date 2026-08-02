import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Reloads the current user from Firebase and returns the refreshed state.
///
/// Used by the verify-email flow to detect when [AuthUser.isEmailVerified]
/// flips to `true`, since that change is not pushed through the auth-state
/// stream.
class ReloadUser {
  const ReloadUser(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser?>> call() => _repository.reloadUser();
}

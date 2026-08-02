import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Registers a new account with an email and password.
class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _repository.signUpWithEmail(
      email: email.trim(),
      password: password,
      displayName: displayName?.trim(),
    );
  }
}

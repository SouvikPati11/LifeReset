import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Sends a password-reset email to the given address.
class SendPasswordResetEmail {
  const SendPasswordResetEmail(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String email) {
    return _repository.sendPasswordResetEmail(email.trim());
  }
}

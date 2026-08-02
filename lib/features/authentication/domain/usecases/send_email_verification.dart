import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Sends (or resends) a verification email to the current user.
class SendEmailVerification {
  const SendEmailVerification(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.sendEmailVerification();
}

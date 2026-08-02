import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Signs the current user out.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}

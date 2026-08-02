import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Streams the authentication state, emitting `null` when signed out.
class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AuthUser?> call() => _repository.authStateChanges();
}

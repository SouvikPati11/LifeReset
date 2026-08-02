import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// [AuthRepository] backed by an [AuthRemoteDataSource].
///
/// Delegates to the data source and wraps fallible calls in
/// [BaseRepository.guard], which converts thrown [AppException]s into typed
/// [Failure]s inside a [Result].
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AuthUser?> authStateChanges() => _remote.authStateChanges();

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return guard<AuthUser>(
      () => _remote.signInWithEmail(email: email, password: password),
    );
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() {
    return guard<AuthUser>(() => _remote.signInWithGoogle());
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    return guard<AuthUser>(
      () => _remote.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) {
    return guard<void>(() => _remote.sendPasswordResetEmail(email));
  }

  @override
  Future<Result<void>> sendEmailVerification() {
    return guard<void>(() => _remote.sendEmailVerification());
  }

  @override
  Future<Result<AuthUser?>> reloadUser() {
    return guard<AuthUser?>(() => _remote.reloadUser());
  }

  @override
  Future<Result<void>> signOut() {
    return guard<void>(() => _remote.signOut());
  }
}

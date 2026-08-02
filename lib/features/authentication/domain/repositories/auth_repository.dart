import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';

/// Contract for authentication operations.
///
/// Implemented in the data layer against Firebase Authentication. All fallible
/// operations return a [Result] so callers handle success and [Failure]
/// explicitly; the auth-state [Stream] emits `null` when signed out.
abstract interface class AuthRepository {
  /// Emits the current [AuthUser] whenever the sign-in state changes,
  /// or `null` when no user is signed in.
  Stream<AuthUser?> authStateChanges();

  /// The currently signed-in user, or `null`. Synchronous convenience for
  /// guards/redirects that cannot await the stream.
  AuthUser? get currentUser;

  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> sendEmailVerification();

  Future<Result<void>> signOut();
}

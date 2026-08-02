import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/auth_user_model.dart';

/// Remote authentication data source contract.
abstract interface class AuthRemoteDataSource {
  Stream<AuthUserModel?> authStateChanges();

  AuthUserModel? get currentUser;

  Future<AuthUserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUserModel> signInWithGoogle();

  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<AuthUserModel?> reloadUser();

  Future<void> signOut();
}

/// Firebase Authentication implementation of [AuthRemoteDataSource].
///
/// Translates [FirebaseAuthException]s into the app's [AuthException] with a
/// human-readable message, so the repository can map them to [Failure]s via
/// `BaseRepository.guard`.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._firebaseAuth, this._googleSignIn);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AuthUserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
          (user) => user == null ? null : AuthUserModel.fromFirebaseUser(user),
        );
  }

  @override
  AuthUserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code), code: e.code);
    }
  }

  @override
  Future<AuthUserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User dismissed the Google account chooser — not a real error.
        throw const AuthException(
          'Google sign-in was cancelled.',
          code: 'google-cancelled',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return _requireUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code), code: e.code);
    }
  }

  @override
  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _requireRawUser(credential.user);
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      return AuthUserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code), code: e.code);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code), code: e.code);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _requireRawUser(_firebaseAuth.currentUser);
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code), code: e.code);
    }
  }

  @override
  Future<AuthUserModel?> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      await user.reload();
      final refreshed = _firebaseAuth.currentUser;
      return refreshed == null
          ? null
          : AuthUserModel.fromFirebaseUser(refreshed);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code), code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out of Google too so the next Google login re-prompts for account.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code), code: e.code);
    }
  }

  AuthUserModel _requireUser(User? user) =>
      AuthUserModel.fromFirebaseUser(_requireRawUser(user));

  User _requireRawUser(User? user) {
    if (user == null) {
      throw const AuthException(
        'Authentication succeeded but no user was returned.',
        code: 'no-user',
      );
    }
    return user;
  }

  /// Maps Firebase auth error codes to user-facing messages.
  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';

/// Drives the outcome of auth form submissions.
///
/// Exposes an `AsyncValue<void>` that screens watch to show a spinner (loading)
/// or surface an error dialog (error, carrying a [Failure]). Each action
/// returns `true` on success. Navigation is handled by the router's auth guard
/// reacting to the auth-state / profile providers — controllers never navigate.
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInWithEmailProvider)
        .call(email: email, password: password);
    return _completeWithProfile(result);
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(signUpWithEmailProvider).call(
          email: email,
          password: password,
          displayName: displayName,
        );
    if (result is Success<AuthUser>) {
      // Create the Firestore profile, then send the verification email.
      await ref.read(ensureUserProfileProvider).call(result.value);
      await ref.read(sendEmailVerificationProvider).call();
      state = const AsyncData(null);
      return true;
    }
    _emitFailure((result as FailureResult<AuthUser>).failure);
    return false;
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithGoogleProvider).call();
    if (result is FailureResult<AuthUser>) {
      final failure = result.failure;
      // A cancelled Google chooser is not an error — reset silently.
      if (failure is AuthFailure && failure.code == 'google-cancelled') {
        state = const AsyncData(null);
        return false;
      }
      _emitFailure(failure);
      return false;
    }
    return _completeWithProfile(result);
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    final result = await ref.read(sendPasswordResetEmailProvider).call(email);
    return _reflect(result);
  }

  /// Resends the verification email to the current user.
  Future<bool> resendVerificationEmail() async {
    state = const AsyncLoading();
    final result = await ref.read(sendEmailVerificationProvider).call();
    return _reflect(result);
  }

  /// Reloads the user and returns whether their email is now verified.
  ///
  /// On verification it invalidates the auth-state provider so the router's
  /// guard re-evaluates and moves the user into the app. This runs silently and
  /// does not disturb the form submission state.
  Future<bool> refreshVerificationStatus() async {
    final result = await ref.read(reloadUserProvider).call();
    if (result is Success<AuthUser?>) {
      final verified = result.value?.isEmailVerified ?? false;
      if (verified) {
        ref.invalidate(authStateChangesProvider);
      }
      return verified;
    }
    return false;
  }

  Future<bool> signOut() async {
    state = const AsyncLoading();
    final result = await ref.read(signOutProvider).call();
    return _reflect(result);
  }

  /// Ensures the profile exists (self-healing) and marks success.
  Future<bool> _completeWithProfile(Result<AuthUser> result) async {
    if (result is Success<AuthUser>) {
      await ref.read(ensureUserProfileProvider).call(result.value);
      state = const AsyncData(null);
      return true;
    }
    _emitFailure((result as FailureResult<AuthUser>).failure);
    return false;
  }

  bool _reflect<T>(Result<T> result) {
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (failure) {
        _emitFailure(failure);
        return false;
      },
    );
  }

  void _emitFailure(Failure failure) {
    state = AsyncError(failure, StackTrace.current);
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);

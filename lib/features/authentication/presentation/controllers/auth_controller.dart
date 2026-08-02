import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../providers/auth_providers.dart';

/// Drives the outcome of an auth form submission.
///
/// Exposes an `AsyncValue<void>` that the UI watches to show a spinner (loading)
/// or an inline error (error). Each action returns `true` on success so the
/// caller can navigate; failures are surfaced through the notifier's state as
/// a [Failure] carried by [AsyncError].
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn({
    required String email,
    required String password,
  }) {
    final useCase = ref.read(signInWithEmailProvider);
    return _run(() => useCase(email: email, password: password));
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    final useCase = ref.read(signUpWithEmailProvider);
    return _run(
      () => useCase(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  Future<bool> sendPasswordReset(String email) {
    final useCase = ref.read(sendPasswordResetEmailProvider);
    return _run(() => useCase(email));
  }

  Future<bool> signOut() {
    final useCase = ref.read(signOutProvider);
    return _run(() => useCase());
  }

  /// Runs [action], reflecting its [Result] into `state` and returning whether
  /// it succeeded.
  Future<bool> _run<T>(Future<Result<T>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);

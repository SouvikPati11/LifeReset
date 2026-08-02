import 'package:flutter/material.dart';

import '../../../../core/errors/failures.dart';

/// Presentation details for an auth error dialog.
class _AuthErrorInfo {
  const _AuthErrorInfo({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}

/// Shows a Material 3 error dialog describing an authentication [Failure].
///
/// Maps the well-known failure cases from the requirements — no internet,
/// wrong password, user not found, too many requests, email not verified — to
/// a clear title, message and icon. Google-cancelled is intentionally handled
/// silently upstream and never reaches here.
Future<void> showAuthErrorDialog(BuildContext context, Failure failure) {
  final info = _resolve(failure);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: Icon(info.icon, color: colorScheme.error, size: 32),
        title: Text(info.title, textAlign: TextAlign.center),
        content: Text(info.message, textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      );
    },
  );
}

_AuthErrorInfo _resolve(Failure failure) {
  if (failure is NetworkFailure || failure.code == 'network-request-failed') {
    return const _AuthErrorInfo(
      title: 'No internet connection',
      message:
          'You appear to be offline. Check your connection and try again.',
      icon: Icons.wifi_off_rounded,
    );
  }

  switch (failure.code) {
    case 'wrong-password':
    case 'invalid-credential':
      return const _AuthErrorInfo(
        title: 'Incorrect password',
        message: 'The email or password you entered is incorrect.',
        icon: Icons.lock_outline_rounded,
      );
    case 'user-not-found':
      return const _AuthErrorInfo(
        title: 'Account not found',
        message: 'No account exists for that email. Try creating one instead.',
        icon: Icons.person_off_outlined,
      );
    case 'too-many-requests':
      return const _AuthErrorInfo(
        title: 'Too many attempts',
        message:
            'Access has been temporarily blocked after too many attempts. '
            'Please wait a moment and try again.',
        icon: Icons.timer_outlined,
      );
    case 'email-not-verified':
      return const _AuthErrorInfo(
        title: 'Email not verified',
        message:
            'Please verify your email address before continuing. Check your '
            'inbox for the verification link.',
        icon: Icons.mark_email_unread_outlined,
      );
    case 'email-already-in-use':
      return const _AuthErrorInfo(
        title: 'Email already in use',
        message: 'An account already exists for that email. Try signing in.',
        icon: Icons.email_outlined,
      );
    case 'weak-password':
      return const _AuthErrorInfo(
        title: 'Weak password',
        message: 'Please choose a stronger password and try again.',
        icon: Icons.password_rounded,
      );
    default:
      return _AuthErrorInfo(
        title: 'Something went wrong',
        message: failure.message,
        icon: Icons.error_outline_rounded,
      );
  }
}

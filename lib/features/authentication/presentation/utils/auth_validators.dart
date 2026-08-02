/// Form field validators for the authentication screens.
///
/// Return `null` when valid or an error message otherwise, matching the
/// signature expected by [FormField.validator].
class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static const int minPasswordLength = 8;

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email is required.';
    if (!_emailRegExp.hasMatch(input)) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Password is required.';
    if (input.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static String? displayName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Name is required.';
    if (input.length < 2) return 'Please enter your name.';
    return null;
  }
}

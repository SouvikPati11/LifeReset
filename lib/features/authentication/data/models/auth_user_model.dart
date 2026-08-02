import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';

/// Data-layer representation of [AuthUser] that knows how to map from Firebase.
///
/// Keeping the Firebase → domain mapping in the model isolates the `User` type
/// to the data layer, so the domain and presentation layers stay Firebase-free.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
    super.isEmailVerified,
  });

  /// Builds a model from a Firebase [User].
  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }
}

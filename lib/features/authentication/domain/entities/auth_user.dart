import '../../../../shared/models/entity.dart';

/// Authenticated user in the domain layer.
///
/// A pure, framework-agnostic representation of the signed-in account. The data
/// layer maps Firebase's `User` into this entity so nothing above the data
/// layer depends on Firebase types.
class AuthUser extends Entity {
  const AuthUser({
    required super.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, isEmailVerified];
}

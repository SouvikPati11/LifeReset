import '../../../../shared/models/entity.dart';

/// Authorization role for an account.
///
/// SECURITY: the role is resolved from the server-side Firestore document, and
/// [fromString] deliberately defaults unknown/absent values to [user] so a
/// malformed or tampered field can never grant elevated access on the client.
enum UserRole {
  user,
  admin;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  String get value => name;

  bool get isAdmin => this == UserRole.admin;
}

/// Subscription tier for an account.
enum SubscriptionTier {
  free,
  premium;

  static SubscriptionTier fromString(String? value) {
    switch (value) {
      case 'premium':
        return SubscriptionTier.premium;
      case 'free':
      default:
        return SubscriptionTier.free;
    }
  }

  String get value => name;

  bool get isPremium => this == SubscriptionTier.premium;
}

/// The `users/{uid}` account document as a domain entity.
///
/// This is the source of truth for authorization ([role]) and entitlement
/// ([subscription]); both come from Firestore and are never trusted from the
/// client.
class UserProfile extends Entity {
  const UserProfile({
    required super.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = UserRole.user,
    this.subscription = SubscriptionTier.free,
    this.createdAt,
    this.updatedAt,
  });

  /// Firestore document id equals the Firebase Auth uid.
  String get uid => id;

  final String name;
  final String email;
  final String? photoUrl;
  final UserRole role;
  final SubscriptionTier subscription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role.isAdmin;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        role,
        subscription,
        createdAt,
        updatedAt,
      ];
}

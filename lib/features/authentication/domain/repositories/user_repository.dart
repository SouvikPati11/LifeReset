import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../entities/user_profile.dart';

/// Contract for the `users/{uid}` Firestore profile document.
///
/// Implemented in the data layer against Cloud Firestore. The role and
/// subscription fields are read from the server document — the client never
/// asserts them — and creation always writes the safe defaults
/// (`role: user`, `subscription: free`).
abstract interface class UserRepository {
  /// Streams the profile for [uid], emitting `null` when the document does not
  /// exist yet.
  Stream<UserProfile?> watchProfile(String uid);

  /// Fetches the profile for [uid] once.
  Future<Result<UserProfile?>> getProfile(String uid);

  /// Creates the profile with default role/subscription if it does not already
  /// exist; otherwise refreshes mutable fields (email, photo, name, timestamp)
  /// without ever changing role or subscription.
  Future<Result<void>> ensureProfile(AuthUser user);
}

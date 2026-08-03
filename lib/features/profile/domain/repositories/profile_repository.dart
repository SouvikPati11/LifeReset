import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

/// Contract for the user's profile, settings and subscription intent, all held
/// on `users/{uid}`.
abstract interface class ProfileRepository {
  /// Streams the profile (email is supplied from auth as a fallback).
  Stream<UserProfile> watchProfile(String uid, String email);

  /// Updates editable profile info.
  Future<Result<void>> updateProfile(
    String uid, {
    String? name,
    Gender? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? location,
    String? photoUrl,
  });

  /// Updates app settings.
  Future<Result<void>> updateSettings(
    String uid, {
    AppearanceMode? appearance,
    String? language,
    bool? notificationsEnabled,
    bool? remindersEnabled,
  });

  /// Records the chosen plan (and starts/clears the trial). No payment is
  /// processed here.
  Future<Result<void>> selectPlan(String uid, SubscriptionPlan plan);
}

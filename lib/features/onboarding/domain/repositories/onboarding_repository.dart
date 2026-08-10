import '../../../../core/utils/result.dart';
import '../entities/onboarding_answers.dart';

/// Contract for persisting onboarding progress to the user's account document.
///
/// Implemented in the data layer against Cloud Firestore. Writes land on
/// `users/{uid}` (merged) so completion is stored alongside the account and can
/// gate the flow — a completed user never sees onboarding again.
abstract interface class OnboardingRepository {
  /// Streams whether the user has completed onboarding (`onboardingCompleted`).
  Stream<bool> watchCompleted(String uid);

  /// Saves all answers and marks onboarding complete for [uid], persisting the
  /// starting [recoveryScore] so the Home dashboard has a real value to show.
  Future<Result<void>> completeOnboarding({
    required String uid,
    required OnboardingAnswers answers,
    required int recoveryScore,
  });
}

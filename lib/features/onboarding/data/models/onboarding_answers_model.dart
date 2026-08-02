import '../../domain/entities/onboarding_answers.dart';

/// Maps [OnboardingAnswers] to the Firestore payload written on `users/{uid}`.
class OnboardingAnswersModel {
  const OnboardingAnswersModel(this.answers);

  final OnboardingAnswers answers;

  /// The nested `answers` map stored on the user document.
  Map<String, dynamic> toAnswersMap() {
    return {
      'breakupTiming': answers.breakupTiming.value,
      'hurtMost': answers.hurtMost.value,
      'goal': answers.goal.value,
    };
  }
}

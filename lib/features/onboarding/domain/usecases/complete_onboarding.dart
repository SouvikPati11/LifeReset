import '../../../../core/utils/result.dart';
import '../entities/onboarding_answers.dart';
import '../repositories/onboarding_repository.dart';

/// Persists the onboarding answers and flags the account as onboarded.
class CompleteOnboarding {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  Future<Result<void>> call({
    required String uid,
    required OnboardingAnswers answers,
  }) {
    return _repository.completeOnboarding(uid: uid, answers: answers);
  }
}

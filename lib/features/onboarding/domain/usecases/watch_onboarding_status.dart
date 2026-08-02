import '../repositories/onboarding_repository.dart';

/// Streams whether the given user has completed onboarding.
class WatchOnboardingStatus {
  const WatchOnboardingStatus(this._repository);

  final OnboardingRepository _repository;

  Stream<bool> call(String uid) => _repository.watchCompleted(uid);
}

import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_data_source.dart';

/// [OnboardingRepository] backed by Cloud Firestore.
class OnboardingRepositoryImpl extends BaseRepository
    implements OnboardingRepository {
  OnboardingRepositoryImpl(this._remote);

  final OnboardingRemoteDataSource _remote;

  @override
  Stream<bool> watchCompleted(String uid) => _remote.watchCompleted(uid);

  @override
  Future<Result<void>> completeOnboarding({
    required String uid,
    required OnboardingAnswers answers,
  }) {
    return guard<void>(
      () => _remote.completeOnboarding(uid: uid, answers: answers),
    );
  }
}

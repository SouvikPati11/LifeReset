import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../models/onboarding_answers_model.dart';

/// Remote data source for onboarding state on the `users/{uid}` document.
abstract interface class OnboardingRemoteDataSource {
  Stream<bool> watchCompleted(String uid);

  Future<void> completeOnboarding({
    required String uid,
    required OnboardingAnswers answers,
    required int recoveryScore,
  });
}

/// Cloud Firestore implementation.
///
/// Onboarding state is merged onto the existing account document, so it never
/// touches `role`/`subscription` — keeping it within the Firestore Security
/// Rules that forbid clients from changing those fields.
class FirestoreOnboardingRemoteDataSource
    implements OnboardingRemoteDataSource {
  FirestoreOnboardingRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid);

  @override
  Stream<bool> watchCompleted(String uid) {
    return _userDoc(uid).snapshots().map(
          (doc) => (doc.data()?['onboardingCompleted'] as bool?) ?? false,
        );
  }

  @override
  Future<void> completeOnboarding({
    required String uid,
    required OnboardingAnswers answers,
    required int recoveryScore,
  }) async {
    try {
      final model = OnboardingAnswersModel(answers);
      // The recovery journey starts on day 1 with the onboarding-derived score
      // as the first history point (its starting point). serverTimestamp() is
      // not allowed inside an array, so the point uses a client timestamp.
      await _userDoc(uid).set({
        'onboardingCompleted': true,
        'problem': answers.problem.value,
        'answers': model.toAnswersMap(),
        'recoveryScore': recoveryScore,
        'currentDay': 1,
        'scoreHistory': [
          {'date': Timestamp.now(), 'score': recoveryScore},
        ],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e, st) {
      // Surface the exact cause (code + Firestore path + operation) so a denied
      // write is diagnosable rather than a generic "could not save".
      AppLogger.error(
        'Onboarding completion write failed '
        '[op=set(merge), path=${AppConstants.usersCollection}/$uid, '
        'code=${e.code}]: ${e.message}',
        e,
        st,
      );
      throw ServerException(
        e.message ?? 'Failed to save onboarding.',
        code: e.code,
      );
    }
  }
}

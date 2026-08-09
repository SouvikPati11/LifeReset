import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/onboarding_draft_local_data_source.dart';
import '../../data/datasources/onboarding_remote_data_source.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/watch_onboarding_status.dart';

/// Dependency graph for the onboarding feature.

final onboardingRemoteDataSourceProvider =
    Provider<OnboardingRemoteDataSource>((ref) {
  return FirestoreOnboardingRemoteDataSource(FirebaseFirestore.instance);
});

/// Local store for the in-progress onboarding draft (survives app restarts).
final onboardingDraftLocalDataSourceProvider =
    Provider<OnboardingDraftLocalDataSource>((ref) {
  return const OnboardingDraftLocalDataSource();
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingRemoteDataSourceProvider));
});

final completeOnboardingProvider = Provider<CompleteOnboarding>((ref) {
  return CompleteOnboarding(ref.watch(onboardingRepositoryProvider));
});

final watchOnboardingStatusProvider = Provider<WatchOnboardingStatus>((ref) {
  return WatchOnboardingStatus(ref.watch(onboardingRepositoryProvider));
});

/// Streams whether the signed-in user has completed onboarding.
///
/// Emits `false` when signed out. Read by the router guard to show the flow
/// exactly once, and by the flow itself to leave once completion is persisted.
final onboardingStatusProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) {
    return Stream.value(false);
  }
  return ref.watch(watchOnboardingStatusProvider).call(user.id);
});

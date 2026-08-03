import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

/// Dependency graph for the Profile & Subscription feature.

final _firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    FirebaseProfileRemoteDataSource(ref.watch(_firestoreProvider)),
  );
});

final watchProfileUseCaseProvider =
    Provider((ref) => WatchProfile(ref.watch(profileRepositoryProvider)));
final updateProfileUseCaseProvider =
    Provider((ref) => UpdateProfile(ref.watch(profileRepositoryProvider)));
final updateSettingsUseCaseProvider =
    Provider((ref) => UpdateSettings(ref.watch(profileRepositoryProvider)));
final selectPlanUseCaseProvider =
    Provider((ref) => SelectPlan(ref.watch(profileRepositoryProvider)));

/// The signed-in user's profile (cached; streamed from Firestore).
final profileProvider = StreamProvider<UserProfile>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(UserProfile.initial('', ''));
  return ref
      .watch(watchProfileUseCaseProvider)
      .call(user.id, user.email ?? '');
});

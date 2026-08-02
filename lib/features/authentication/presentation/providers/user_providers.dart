import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/user_remote_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/ensure_user_profile.dart';
import '../../domain/usecases/watch_user_profile.dart';
import 'auth_providers.dart';

/// Dependency graph for the Firestore user-profile (`users/{uid}`).

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return FirestoreUserRemoteDataSource(ref.watch(firebaseFirestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDataSourceProvider));
});

final ensureUserProfileProvider = Provider<EnsureUserProfile>((ref) {
  return EnsureUserProfile(ref.watch(userRepositoryProvider));
});

final watchUserProfileProvider = Provider<WatchUserProfile>((ref) {
  return WatchUserProfile(ref.watch(userRepositoryProvider));
});

/// Streams the signed-in user's profile document, or `null` when signed out /
/// not yet created. This is the authoritative source of the user's role.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (authUser == null) {
    return Stream.value(null);
  }
  return ref.watch(watchUserProfileProvider).call(authUser.id);
});

/// Whether the signed-in user is an admin, derived from the server-side role.
///
/// SECURITY: this is computed from the Firestore document, never from a value
/// the client could set, and defaults to `false` while the profile loads.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.isAdmin ?? false;
});

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

/// Remote data source for the `users/{uid}` Firestore document.
abstract interface class UserRemoteDataSource {
  Stream<UserProfileModel?> watchProfile(String uid);

  Future<UserProfileModel?> getProfile(String uid);

  Future<void> ensureProfile(AuthUser user);
}

/// Cloud Firestore implementation of [UserRemoteDataSource].
///
/// On first sign-up it creates the account document with the safe defaults
/// (`role: user`, `subscription: free`). SECURITY: the client never writes an
/// elevated role — role changes are reserved for the backend / admins and
/// enforced by Firestore Security Rules.
class FirestoreUserRemoteDataSource implements UserRemoteDataSource {
  FirestoreUserRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  @override
  Stream<UserProfileModel?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? UserProfileModel.fromFirestore(doc) : null,
        );
  }

  @override
  Future<UserProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      return doc.exists ? UserProfileModel.fromFirestore(doc) : null;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load profile.', code: e.code);
    }
  }

  @override
  Future<void> ensureProfile(AuthUser user) async {
    try {
      final docRef = _users.doc(user.id);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        await docRef.set({
          'uid': user.id,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoUrl ?? '',
          // SECURITY: defaults only — never client-supplied.
          'role': UserRole.user.value,
          'subscription': SubscriptionTier.free.value,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Refresh mutable fields only; role/subscription/createdAt are untouched.
      final updates = <String, dynamic>{
        'email': user.email ?? '',
        'photoUrl': user.photoUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        updates['name'] = user.displayName;
      }
      await docRef.update(updates);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save profile.', code: e.code);
    }
  }
}

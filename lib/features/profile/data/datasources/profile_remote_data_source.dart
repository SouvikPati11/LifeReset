import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

/// Remote data source for the profile document (`users/{uid}`).
abstract interface class ProfileRemoteDataSource {
  Stream<UserProfile> watchProfile(String uid, String email);
  Future<void> updateFields(String uid, Map<String, dynamic> fields);
}

class FirebaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  FirebaseProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid);

  @override
  Stream<UserProfile> watchProfile(String uid, String email) {
    return _userDoc(uid)
        .snapshots()
        .map((doc) => UserProfileModel.fromFirestore(doc, email));
  }

  @override
  Future<void> updateFields(String uid, Map<String, dynamic> fields) async {
    try {
      await _userDoc(uid).set(
        {...fields, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save changes.', code: e.code);
    }
  }
}

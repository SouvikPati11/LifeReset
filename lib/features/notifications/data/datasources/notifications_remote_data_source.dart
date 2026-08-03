import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_notification.dart';

/// Firestore data source for the notification inbox, preferences and device
/// tokens. Inbox documents are created only by Cloud Functions; the client
/// reads them and toggles `isRead`.
class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(AppConstants.usersCollection).doc(uid);

  CollectionReference<Map<String, dynamic>> _inbox(String uid) =>
      _userDoc(uid).collection('notifications');

  CollectionReference<Map<String, dynamic>> _tokens(String uid) =>
      _userDoc(uid).collection('fcm_tokens');

  // ---- Inbox ----

  Stream<List<AppNotification>> watchInbox(String uid) {
    return _inbox(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return AppNotification(
                id: d.id,
                title: (data['title'] as String?) ?? '',
                body: (data['body'] as String?) ?? '',
                type: AppNotificationType.fromValue(data['type'] as String?),
                isRead: (data['isRead'] as bool?) ?? false,
                createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
              );
            }).toList());
  }

  Future<void> markRead(String uid, String notificationId) async {
    try {
      await _inbox(uid).doc(notificationId).set(
        {'isRead': true},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update.', code: e.code);
    }
  }

  Future<void> markAllRead(String uid) async {
    try {
      final snap = await _inbox(uid).where('isRead', isEqualTo: false).get();
      if (snap.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.set(doc.reference, {'isRead': true}, SetOptions(merge: true));
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update.', code: e.code);
    }
  }

  Future<void> delete(String uid, String notificationId) async {
    try {
      await _inbox(uid).doc(notificationId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete.', code: e.code);
    }
  }

  Future<void> clearAll(String uid) async {
    try {
      final snap = await _inbox(uid).limit(300).get();
      if (snap.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to clear.', code: e.code);
    }
  }

  // ---- Preferences ----

  Stream<NotificationPrefs> watchPrefs(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      final map = doc.data()?['notificationSettings'] as Map<String, dynamic>?;
      return NotificationPrefs.fromMap(map);
    });
  }

  Future<void> savePrefs(String uid, NotificationPrefs prefs) async {
    try {
      await _userDoc(uid).set(
        {
          'notificationSettings': prefs.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save settings.', code: e.code);
    }
  }

  // ---- Tokens ----

  Future<void> registerToken(String uid, String token, String platform) async {
    try {
      // Doc id = token → registering the same token twice is a no-op.
      await _tokens(uid).doc(token).set({
        'token': token,
        'platform': platform,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to register device.', code: e.code);
    }
  }

  Future<void> removeToken(String uid, String token) async {
    try {
      await _tokens(uid).doc(token).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to remove device.', code: e.code);
    }
  }
}

import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';

/// Contract for the Push Notification feature.
///
/// The inbox and preferences are read from / written to Firestore; FCM tokens
/// are registered so Cloud Functions can target the user's devices. The client
/// never sends push messages — only Cloud Functions do.
abstract interface class NotificationsRepository {
  /// The user's notification inbox, newest first.
  Stream<List<AppNotification>> watchInbox(String uid);

  /// The user's notification preferences.
  Stream<NotificationPrefs> watchPrefs(String uid);

  Future<Result<void>> markRead(String uid, String notificationId);
  Future<Result<void>> markAllRead(String uid);
  Future<Result<void>> delete(String uid, String notificationId);
  Future<Result<void>> clearAll(String uid);

  Future<Result<void>> savePrefs(String uid, NotificationPrefs prefs);

  /// Registers (or refreshes) an FCM device token for the user. The document
  /// id is the token itself, so repeated registrations are idempotent.
  Future<Result<void>> registerToken(String uid, String token, String platform);

  /// Removes a device token (e.g. on sign-out).
  Future<Result<void>> removeToken(String uid, String token);
}

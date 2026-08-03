import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl extends BaseRepository
    implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Stream<List<AppNotification>> watchInbox(String uid) =>
      _remote.watchInbox(uid);

  @override
  Stream<NotificationPrefs> watchPrefs(String uid) => _remote.watchPrefs(uid);

  @override
  Future<Result<void>> markRead(String uid, String notificationId) =>
      guard(() => _remote.markRead(uid, notificationId));

  @override
  Future<Result<void>> markAllRead(String uid) =>
      guard(() => _remote.markAllRead(uid));

  @override
  Future<Result<void>> delete(String uid, String notificationId) =>
      guard(() => _remote.delete(uid, notificationId));

  @override
  Future<Result<void>> clearAll(String uid) =>
      guard(() => _remote.clearAll(uid));

  @override
  Future<Result<void>> savePrefs(String uid, NotificationPrefs prefs) =>
      guard(() => _remote.savePrefs(uid, prefs));

  @override
  Future<Result<void>> registerToken(String uid, String token, String platform) =>
      guard(() => _remote.registerToken(uid, token, platform));

  @override
  Future<Result<void>> removeToken(String uid, String token) =>
      guard(() => _remote.removeToken(uid, token));
}

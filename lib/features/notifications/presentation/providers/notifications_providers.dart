import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../data/services/push_messaging_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Dependency graph for the Push Notification feature.

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final pushMessagingServiceProvider = Provider<PushMessagingService>((ref) {
  return PushMessagingService(ref.watch(firebaseMessagingProvider));
});

final _dataSourceProvider = Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource(FirebaseFirestore.instance);
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(ref.watch(_dataSourceProvider));
});

/// The signed-in user's notification inbox (newest first).
final inboxProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(notificationsRepositoryProvider).watchInbox(uid);
});

/// Count of unread inbox items (for a badge).
final unreadCountProvider = Provider<int>((ref) {
  final items = ref.watch(inboxProvider).valueOrNull ?? const [];
  return items.where((n) => !n.isRead).length;
});

/// The signed-in user's notification preferences.
final notificationPrefsProvider = StreamProvider<NotificationPrefs>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const NotificationPrefs());
  return ref.watch(notificationsRepositoryProvider).watchPrefs(uid);
});

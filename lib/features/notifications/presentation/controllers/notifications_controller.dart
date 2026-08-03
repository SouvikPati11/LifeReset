import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/notifications_providers.dart';

/// Latest foreground message, exposed so a screen can show an in-app banner.
/// The inbox itself always updates from Firestore (Cloud Functions write the
/// document), so this is purely for optional in-app surfacing.
final latestForegroundMessageProvider =
    StateProvider<RemoteMessage?>((ref) => null);

/// The `data` payload of the notification the user tapped (used for deep-link
/// style navigation to the inbox). Cleared by the consumer after handling.
final pendingNotificationTapProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

class NotificationInitState {
  const NotificationInitState({
    this.initialized = false,
    this.permissionGranted = false,
  });

  final bool initialized;
  final bool permissionGranted;

  NotificationInitState copyWith({bool? initialized, bool? permissionGranted}) =>
      NotificationInitState(
        initialized: initialized ?? this.initialized,
        permissionGranted: permissionGranted ?? this.permissionGranted,
      );
}

/// Orchestrates FCM setup for the signed-in user: permission, token
/// registration + refresh, and foreground / tap message handling.
class NotificationsController extends Notifier<NotificationInitState> {
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  bool _started = false;

  @override
  NotificationInitState build() {
    ref.onDispose(() {
      _tokenSub?.cancel();
      _foregroundSub?.cancel();
      _openedSub?.cancel();
    });
    return const NotificationInitState();
  }

  /// Runs the one-time setup. Safe to call repeatedly (guarded).
  Future<void> initialize() async {
    if (_started) return;
    _started = true;

    final service = ref.read(pushMessagingServiceProvider);
    await service.configureForegroundPresentation();

    final granted = await service.requestPermission();
    state = state.copyWith(initialized: true, permissionGranted: granted);
    if (!granted) return;

    await _registerCurrentToken();
    _tokenSub = service.onTokenRefresh.listen(_saveToken);
    _foregroundSub = service.onForegroundMessage.listen(_onForeground);
    _openedSub = service.onMessageOpenedApp.listen(_onOpened);

    // App launched from terminated state via a notification tap.
    final initial = await service.getInitialMessage();
    if (initial != null) _onOpened(initial);
  }

  /// Re-requests permission (e.g. from the settings screen) and registers the
  /// token if it is now granted.
  Future<void> recheckPermission() async {
    final granted =
        await ref.read(pushMessagingServiceProvider).requestPermission();
    state = state.copyWith(permissionGranted: granted);
    if (granted) await _registerCurrentToken();
  }

  Future<void> _registerCurrentToken() async {
    final token = await ref.read(pushMessagingServiceProvider).getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    final platform = ref.read(pushMessagingServiceProvider).platformLabel;
    final result = await ref
        .read(notificationsRepositoryProvider)
        .registerToken(uid, token, platform);
    result.when(
      success: (_) => AppLogger.debug('FCM token registered.'),
      failure: (f) => AppLogger.warning('FCM token save failed: ${f.message}'),
    );
  }

  void _onForeground(RemoteMessage message) {
    ref.read(latestForegroundMessageProvider.notifier).state = message;
  }

  void _onOpened(RemoteMessage message) {
    ref.read(pendingNotificationTapProvider.notifier).state = message.data;
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationInitState>(
  NotificationsController.new,
);

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../firebase_options.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../controllers/notifications_controller.dart';
import '../screens/notifications_inbox_screen.dart';

/// Background / terminated message handler.
///
/// Must be a top-level function. When Cloud Functions send a message with a
/// `notification` payload, the OS displays it automatically; this handler
/// simply guarantees Firebase is available for any data-only processing.
@pragma('vm:entry-point')
Future<void> notificationsBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Already initialized in this isolate.
  }
  AppLogger.debug('Background message: ${message.messageId}');
}

/// Drop this above your app content (below `MaterialApp`, so it has access to a
/// `Navigator` and `ScaffoldMessenger`) to wire up push notifications:
///
/// ```dart
/// builder: (context, child) => NotificationsInitializer(child: child!),
/// ```
///
/// It registers the background handler once, initializes FCM for the signed-in
/// user, surfaces foreground messages as an in-app banner, and opens the inbox
/// when a notification is tapped.
class NotificationsInitializer extends ConsumerStatefulWidget {
  const NotificationsInitializer({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<NotificationsInitializer> createState() =>
      _NotificationsInitializerState();
}

class _NotificationsInitializerState
    extends ConsumerState<NotificationsInitializer> {
  @override
  void initState() {
    super.initState();
    // Firebase may be uninitialized in development (placeholder config); guard
    // so notification setup never blocks app startup.
    if (!FirebaseService.isInitialized) return;
    try {
      FirebaseMessaging.onBackgroundMessage(notificationsBackgroundHandler);
    } catch (e) {
      AppLogger.warning('Could not register FCM background handler: $e');
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(currentUserProvider) != null) {
        ref.read(notificationsControllerProvider.notifier).initialize();
      }
    });
  }

  void _showForeground(RemoteMessage message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final notification = message.notification;
    if (messenger == null || notification == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(notification.title ?? notification.body ?? 'New notification'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _openInbox(),
        ),
      ),
    );
  }

  void _openInbox() {
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    navigator?.push(
      MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize when a user signs in.
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        ref.read(notificationsControllerProvider.notifier).initialize();
      }
    });

    // Surface foreground messages as an in-app banner.
    ref.listen(latestForegroundMessageProvider, (previous, message) {
      if (message != null) _showForeground(message);
    });

    // Open the inbox when a notification is tapped (background/terminated).
    ref.listen(pendingNotificationTapProvider, (previous, data) {
      if (data != null) {
        ref.read(pendingNotificationTapProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) => _openInbox());
      }
    });

    return widget.child;
  }
}

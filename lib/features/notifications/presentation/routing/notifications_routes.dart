import 'package:go_router/go_router.dart';

import '../screens/notification_settings_screen.dart';
import '../screens/notifications_inbox_screen.dart';

/// Route path/name for the notification inbox. Declared locally (the shared
/// [AppRoutes] table is part of Foundation and is not modified here).
const String kNotificationsPath = '/notifications';
const String kNotificationsName = 'notifications';

/// The Push Notification routes, exposed as a plug-in list.
///
/// Self-contained: [NotificationsInboxScreen] is the entry point and the
/// settings screen is pushed with the local [Navigator]. Surface it by pushing
/// [NotificationsInboxScreen] (e.g. from a bell icon), or spread
/// [notificationsRoutes] into the app's `GoRouter`. Wrap the app content in
/// `NotificationsInitializer` once to enable FCM.
final List<RouteBase> notificationsRoutes = [
  GoRoute(
    path: kNotificationsPath,
    name: kNotificationsName,
    builder: (context, state) => const NotificationsInboxScreen(),
    routes: [
      GoRoute(
        path: 'settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  ),
];

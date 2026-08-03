import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [FirebaseMessaging].
///
/// Handles permission, token retrieval/refresh and the foreground / tap message
/// streams. It never *sends* messages — sending is exclusively a Cloud
/// Functions responsibility.
class PushMessagingService {
  PushMessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  /// Requests notification permission. Returns true when authorized or
  /// provisionally authorized.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<AuthorizationStatus> currentStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Ensures foreground notifications are surfaced on iOS.
  Future<void> configureForegroundPresentation() {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Messages received while the app is in the foreground.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// Fired when the user taps a notification that opened/backgrounded the app.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// The message that launched the app from a terminated state (if any).
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  /// A coarse platform label stored alongside the token.
  String get platformLabel {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      default:
        return 'other';
    }
  }
}

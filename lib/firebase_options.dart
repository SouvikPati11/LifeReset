// File generated for the LifeReset Firebase project (lifereset-556c7).
//
// The Android options below are the real values for the `com.lifereset.app`
// Android app, taken from android/app/google-services.json. Only Android is
// configured for this project; other platforms throw UnsupportedError until
// they are added (re-run `flutterfire configure` to add iOS/web/etc.).
//
// A Firebase "apiKey" is a public project identifier, not a secret — access is
// controlled by Firebase Security Rules and API-key restrictions — so it is
// safe to commit, exactly as the FlutterFire CLI generates it.
//
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6--MwKQfi10M0QWLUscgKS95rIpZirz0',
    appId: '1:165332899972:android:23d372ad2589ca68414ad1',
    messagingSenderId: '165332899972',
    projectId: 'lifereset-556c7',
    storageBucket: 'lifereset-556c7.firebasestorage.app',
  );
}

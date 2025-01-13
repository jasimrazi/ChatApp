// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgWGQpGUpgKGfhAaFwv_5vkgJm1owOZvY',
    appId: '1:933931510078:web:170aa1adb6d2853148646f',
    messagingSenderId: '933931510078',
    projectId: 'chat-app-759db',
    authDomain: 'chat-app-759db.firebaseapp.com',
    storageBucket: 'chat-app-759db.firebasestorage.app',
    measurementId: 'G-YMVF7XM0ST',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxVy733H86mrVNLVJZt3n5KjZaa6VspbY',
    appId: '1:933931510078:android:e6eecccc304e705d48646f',
    messagingSenderId: '933931510078',
    projectId: 'chat-app-759db',
    storageBucket: 'chat-app-759db.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkQgfXpoRMm1bIptuG_uUKmUfhlDrdbdk',
    appId: '1:933931510078:ios:e3b5bc260ee865b348646f',
    messagingSenderId: '933931510078',
    projectId: 'chat-app-759db',
    storageBucket: 'chat-app-759db.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );
}

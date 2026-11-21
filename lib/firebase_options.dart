// File generated/configured for Firebase
// Sinh viên có thể chạy lệnh `flutterfire configure` để tự động cập nhật file này
// với Project ID thật từ Firebase Console của mình.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDemoPlaceholderWebKeyForFlutterApp123',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'demo-flutter-firebase-ch5',
    authDomain: 'demo-flutter-firebase-ch5.firebaseapp.com',
    storageBucket: 'demo-flutter-firebase-ch5.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderAndroidKeyFlutter123',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'demo-flutter-firebase-ch5',
    storageBucket: 'demo-flutter-firebase-ch5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderIosKeyFlutter123',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'demo-flutter-firebase-ch5',
    storageBucket: 'demo-flutter-firebase-ch5.appspot.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderMacosKeyFlutter123',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'demo-flutter-firebase-ch5',
    storageBucket: 'demo-flutter-firebase-ch5.appspot.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderWindowsKeyFlutter123',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'demo-flutter-firebase-ch5',
    authDomain: 'demo-flutter-firebase-ch5.firebaseapp.com',
    storageBucket: 'demo-flutter-firebase-ch5.appspot.com',
  );
}

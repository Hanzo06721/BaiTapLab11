import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  // Kiểm tra xem đã có API Key Firebase thật từ Firebase Console chưa
  static bool get hasRealCredentials {
    try {
      final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
      return !apiKey.contains('Placeholder') && !apiKey.startsWith('AIzaSyDemo');
    } catch (_) {
      return false;
    }
  }

  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        return true;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint("Firebase initialized successfully! (hasRealCredentials: $hasRealCredentials)");
      return true;
    } catch (e) {
      debugPrint("Firebase.initializeApp exception (Chế độ Demo/Mô phỏng sẵn sàng): $e");
      _initialized = false;
      return false;
    }
  }

  static bool checkConnected() {
    return Firebase.apps.isNotEmpty && hasRealCredentials;
  }
}

import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'screens/home_hub_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi chạy Firebase theo hướng dẫn Chương 5 (Trang 4)
  await FirebaseService.initialize();
  checkFirebaseConnected();

  runApp(const MyApp());
}

// Hàm kiểm tra tình trạng kết nối đến Firebase theo đúng đề bài (Mục 1.4 - Trang 4)
void checkFirebaseConnected() {
  bool isConnected = FirebaseService.checkConnected();
  debugPrint('=======================================');
  debugPrint('Firebase connected: $isConnected');
  debugPrint('=======================================');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chương 5: Firebase Thực Hành',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeHubScreen(),
    );
  }
}

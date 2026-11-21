import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_service.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Đăng ký với Email và Mật khẩu
  Future<AppUser> registerWithEmail(String email, String password, {String? displayName}) async {
    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        if (displayName != null && displayName.isNotEmpty) {
          await credential.user?.updateDisplayName(displayName);
        }
        final user = credential.user;
        _currentUser = AppUser(
          uid: user?.uid ?? 'user-${DateTime.now().millisecondsSinceEpoch}',
          email: user?.email,
          displayName: displayName ?? user?.displayName ?? email.split('@').first,
          photoUrl: user?.photoURL,
        );
        notifyListeners();
        return _currentUser!;
      } catch (e) {
        if (e.toString().contains('API key not valid') || e.toString().contains('api-key-not-valid')) {
          return _mockRegister(email, password, displayName);
        }
        rethrow;
      }
    } else {
      return _mockRegister(email, password, displayName);
    }
  }

  Future<AppUser> _mockRegister(String email, String password, String? displayName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = AppUser(
      uid: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: displayName ?? email.split('@').first,
    );
    notifyListeners();
    return _currentUser!;
  }

  // Đăng nhập với Email và Mật khẩu
  Future<AppUser> signInWithEmail(String email, String password) async {
    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        final user = credential.user;
        _currentUser = AppUser(
          uid: user?.uid ?? '',
          email: user?.email,
          displayName: user?.displayName ?? email.split('@').first,
          photoUrl: user?.photoURL,
        );
        notifyListeners();
        return _currentUser!;
      } catch (e) {
        if (e.toString().contains('API key not valid') || e.toString().contains('api-key-not-valid')) {
          return _mockSignIn(email);
        }
        rethrow;
      }
    } else {
      return _mockSignIn(email);
    }
  }

  Future<AppUser> _mockSignIn(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = AppUser(
      uid: 'demo-user-12345',
      email: email.trim(),
      displayName: email.split('@').first,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    );
    notifyListeners();
    return _currentUser!;
  }

  // Đăng nhập Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Người dùng hủy đăng nhập
      }

      if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;
        _currentUser = AppUser(
          uid: user?.uid ?? googleUser.id,
          email: user?.email ?? googleUser.email,
          displayName: user?.displayName ?? googleUser.displayName,
          photoUrl: user?.photoURL ?? googleUser.photoUrl,
        );
      } else {
        _currentUser = AppUser(
          uid: googleUser.id,
          email: googleUser.email,
          displayName: googleUser.displayName,
          photoUrl: googleUser.photoUrl,
        );
      }
      notifyListeners();
      return _currentUser;
    } catch (e) {
      debugPrint("Google Sign In exception: $e -> Fallback sang Demo user");
      _currentUser = AppUser(
        uid: 'google-demo-user',
        email: 'user.google@gmail.com',
        displayName: 'Google Demo User',
        photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      );
      notifyListeners();
      return _currentUser;
    }
  }

  // Đăng nhập ẩn danh / Guest
  Future<AppUser> signInAnonymously() async {
    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        final credential = await _auth.signInAnonymously();
        final user = credential.user;
        _currentUser = AppUser(
          uid: user?.uid ?? 'guest-${DateTime.now().millisecondsSinceEpoch}',
          displayName: 'Khách (Guest)',
          isAnonymous: true,
        );
        notifyListeners();
        return _currentUser!;
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AppUser(
      uid: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Khách (Guest)',
      isAnonymous: true,
    );
    notifyListeners();
    return _currentUser!;
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
        await _auth.signOut();
      }
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }
}

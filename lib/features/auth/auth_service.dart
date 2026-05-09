import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_user.dart';

/// Firebase Auth + Google Sign-In işlemlerini yöneten servis.
/// Riverpod provider'ı bu sınıfı inject eder.
class AuthService {
  AuthService()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ── Oturum durumu stream'i ───────────────────────────────────────
  /// null  → kullanıcı giriş yapmamış
  /// User  → kullanıcı giriş yapmış
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user == null ? null : AuthUser.fromFirebase(user),
      );

  /// Anlık kullanıcı (null ise oturum yok)
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : AuthUser.fromFirebase(user);
  }

  // ── Google ile giriş ────────────────────────────────────────────
  Future<AuthUser?> signInWithGoogle() async {
    // Google hesap seçim ekranını aç
    final googleUser = await _googleSignIn.signIn();

    // Kullanıcı seçim ekranını kapattıysa null döner
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    // Google token'larını Firebase credential'ına çevir
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase'e giriş yap
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;

    return user == null ? null : AuthUser.fromFirebase(user);
  }

  // ── Çıkış ───────────────────────────────────────────────────────
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _auth.signOut(),
    ]);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kisisel_harcama_kocu_1/core/config/app_config.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: kIsWeb ? AppConfig.webGoogleClientId : null,
            );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _ensureUserDocument(credential.user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e));
    }
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      await _ensureUserDocument(credential.user, displayName: displayName);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e));
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final credential = await _auth.signInWithPopup(provider);
        await _ensureUserDocument(credential.user);
        return credential;
      }

      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthCanceledException();
      }

      final authentication = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _ensureUserDocument(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e));
    }
  }

  Future<void> _ensureUserDocument(
    User? user, {
    String? displayName,
  }) async {
    if (user == null) return;

    final doc = _firestore.collection('users').doc(user.uid);
    await doc.set(
      {
        'email': user.email,
        'displayName': displayName?.trim() ?? user.displayName,
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      if (!kIsWeb) _googleSignIn.signOut(),
    ]);
  }
}

String mapFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Geçersiz e-posta adresi.';
    case 'user-disabled':
      return 'Bu hesap devre dışı bırakılmış.';
    case 'user-not-found':
      return 'Bu e-posta ile kayıtlı hesap bulunamadı.';
    case 'wrong-password':
      return 'Şifre hatalı.';
    case 'email-already-in-use':
      return 'Bu e-posta zaten kullanılıyor.';
    case 'weak-password':
      return 'Şifre en az 6 karakter olmalı.';
    case 'operation-not-allowed':
      return 'E-posta girişi Firebase Console\'da etkin değil.';
    case 'invalid-credential':
      return 'E-posta veya şifre hatalı.';
    case 'too-many-requests':
      return 'Çok fazla deneme. Lütfen biraz bekleyin.';
    default:
      return e.message ?? 'Kimlik doğrulama hatası.';
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthCanceledException implements Exception {
  const AuthCanceledException();
}

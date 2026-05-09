import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'auth_user.dart';

// ── AuthService provider ─────────────────────────────────────────
/// Uygulamanın tek AuthService instance'ı.
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);

// ── Oturum durumu stream provider ───────────────────────────────
/// Firebase auth state değişikliklerini dinler.
/// null  → giriş yapılmamış → LoginScreen
/// User  → giriş yapılmış   → HomeScreen
final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

// ── Google Sign-In state ─────────────────────────────────────────
/// Giriş butonunun loading/hata durumunu yönetir.
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signInWithGoogle(),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signOut(),
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

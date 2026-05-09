import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_provider.dart';
import 'login_screen.dart';
import 'features/home/home_screen.dart';      

// ── Route isimleri (magic string'den kaçın) ──────────────────────
abstract class AppRoute {
  static const login = '/login';
  static const home = '/home';
}

// ── Router provider ──────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  // auth state değişince router'ı yeniden değerlendir
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoute.login,
    // Redirect: auth durumuna göre yönlendirme
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return null; // henüz bilmiyoruz, bekle

      final isLoggedIn = authState.valueOrNull != null;
      final onLogin = state.matchedLocation == AppRoute.login;

      if (!isLoggedIn && !onLogin) return AppRoute.login;
      if (isLoggedIn && onLogin) return AppRoute.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(), // aşağıda tanımlı
      ),
      // GoRoute'da:
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const HomeScreen(), // ← değiştir
      ),
    ],
  );
});

// ── Geçici placeholder (HomeScreen henüz yazılmadı) ──────────────
class _PlaceholderHome extends ConsumerWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hoş geldin,\n${user?.displayName ?? 'Kullanıcı'}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () =>
                  ref.read(authNotifierProvider.notifier).signOut(),
              child: const Text('Çıkış yap',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LoginScreen burada tanımlı (ayrı dosyadan import edilebilir) ──
// Altta login_screen.dart içeriği mevcut; import etmek istersen:
// import 'features/auth/login_screen.dart';

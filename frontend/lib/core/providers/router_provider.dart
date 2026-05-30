import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/router/router_refresh.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/auth_route_page.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/app_route_page.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/presentation/about_page.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/presentation/contact_page.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/presentation/download_page.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/presentation/landing_page.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/presentation/marketing_privacy_page.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/presentation/marketing_shell.dart';

final firebaseInitErrorProvider = Provider<String?>((ref) => null);

final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firebaseInitError = ref.watch(firebaseInitErrorProvider);

  return GoRouter(
    initialLocation: kIsWeb ? AppRoutes.home : AppRoutes.appOzet,
    refreshListenable: RouterRefreshListenable(authService.authStateChanges),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final path = state.matchedLocation;

      if (loggedIn && path == AppRoutes.auth) {
        return AppRoutes.appOzet;
      }
      if (!loggedIn && AppRoutes.isAppLocation(path)) {
        return AppRoutes.auth;
      }
      if (loggedIn && path == AppRoutes.app) {
        return AppRoutes.appOzet;
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MarketingShell(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LandingPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.about,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AboutPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.contact,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.download,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DownloadPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.privacy,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MarketingPrivacyPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) {
          final startOnRegister =
              state.uri.queryParameters[AppRoutes.authRegisterQuery] == '1';
          return MaterialPage(
            child: AuthRoutePage(
              firebaseInitError: firebaseInitError,
              startOnRegister: startOnRegister,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.app,
        pageBuilder: (context, state) => MaterialPage(
          child: AppRoutePage(firebaseInitError: firebaseInitError),
        ),
        routes: [
          GoRoute(
            path: 'ozet',
            pageBuilder: (context, state) => MaterialPage(
              child: AppRoutePage(firebaseInitError: firebaseInitError),
            ),
          ),
          GoRoute(
            path: 'analiz',
            pageBuilder: (context, state) => MaterialPage(
              child: AppRoutePage(firebaseInitError: firebaseInitError),
            ),
          ),
          GoRoute(
            path: 'takvim',
            pageBuilder: (context, state) => MaterialPage(
              child: AppRoutePage(firebaseInitError: firebaseInitError),
            ),
          ),
          GoRoute(
            path: 'profil',
            pageBuilder: (context, state) => MaterialPage(
              child: AppRoutePage(firebaseInitError: firebaseInitError),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Sayfa bulunamadı: ${state.uri}'),
        ),
      ),
    ),
  );
});

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/auth_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/splash_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/authenticated_home.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    this.firebaseInitError,
  });

  final String? firebaseInitError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return AuthScreen(
            authService: authService,
            firebaseInitError: firebaseInitError,
          );
        }

        return AuthenticatedHome(
          user: user,
          authService: authService,
        );
      },
    );
  }
}

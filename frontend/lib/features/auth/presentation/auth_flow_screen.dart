import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/auth_onboarding_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/auth_screen.dart';

class AuthFlowScreen extends ConsumerStatefulWidget {
  const AuthFlowScreen({
    super.key,
    required this.authService,
    this.firebaseInitError,
  });

  final AuthService authService;
  final String? firebaseInitError;

  @override
  ConsumerState<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends ConsumerState<AuthFlowScreen> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _showOnboarding =
        !(prefs.getBool(AppConstants.authOnboardingCompletedKey) ?? false);
  }

  Future<void> _completeOnboarding() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(AppConstants.authOnboardingCompletedKey, true);
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showOnboarding
          ? AuthOnboardingScreen(
              key: const ValueKey('onboarding'),
              onComplete: _completeOnboarding,
            )
          : AuthScreen(
              key: const ValueKey('auth'),
              authService: widget.authService,
              firebaseInitError: widget.firebaseInitError,
            ),
    );
  }
}

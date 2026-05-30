import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/auth_flow_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_navbar.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_footer.dart';

/// Giriş / kayıt — üstte tanıtım navbar, altta auth akışı.
class AuthRoutePage extends StatelessWidget {
  const AuthRoutePage({
    super.key,
    this.firebaseInitError,
    this.startOnRegister = false,
  });

  final String? firebaseInitError;
  final bool startOnRegister;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            MarketingNavbar(location: AppRoutes.auth),
            Expanded(
              child: AuthFlowScreen(
                firebaseInitError: firebaseInitError,
                startOnRegister: startOnRegister,
              ),
            ),
            const MarketingFooter(showNavLinks: false),
          ],
        ),
      ),
    );
  }
}

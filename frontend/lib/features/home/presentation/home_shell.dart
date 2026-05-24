import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/home_shell_mobile.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/home_shell_web.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ResponsiveBreakpoints.isWideLayout(context)) {
      return HomeShellWeb(
        user: user,
        authService: authService,
      );
    }

    return HomeShellMobile(
      user: user,
      authService: authService,
    );
  }
}

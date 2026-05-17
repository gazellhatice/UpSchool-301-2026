import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_theme.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/auth_gate.dart';

class HarcamaKocuApp extends ConsumerWidget {
  const HarcamaKocuApp({super.key, this.firebaseInitError});

  final String? firebaseInitError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Kişisel Harcama Koçu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: AuthGate(firebaseInitError: firebaseInitError),
    );
  }
}

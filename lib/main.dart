import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: depend_on_referenced_packages
import 'firebase_options.dart'; // flutterfire configure tarafından üretilir
import 'features/auth/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Durum çubuğunu transparan yap (immersive görünüm)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  await DbService.instance.init(); // ← bunu ekle

  runApp(
    // Riverpod: tüm provider'ların erişebildiği kök widget
    const ProviderScope(
      child: MmasApp(),
    ),
  );
}


class MmasApp extends ConsumerWidget {
  const MmasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MMAS Money Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1DB954),
        secondary: Color(0xFF1DB954),
        surface: Color(0xFF141414),
        error: Color(0xFFFF6B6B),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      useMaterial3: true,
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/sync_status_provider.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/splash_screen.dart';
import 'package:kisisel_harcama_kocu_1/core/navigation/app_navigation.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/home_shell.dart';

class AuthenticatedHome extends ConsumerStatefulWidget {
  const AuthenticatedHome({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  ConsumerState<AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends ConsumerState<AuthenticatedHome> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final syncResult = await ref
          .read(financeRepositoryProvider(widget.user.uid))
          .initialize();
      if (syncResult.success) {
        await ref.read(lastSyncAtProvider.notifier).markSynced();
      }
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _ready = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SplashScreen();
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Veritabanı başlatılamadı: $_error'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _ready = false;
                      _error = null;
                    });
                    _initialize();
                  },
                  child: const Text('Tekrar dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // userChanges() stream'i — displayName, photoURL değişince otomatik yenilenir
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: widget.user,
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.user;
        return AppNavigationSync(
          child: HomeShell(
            user: user,
            authService: widget.authService,
          ),
        );
      },
    );
  }
}
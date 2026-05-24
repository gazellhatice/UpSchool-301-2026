import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/widgets/auth_form_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authService,
    this.firebaseInitError,
  });

  final AuthService authService;
  final String? firebaseInitError;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerName = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerPasswordConfirm = TextEditingController();

  int _tabIndex = 0;
  bool _loading = false;
  bool _obscureLogin = true;
  bool _obscureRegister = true;
  String? _error;

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerName.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    _registerPasswordConfirm.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_tabIndex == index) return;
    setState(() {
      _tabIndex = index;
      _error = null;
    });
  }

  Future<void> _submitLogin() async {
    await _runAuth(() => widget.authService.signInWithEmail(
          email: _loginEmail.text,
          password: _loginPassword.text,
        ));
  }

  Future<void> _submitRegister() async {
    if (_registerPassword.text != _registerPasswordConfirm.text) {
      setState(() => _error = 'Şifreler eşleşmiyor.');
      return;
    }
    if (_registerPassword.text.length < 6) {
      setState(() => _error = 'Şifre en az 6 karakter olmalı.');
      return;
    }

    await _runAuth(() => widget.authService.registerWithEmail(
          email: _registerEmail.text,
          password: _registerPassword.text,
          displayName: _registerName.text,
        ));
  }

  Future<void> _submitGoogle() async {
    await _runAuth(widget.authService.signInWithGoogle);
  }

  Future<void> _forgotPassword() async {
    final email = _loginEmail.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Şifre sıfırlama için e-posta gir.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.mark_email_read_outlined, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Şifre sıfırlama bağlantısı e-postana gönderildi.',
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Şifre sıfırlama gönderilemedi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _runAuth(Future<dynamic> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await action();
    } on AuthCanceledException {
      return;
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() {
        _error = kIsWeb
            ? 'Bağlantı hatası. Firebase ayarlarını kontrol et.'
            : 'İşlem başarısız: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width > 520 ? 440.0 : double.infinity;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - 80,
                  maxWidth: maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 64, borderRadius: 18)),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hesabına giriş yap veya yeni hesap oluştur.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.firebaseInitError != null) ...[
                      AuthErrorBanner(
                        message: widget.firebaseInitError!,
                        isWarning: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTabSwitcher(
                            index: _tabIndex,
                            onChanged: _switchTab,
                          ),
                          const SizedBox(height: 20),
                          if (_error != null) ...[
                            AuthErrorBanner(message: _error!),
                            const SizedBox(height: 16),
                          ],
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _tabIndex == 0
                                ? AuthLoginForm(
                                    key: const ValueKey('login'),
                                    email: _loginEmail,
                                    password: _loginPassword,
                                    obscure: _obscureLogin,
                                    loading: _loading,
                                    onToggleObscure: () => setState(
                                      () => _obscureLogin = !_obscureLogin,
                                    ),
                                    onSubmit: _submitLogin,
                                    onForgotPassword: _forgotPassword,
                                  )
                                : AuthRegisterForm(
                                    key: const ValueKey('register'),
                                    name: _registerName,
                                    email: _registerEmail,
                                    password: _registerPassword,
                                    confirm: _registerPasswordConfirm,
                                    obscure: _obscureRegister,
                                    loading: _loading,
                                    onToggleObscure: () => setState(
                                      () =>
                                          _obscureRegister = !_obscureRegister,
                                    ),
                                    onSubmit: _submitRegister,
                                  ),
                          ),
                          const SizedBox(height: 20),
                          const AuthOrDivider(),
                          const SizedBox(height: 16),
                          AuthGoogleButton(
                            loading: _loading,
                            onPressed: _submitGoogle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AuthTrustFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

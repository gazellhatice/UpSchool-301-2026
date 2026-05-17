import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';

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

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerName = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerPasswordConfirm = TextEditingController();

  bool _loading = false;
  bool _obscureLogin = true;
  bool _obscureRegister = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _error = null);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerName.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    _registerPasswordConfirm.dispose();
    super.dispose();
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
          const SnackBar(
            content: Text('Şifre sıfırlama bağlantısı e-postana gönderildi.'),
            behavior: SnackBarBehavior.floating,
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

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroHeader(theme: theme, palette: palette),
                  const SizedBox(height: 24),
                  if (widget.firebaseInitError != null) ...[
                    _ErrorBox(message: widget.firebaseInitError!, isWarning: true),
                    const SizedBox(height: 12),
                  ],
                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          unselectedLabelStyle: theme.textTheme.titleSmall,
                          tabs: const [
                            Tab(text: 'Giriş yap'),
                            Tab(text: 'Kayıt ol'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_error != null) ...[
                          _ErrorBox(message: _error!),
                          const SizedBox(height: 12),
                        ],
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            return IndexedStack(
                              index: _tabController.index,
                              children: [
                                _LoginForm(
                                  email: _loginEmail,
                                  password: _loginPassword,
                                  obscure: _obscureLogin,
                                  loading: _loading,
                                  onToggleObscure: () => setState(
                                    () => _obscureLogin = !_obscureLogin,
                                  ),
                                  onSubmit: _submitLogin,
                                  onForgotPassword: _forgotPassword,
                                ),
                                _RegisterForm(
                                  name: _registerName,
                                  email: _registerEmail,
                                  password: _registerPassword,
                                  confirm: _registerPasswordConfirm,
                                  obscure: _obscureRegister,
                                  loading: _loading,
                                  onToggleObscure: () => setState(
                                    () => _obscureRegister = !_obscureRegister,
                                  ),
                                  onSubmit: _submitRegister,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Divider(color: palette.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'veya',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: palette.border)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GoogleButton(
                          loading: _loading,
                          onPressed: _submitGoogle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.theme, required this.palette});

  final ThemeData theme;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Text(
            'Kişisel Harcama Koçu',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: palette.heroTitleColors,
          ).createShader(bounds),
          child: Text(
            'Paranı\nkontrol altına al.',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
              color: palette.textPrimary,
              letterSpacing: -1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'E-posta ile kayıt ol veya giriş yap; verilerin Firestore ile senkronize edilir.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: palette.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.email,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: loading ? null : onForgotPassword,
            child: const Text('Şifremi unuttum'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Giriş yap'),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.name,
    required this.email,
    required this.password,
    required this.confirm,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirm;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: password,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: confirm,
          obscureText: obscure,
          decoration: const InputDecoration(
            labelText: 'Şifre tekrar',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Kayıt ol'),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? Colors.white : const Color(0xFFF8F9FC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.g_mobiledata_rounded, size: 28),
              const SizedBox(width: 8),
              Text(
                'Google ile devam et',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFF0F1419),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, this.isWarning = false});

  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.accentWarm : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.info_outline : Icons.error_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/features/legal/privacy_policy_screen.dart';

class AuthTabSwitcher extends StatelessWidget {
  const AuthTabSwitcher({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surfaceLight.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          _TabOption(
            label: 'Giriş yap',
            icon: Icons.login_rounded,
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          _TabOption(
            label: 'Kayıt ol',
            icon: Icons.person_add_alt_1_rounded,
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabOption extends StatelessWidget {
  const _TabOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF3D5AFE),
                    Color(0xFF7C4DFF),
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? Colors.white : palette.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : palette.textSecondary,
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

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    super.key,
    required this.message,
    this.isWarning = false,
  });

  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.accentWarm : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.info_outline_rounded : Icons.error_outline_rounded,
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
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


class AuthLoginForm extends StatelessWidget {
  const AuthLoginForm({
    super.key,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            hintText: 'ornek@mail.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!loading) onSubmit();
          },
          decoration: InputDecoration(
            labelText: 'Şifre',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: loading ? null : onForgotPassword,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            child: const Text('Şifremi unuttum'),
          ),
        ),
        const SizedBox(height: 4),
        AuthPrimaryButton(
          label: 'Giriş yap',
          icon: Icons.login_rounded,
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class AuthRegisterForm extends StatelessWidget {
  const AuthRegisterForm({
    super.key,
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
    return ListenableBuilder(
      listenable: Listenable.merge([password, confirm]),
      builder: (context, _) {
        final pwd = password.text;
        final hasMinLength = pwd.length >= 6;
        final passwordsMatch =
            confirm.text.isNotEmpty && pwd == confirm.text;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                hintText: 'Adın Soyadın',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                hintText: 'ornek@mail.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: obscure,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Şifre',
                hintText: 'En az 6 karakter',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirm,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!loading) onSubmit();
              },
              decoration: const InputDecoration(
                labelText: 'Şifre tekrar',
                hintText: 'Şifreni tekrar gir',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            _PasswordChecklist(
              hasMinLength: hasMinLength,
              passwordsMatch: passwordsMatch,
            ),
            const SizedBox(height: 16),
            AuthPrimaryButton(
              label: 'Kayıt ol',
              icon: Icons.person_add_alt_1_rounded,
              loading: loading,
              onPressed: onSubmit,
            ),
          ],
        );
      },
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  const _PasswordChecklist({
    required this.hasMinLength,
    required this.passwordsMatch,
  });

  final bool hasMinLength;
  final bool passwordsMatch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CheckRow(
          label: 'En az 6 karakter',
          met: hasMinLength,
        ),
        const SizedBox(height: 6),
        _CheckRow(
          label: 'Şifreler eşleşiyor',
          met: passwordsMatch,
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = met ? AppColors.accent : palette.textSecondary;

    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: loading
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFF3D5AFE),
                  Color(0xFF7C4DFF),
                ],
              ),
        boxShadow: loading
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: loading ? null : Colors.transparent,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? palette.surfaceLight.withValues(alpha: 0.9)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.border),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Google ile devam et',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthTrustFooter extends StatelessWidget {
  const AuthTrustFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 16,
              color: palette.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Verilerin Firebase ile güvenle saklanır',
              style: theme.textTheme.labelSmall?.copyWith(
                color: palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyPolicyScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Gizlilik Politikası'),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.appName,
          style: theme.textTheme.labelSmall?.copyWith(
            color: palette.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Divider(color: palette.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'veya',
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: palette.border)),
      ],
    );
  }
}

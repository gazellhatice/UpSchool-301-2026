import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';

/// Geniş ekranda giriş formunun yanında marka paneli.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppLogo(size: 72, borderRadius: 20),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Gelir ve giderlerini takip et, görsel analizlerle harcama '
          'alışkanlığını gör ve AI Finans Koçu\'ndan kişisel öneriler al.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: palette.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        const _ValueRow(
          icon: Icons.offline_bolt_rounded,
          title: 'Offline-first',
          subtitle: 'İnternet yokken kayıt, sonra senkron',
        ),
        const SizedBox(height: 12),
        const _ValueRow(
          icon: Icons.auto_awesome_rounded,
          title: 'Veriye dayalı AI',
          subtitle: 'Koç yanıtları senin gerçek işlemlerine göre',
        ),
        const SizedBox(height: 12),
        const _ValueRow(
          icon: Icons.devices_rounded,
          title: 'Tek hesap',
          subtitle: 'Mobil ve web\'de aynı veriler',
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.school_rounded, color: AppColors.primary.withValues(alpha: 0.9)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Future Talent 2026 · Bitirme Projesi',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.palette.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

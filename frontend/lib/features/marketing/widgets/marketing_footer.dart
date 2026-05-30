import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';

class MarketingFooter extends StatelessWidget {
  const MarketingFooter({
    super.key,
    this.showNavLinks = true,
  });

  /// Giriş sayfasında navbar ile tekrar etmemek için kapatılabilir.
  final bool showNavLinks;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final year = DateTime.now().year;
    final linkStyle = theme.textTheme.labelSmall?.copyWith(
      color: palette.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.glassBorder)),
        color: palette.surface.withValues(alpha: 0.45),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showNavLinks) ...[
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 0,
                  children: [
                    _FooterLink(
                      label: 'Ana Sayfa',
                      style: linkStyle,
                      onTap: () => context.go(AppRoutes.home),
                    ),
                    _FooterLink(
                      label: 'Hakkında',
                      style: linkStyle,
                      onTap: () => context.go(AppRoutes.about),
                    ),
                    _FooterLink(
                      label: 'Uygulamayı indir',
                      style: linkStyle,
                      onTap: () => context.go(AppRoutes.download),
                    ),
                    _FooterLink(
                      label: 'İletişim',
                      style: linkStyle,
                      onTap: () => context.go(AppRoutes.contact),
                    ),
                    _FooterLink(
                      label: 'Gizlilik',
                      style: linkStyle,
                      onTap: () => context.go(AppRoutes.privacy),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Text(
                '© $year ${AppConstants.appName} · Future Talent · Hatice Gazell',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.onTap,
    this.style,
  });

  final String label;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(label, style: style),
    );
  }
}

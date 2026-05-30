import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_section_header.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  static String qrPayload() {
    if (kIsWeb) {
      final base = Uri.base;
      if (base.host.isNotEmpty) {
        return '${base.origin}${AppRoutes.download}';
      }
    }
    return 'https://kisisel-harcama-kocu.app${AppRoutes.download}';
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bağlantı açılamadı: $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final wide = MediaQuery.sizeOf(context).width >= 800;
    final qrData = qrPayload();

    final qrCard = _QrCard(palette: palette, qrPayload: qrData);
    final actions = _DownloadActions(
      onOpenUrl: (url) => _openUrl(context, url),
    );

    return MarketingPageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MarketingSectionHeader(
            title: 'Mobil uygulamayı indir',
            subtitle:
                'Telefonundan gelir-gider takibi, analiz ve AI finans koçuna eriş. '
                'QR kodu okut veya mağaza bağlantısını kullan.',
          ),
          const SizedBox(height: 28),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: qrCard),
                const SizedBox(width: 24),
                Expanded(flex: 6, child: actions),
              ],
            )
          else ...[
            qrCard,
            const SizedBox(height: 24),
            actions,
          ],
          const SizedBox(height: 20),
          Text(
            'Mağaza bağlantıları demo amaçlıdır; yayınlandığında '
            '${AppConstants.appName} sayfasına yönlendirilecektir.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.textSecondary,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.palette, required this.qrPayload});

  final AppPalette palette;
  final String qrPayload;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 200,
              gapless: true,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1A2E),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kameranla okut',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bu sayfaya yönlendirir; Android veya iOS indirme seçeneklerini görürsün.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _DownloadActions extends StatelessWidget {
  const _DownloadActions({required this.onOpenUrl});

  final void Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StoreButton(
          icon: Icons.android_rounded,
          label: 'Google Play',
          subtitle: 'Android cihazlar için',
          color: const Color(0xFF3DDC97),
          onTap: () => onOpenUrl(AppConstants.playStoreUrl),
        ),
        const SizedBox(height: 10),
        _StoreButton(
          icon: Icons.apple_rounded,
          label: 'App Store',
          subtitle: 'iPhone ve iPad için',
          color: const Color(0xFF5B8CFF),
          onTap: () => onOpenUrl(AppConstants.appStoreUrl),
        ),
        const SizedBox(height: 10),
        _StoreButton(
          icon: Icons.download_rounded,
          label: 'APK indir',
          subtitle: 'Doğrudan kurulum (Android)',
          color: AppColors.primary,
          onTap: () => onOpenUrl(AppConstants.apkDownloadUrl),
        ),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kurulum adımları',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              const _StepRow(
                number: '1',
                text: 'QR kodu okut veya mağazadan indir.',
              ),
              const _StepRow(
                number: '2',
                text: 'Uygulamayı aç ve hesap oluştur.',
              ),
              const _StepRow(
                number: '3',
                text: 'Web ile aynı hesapla giriş yap — veriler senkron olur.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.auth),
          icon: const Icon(Icons.language_rounded, size: 18),
          label: const Text('Web sürümünü kullan'),
        ),
      ],
    );
  }
}

class _StoreButton extends StatelessWidget {
  const _StoreButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.glassSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

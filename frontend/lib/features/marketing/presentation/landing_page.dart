import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_section_header.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_trust_bar.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_widgets.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/product_preview_card.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final wide = MediaQuery.sizeOf(context).width >= 800;

    return MarketingPageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroSection(wide: wide, palette: palette),
          const SizedBox(height: 28),
          const MarketingTrustBar(),
          const SizedBox(height: 48),
          const MarketingMetricStrip(),
          const SizedBox(height: 56),
          const MarketingSectionHeader(
            title: 'Neden Kişisel Harcama Koçu?',
            subtitle:
                'Sadece kayıt tutmaz — verini okuyan, Türkçe konuşan bir finans asistanı sunar.',
            centered: true,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: wide ? 1.05 : 1.35,
                children: const [
                  MarketingFeatureCard(
                    icon: Icons.cloud_off_rounded,
                    title: 'Offline-first',
                    description:
                        'İnternet yokken bile işlem ekle. Bağlantı gelince Firebase ile senkron olur.',
                    accentColor: AppColors.accent,
                  ),
                  MarketingFeatureCard(
                    icon: Icons.donut_large_rounded,
                    title: 'Görsel analiz',
                    description:
                        'Pasta grafik, aylık trend ve takvim ile harcamalarını tek bakışta gör.',
                    accentColor: AppColors.primary,
                  ),
                  MarketingFeatureCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Finans Koçu (AI)',
                    description:
                        'Gemini destekli koç, senin gerçek gelir-gider verine göre kişisel tavsiye verir.',
                    accentColor: Color(0xFF6C63FF),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 56),
          const MarketingSectionHeader(title: 'Nasıl çalışır?'),
          const SizedBox(height: 20),
          const MarketingStepCard(
            step: '1',
            title: 'Ücretsiz hesap oluştur',
            description:
                'E-posta veya Google ile kayıt ol. Verilerin güvenli Firebase hesabına bağlanır.',
          ),
          const SizedBox(height: 12),
          const MarketingStepCard(
            step: '2',
            title: 'Gelir ve giderlerini kaydet',
            description:
                'Kategoriler, notlar ve takvim ile günlük finansını düzenli tut.',
          ),
          const SizedBox(height: 12),
          const MarketingStepCard(
            step: '3',
            title: 'AI koçuna sor',
            description:
                '“Bu ay fazla mı harcadım?” gibi sorular sor; yanıt senin verilerine dayanır.',
          ),
          const SizedBox(height: 48),
          _JuryQuoteCard(palette: palette),
          const SizedBox(height: 48),
          _FinalCta(palette: palette),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.wide, required this.palette});

  final bool wide;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final headline = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                const Color(0xFF6C63FF).withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Future Talent 2026 · AI destekli finans',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Paranı yönet,\nAI koçunla bilinçli harca.',
          textAlign: wide ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.08,
                letterSpacing: -1.2,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          '${AppConstants.appName}, gelir ve giderlerini Türkçe arayüzle takip etmeni sağlar. '
          'Finans Koçu her ayki verilerini okuyarak sana özel öneriler sunar.',
          textAlign: wide ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.textSecondary,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: wide ? WrapAlignment.center : WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go(
                '${AppRoutes.auth}?${AppRoutes.authRegisterQuery}=1',
              ),
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Ücretsiz başla'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.auth),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Canlı demoyu dene'),
            ),
          ],
        ),
      ],
    );

    const visual = ProductPreviewCard();

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: headline),
          const SizedBox(width: 40),
          const Expanded(flex: 6, child: visual),
        ],
      );
    }

    return Column(
      children: [
        headline,
        const SizedBox(height: 32),
        visual,
      ],
    );
  }
}

class _JuryQuoteCard extends StatelessWidget {
  const _JuryQuoteCard({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 40,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            '“Hazır cevaplı bir chatbot değil — kullanıcının kendi kayıtlı '
            'harcama verisine dayalı, Türkçe ve güvenli bir finans koçu.”',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bitirme projesi · Hatice Gazell',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _FinalCta extends StatelessWidget {
  const _FinalCta({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A2450),
            Color(0xFF121A3A),
            Color(0xFF0A1024),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Hemen başla — ücretsiz',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Web, Android ve iOS için tek hesap. Tarayıcıdan kullan veya mobilde indir.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => context.go(
                  '${AppRoutes.auth}?${AppRoutes.authRegisterQuery}=1',
                ),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Kayıt ol'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.about),
                child: const Text('Projeyi incele'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

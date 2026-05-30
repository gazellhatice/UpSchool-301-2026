import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_section_header.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MarketingPageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MarketingSectionHeader(
            title: 'Hakkında',
            subtitle:
                'Future Talent 2026 bitirme projesi — yapay zeka destekli kişisel finans.',
          ),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.gradientCard,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hatice Gazell',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Geliştirici · Future Talent 2026',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Flutter, Firebase ve Node.js ile uçtan uca geliştirilmiş; '
                        'AI koç katmanı backend üzerinden güvenli şekilde sunulur.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _AboutBlock(
            title: 'Problem',
            body:
                'Birçok kişi harcamalarını dağınık tutuyor; ay sonunda nereye gittiğini '
                'görmek zor. Basit, Türkçe ve güvenilir bir araç eksikliği var.',
          ),
          const SizedBox(height: 16),
          const _AboutBlock(
            title: 'Çözüm',
            body:
                'Gelir-gider kaydı, görsel analiz ve gerçek verilere dayalı Finans Koçu '
                'tek uygulamada birleşiyor. Offline çalışır, bulutta senkron olur.',
          ),
          const SizedBox(height: 16),
          const _AboutBlock(
            title: 'Hedef kitle',
            body:
                'Türkiye\'deki genç profesyoneller, öğrenciler ve serbest çalışanlar. '
                'Arayüz Türkçe, para birimi ₺.',
          ),
          const SizedBox(height: 32),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teknoloji yığını',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                const _TechRow(
                  icon: Icons.phone_android_rounded,
                  label: 'Frontend',
                  value: 'Flutter · Riverpod · Drift · Firebase',
                ),
                _TechRow(
                  icon: Icons.dns_rounded,
                  label: 'Backend',
                  value: 'Node.js · Express · Gemini / OpenRouter',
                ),
                _TechRow(
                  icon: Icons.language_rounded,
                  label: 'Web',
                  value: 'Responsive shell · go_router · Firebase Hosting',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.auth),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Canlı demoyu dene'),
          ),
        ],
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.palette.textSecondary,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  const _TechRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

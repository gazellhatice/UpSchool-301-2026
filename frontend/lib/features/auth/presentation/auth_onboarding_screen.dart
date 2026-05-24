import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';

class AuthOnboardingScreen extends StatefulWidget {
  const AuthOnboardingScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<AuthOnboardingScreen> createState() => _AuthOnboardingScreenState();
}

class _AuthOnboardingScreenState extends State<AuthOnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slides = [
    _OnboardingSlide(
      eyebrow: 'HOŞ GELDİN',
      title: 'Paranı kontrol\naltına al.',
      body:
          'Gelir ve giderlerini tek yerden yönet; finansal hedeflerine adım adım yaklaş.',
      icon: Icons.account_balance_wallet_rounded,
      gradient: AppColors.gradientCard,
      showLogo: true,
    ),
    _OnboardingSlide(
      eyebrow: 'TAKİP ET',
      title: 'Her harcamayı\nnet gör.',
      body:
          'Özet, analiz ve takvim sekmeleriyle bütçeni, trendlerini ve günlük akışını izle.',
      icon: Icons.insights_rounded,
      gradient: [Color(0xFF00C9A7), Color(0xFF3D5AFE)],
    ),
    _OnboardingSlide(
      eyebrow: 'AI KOÇ',
      title: 'Akıllı öneriler\nalsın.',
      body:
          'Finans koçun harcama alışkanlıklarını yorumlasın; verilerin güvenle senkronize edilsin.',
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final isLast = _page == _slides.length - 1;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: widget.onComplete,
                    icon: Icon(
                      Icons.close_rounded,
                      color: palette.textSecondary,
                    ),
                    label: Text(
                      'Kapat',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) {
                    return _OnboardingPage(slide: _slides[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final active = index == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: active
                                ? AppColors.primary
                                : palette.border,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(isLast ? 'Girişe geç' : 'İleri'),
                      ),
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.onComplete,
                        child: const Text('Atla'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.gradient,
    this.showLogo = false,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final List<Color> gradient;
  final bool showLogo;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (slide.showLogo) ...[
            const AppLogo(size: 96),
            const SizedBox(height: 28),
          ] else
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: slide.gradient),
                boxShadow: [
                  BoxShadow(
                    color: slide.gradient.first.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(slide.icon, color: Colors.white, size: 44),
            ),
          if (!slide.showLogo) const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              slide.eyebrow,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (slide.showLogo)
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          if (slide.showLogo) const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: palette.heroTitleColors,
            ).createShader(bounds),
            child: Text(
              slide.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.08,
                color: palette.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

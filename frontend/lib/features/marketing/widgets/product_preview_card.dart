import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';

/// Landing hero — uygulama arayüzünü simüle eden canlı önizleme.
class ProductPreviewCard extends StatefulWidget {
  const ProductPreviewCard({super.key});

  @override
  State<ProductPreviewCard> createState() => _ProductPreviewCardState();
}

class _ProductPreviewCardState extends State<ProductPreviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final dy = (_float.value - 0.5) * 8;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGlow.withValues(alpha: 0.25),
              blurRadius: 48,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PreviewChrome(palette: palette),
              Container(
                color: const Color(0xFF0A0E18),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SidebarMock(palette: palette),
                    const SizedBox(width: 12),
                    Expanded(child: _DashboardMock(palette: palette)),
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

class _PreviewChrome extends StatelessWidget {
  const _PreviewChrome({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: palette.surface.withValues(alpha: 0.95),
      child: Row(
        children: [
          _Dot(AppColors.danger),
          const SizedBox(width: 6),
          _Dot(AppColors.accentWarm),
          const SizedBox(width: 6),
          _Dot(AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.glassSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.glassBorder),
              ),
              child: Text(
                'harcama-kocu.web.app/uygulama/ozet',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: palette.textSecondary,
                      fontSize: 10,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SidebarMock extends StatelessWidget {
  const _SidebarMock({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Column(
        children: [
          const AppLogo(size: 28, borderRadius: 8),
          const SizedBox(height: 14),
          _NavIcon(Icons.dashboard_rounded, selected: true),
          _NavIcon(Icons.pie_chart_outline_rounded),
          _NavIcon(Icons.calendar_month_outlined),
          _NavIcon(Icons.person_outline_rounded),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(this.icon, {this.selected = false});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DashboardMock extends StatelessWidget {
  const _DashboardMock({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricChip(
                label: 'Net bakiye',
                value: '₺12.450',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricChip(
                label: 'Gider',
                value: '₺8.200',
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.glassBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final h in [0.35, 0.55, 0.4, 0.7, 0.5, 0.85, 0.6])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FractionallySizedBox(
                      heightFactor: h,
                      alignment: Alignment.bottomCenter,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.primary,
                              Color(0xFF6C63FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...[
          ('Yemek', '-₺185', Icons.restaurant_rounded, AppColors.accentWarm),
          ('Maaş', '+₺28.000', Icons.work_outline_rounded, AppColors.accent),
        ].map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _TxRow(
              title: row.$1,
              amount: row.$2,
              icon: row.$3,
              color: row.$4,
              palette: palette,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Koç: Yemek %18 azaltırsan bütçe hedefine yaklaşırsın.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.palette,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final income = amount.startsWith('+');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: income ? AppColors.accent : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

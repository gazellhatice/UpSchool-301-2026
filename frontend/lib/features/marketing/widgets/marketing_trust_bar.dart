import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';

class MarketingTrustBar extends StatelessWidget {
  const MarketingTrustBar({super.key});

  static const _items = [
    (Icons.flutter_dash, 'Flutter'),
    (Icons.cloud_rounded, 'Firebase'),
    (Icons.auto_awesome_rounded, 'AI Koç'),
    (Icons.school_rounded, 'Future Talent 2026'),
    (Icons.translate_rounded, 'Türkçe · ₺'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: _items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: palette.glassSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.$1, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                item.$2,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class MarketingMetricStrip extends StatelessWidget {
  const MarketingMetricStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;

    final metrics = [
      ('4', 'Ana modül', Icons.grid_view_rounded),
      ('AI', 'Kişisel koç', Icons.psychology_rounded),
      ('%100', 'Türkçe arayüz', Icons.flag_rounded),
    ];

    final children = metrics.map((m) {
      return Expanded(
        child: _MetricTile(
          value: m.$1,
          label: m.$2,
          icon: m.$3,
        ),
      );
    }).toList();

    if (wide) {
      return Row(children: children);
    }
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            palette.surface.withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

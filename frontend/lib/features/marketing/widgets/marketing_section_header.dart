import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';

class MarketingSectionHeader extends StatelessWidget {
  const MarketingSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.centered = false,
  });

  final String title;
  final String? subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final align = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: align,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: align,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                  height: 1.45,
                ),
          ),
        ],
      ],
    );
  }
}

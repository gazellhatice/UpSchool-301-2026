import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.borderRadius,
    this.showShadow = true,
  });

  final double size;
  final double? borderRadius;
  final bool showShadow;

  static const assetPath = 'assets/images/splash_logo.png';

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size * 0.28;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

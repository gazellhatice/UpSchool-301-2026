import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_widgets.dart';

class MarketingPrivacyPage extends StatelessWidget {
  const MarketingPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MarketingPageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gizlilik politikası',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            AppConstants.privacyPolicyBody.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.55,
                  color: palette.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

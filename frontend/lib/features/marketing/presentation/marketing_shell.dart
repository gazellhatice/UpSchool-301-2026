import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/landing_team_announcement.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_footer.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_navbar.dart';

class MarketingShell extends StatelessWidget {
  const MarketingShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MarketingNavbar(location: location),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SingleChildScrollView(child: child),
                  if (AppRoutes.showsTeamAnnouncement(location))
                    const LandingTeamAnnouncement(),
                ],
              ),
            ),
            const MarketingFooter(),
          ],
        ),
      ),
    );
  }
}

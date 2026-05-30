import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/coach_panel_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/app_keyboard_shortcuts.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/app_shell_top_bar.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/settings_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/web_app_sidebar.dart';

class HomeShellWeb extends ConsumerWidget {
  const HomeShellWeb({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    final coachOpen = ref.watch(coachPanelOpenProvider);
    final palette = context.palette;

    return AppKeyboardShortcuts(
      user: user,
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: ResponsiveBreakpoints.sidebarWidth,
                  child: WebAppSidebar(
                    user: user,
                    authService: authService,
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppShellTopBar(
                              tabIndex: index,
                              user: user,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth:
                                        ResponsiveBreakpoints.contentMaxWidth,
                                  ),
                                  child: IndexedStack(
                                    index: index,
                                    children: [
                                      DashboardTab(user: user),
                                      StatsTab(
                                        userId: user.uid,
                                        user: user,
                                      ),
                                      CalendarTab(
                                        userId: user.uid,
                                        user: user,
                                      ),
                                      SettingsTab(
                                        user: user,
                                        authService: authService,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (coachOpen)
                        Container(
                          width: 400,
                          margin: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(-4, 0),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CoachChatScreen(
                            user: user,
                            embedded: true,
                            onClose: () => ref
                                .read(coachPanelOpenProvider.notifier)
                                .state = false,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

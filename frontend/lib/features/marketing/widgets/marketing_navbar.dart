import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketingNavbar extends ConsumerStatefulWidget {
  const MarketingNavbar({
    super.key,
    required this.location,
  });

  final String location;

  @override
  ConsumerState<MarketingNavbar> createState() => _MarketingNavbarState();
}

class _MarketingNavbarState extends ConsumerState<MarketingNavbar> {
  bool _menuOpen = false;

  void _navigate(String path) {
    setState(() => _menuOpen = false);
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final user = FirebaseAuth.instance.currentUser;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Material(
      color: palette.glassSurface.withValues(alpha: 0.92),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.glassBorder)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => _navigate(AppRoutes.home),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppLogo(size: 36, borderRadius: 10),
                          const SizedBox(width: 10),
                          if (wide)
                            Text(
                              AppConstants.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (wide) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _navLinks(palette),
                      ),
                      const SizedBox(width: 8),
                      _authActions(context, user),
                    ] else
                      IconButton(
                        onPressed: () =>
                            setState(() => _menuOpen = !_menuOpen),
                        icon: Icon(
                          _menuOpen
                              ? Icons.close_rounded
                              : Icons.menu_rounded,
                        ),
                      ),
                  ],
                ),
                if (!wide && _menuOpen) ...[
                  const SizedBox(height: 16),
                  ..._navLinks(palette, stacked: true),
                  const SizedBox(height: 12),
                  _authActions(context, user, stacked: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _navLinks(AppPalette palette, {bool stacked = false}) {
    final links = [
      (AppRoutes.home, 'Ana Sayfa'),
      (AppRoutes.about, 'Hakkında'),
      (AppRoutes.download, 'Uygulamayı indir'),
      (AppRoutes.contact, 'İletişim'),
    ];

    final children = links.map((link) {
      final selected = widget.location == link.$1;
      return Padding(
        padding: EdgeInsets.only(
          right: stacked ? 0 : 8,
          bottom: stacked ? 8 : 0,
        ),
        child: TextButton(
          onPressed: () => _navigate(link.$1),
          style: TextButton.styleFrom(
            foregroundColor:
                selected ? AppColors.primary : palette.textSecondary,
          ),
          child: Text(
            link.$2,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList();

    if (stacked) {
      return children;
    }
    return children;
  }

  Widget _authActions(
    BuildContext context,
    User? user, {
    bool stacked = false,
  }) {
    if (user != null) {
      final button = FilledButton(
        onPressed: () => context.go(AppRoutes.appOzet),
        child: const Text('Uygulamaya git'),
      );
      if (stacked) {
        return SizedBox(width: double.infinity, child: button);
      }
      return button;
    }

    final login = OutlinedButton(
      onPressed: () => context.go(AppRoutes.auth),
      child: const Text('Giriş yap'),
    );
    final register = FilledButton(
      onPressed: () => context.go('${AppRoutes.auth}?${AppRoutes.authRegisterQuery}=1'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text('Kayıt ol'),
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: double.infinity, child: login),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: register),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        login,
        const SizedBox(width: 8),
        register,
      ],
    );
  }
}

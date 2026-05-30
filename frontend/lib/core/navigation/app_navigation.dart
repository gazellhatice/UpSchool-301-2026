import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';

/// URL ↔ sekme senkronu (web yenilemede sekme korunur).
class AppNavigationSync extends ConsumerStatefulWidget {
  const AppNavigationSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppNavigationSync> createState() => _AppNavigationSyncState();
}

class _AppNavigationSyncState extends ConsumerState<AppNavigationSync> {
  String? _lastAppliedLocation;
  String? _scheduledLocation;

  /// Provider güncellemesi build sırasında yapılamaz — frame sonrasına ertelenir.
  void _scheduleSyncFromUrl(String location) {
    if (!kIsWeb) return;
    if (_scheduledLocation == location) return;
    _scheduledLocation = location;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledLocation = null;
      if (!mounted) return;
      // Eski frame callback'i yeni URL'yi ezmesin.
      final active = GoRouterState.of(context).matchedLocation;
      if (active != location) return;
      _syncTabFromUrl(active);
    });
  }

  void _syncTabFromUrl(String location) {
    if (!kIsWeb) return;
    if (_lastAppliedLocation == location) return;

    final tabIndex = AppRoutes.tabIndexFromLocation(location);
    if (tabIndex == null) return;

    final current = ref.read(homeTabIndexProvider);
    if (current == tabIndex) {
      _lastAppliedLocation = location;
      return;
    }

    _lastAppliedLocation = location;
    ref.read(homeTabIndexProvider.notifier).state = tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    _scheduleSyncFromUrl(location);

    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      if (!kIsWeb) return;

      final target = AppRoutes.tabPath(next);
      final current = GoRouterState.of(context).matchedLocation;
      if (current != target) {
        _lastAppliedLocation = target;
        context.go(target);
      }
    });

    return widget.child;
  }
}

/// Sekme değişiminde URL güncelle (yalnızca web).
void navigateToAppTab(BuildContext context, WidgetRef ref, int index) {
  ref.read(homeTabIndexProvider.notifier).state = index;
  if (kIsWeb) {
    final target = AppRoutes.tabPath(index);
    context.go(target);
  }
}

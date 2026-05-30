import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/coach_panel_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/sync_status_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';

Future<void> performSignOut({
  required BuildContext context,
  required WidgetRef ref,
  required String userId,
  required AuthService authService,
}) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Çıkış yap',
    message: 'Oturumunuz kapatılacak. Yerel veriler bu cihazda kalır.',
    confirmLabel: 'Çıkış yap',
    isDestructive: false,
  );
  if (!ok) return;

  ref.read(coachPanelOpenProvider.notifier).state = false;
  await ref.read(financeRepositoryProvider(userId)).clearLocalUserData();
  ref.read(lastSyncAtProvider.notifier).clear();
  await authService.signOut();

  if (!context.mounted) return;
  if (kIsWeb) {
    context.go(AppRoutes.home);
  }
}

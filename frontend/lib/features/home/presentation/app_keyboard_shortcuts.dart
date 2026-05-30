import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/navigation/app_navigation.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/coach_panel_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _AddTransactionIntent extends Intent {
  const _AddTransactionIntent();
}

class _OpenCoachIntent extends Intent {
  const _OpenCoachIntent();
}

class _SwitchTabIntent extends Intent {
  const _SwitchTabIntent(this.index);
  final int index;
}

class _ClosePanelIntent extends Intent {
  const _ClosePanelIntent();
}

/// Web uygulama kabuğu için klavye kısayolları.
class AppKeyboardShortcuts extends ConsumerWidget {
  const AppKeyboardShortcuts({
    super.key,
    required this.user,
    required this.child,
  });

  final User user;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyN): const _AddTransactionIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyK): const _OpenCoachIntent(),
        LogicalKeySet(LogicalKeyboardKey.digit1): const _SwitchTabIntent(0),
        LogicalKeySet(LogicalKeyboardKey.digit2): const _SwitchTabIntent(1),
        LogicalKeySet(LogicalKeyboardKey.digit3): const _SwitchTabIntent(2),
        LogicalKeySet(LogicalKeyboardKey.digit4): const _SwitchTabIntent(3),
        LogicalKeySet(LogicalKeyboardKey.escape): const _ClosePanelIntent(),
      },
      child: Actions(
        actions: {
          _AddTransactionIntent: CallbackAction<_AddTransactionIntent>(
            onInvoke: (_) {
              final index = ref.read(homeTabIndexProvider);
              if (index == 0 || index == 2) {
                TransactionFormSheet.show(context, user.uid);
              }
              return null;
            },
          ),
          _OpenCoachIntent: CallbackAction<_OpenCoachIntent>(
            onInvoke: (_) {
              CoachChatScreen.open(context, user);
              return null;
            },
          ),
          _SwitchTabIntent: CallbackAction<_SwitchTabIntent>(
            onInvoke: (intent) {
              navigateToAppTab(context, ref, intent.index);
              return null;
            },
          ),
          _ClosePanelIntent: CallbackAction<_ClosePanelIntent>(
            onInvoke: (_) {
              if (ref.read(coachPanelOpenProvider)) {
                ref.read(coachPanelOpenProvider.notifier).state = false;
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

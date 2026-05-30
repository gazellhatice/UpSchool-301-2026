import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';

/// Geniş ekranda dialog, dar ekranda bottom sheet.
Future<T?> showAdaptiveOverlay<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 520,
  bool barrierDismissible = true,
}) {
  if (ResponsiveBreakpoints.isWideLayout(context)) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: builder(ctx),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: barrierDismissible,
    builder: builder,
  );
}

bool useDialogFormLayout(BuildContext context) {
  return ResponsiveBreakpoints.isWideLayout(context);
}

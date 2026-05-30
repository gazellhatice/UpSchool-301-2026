import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/adaptive_overlay.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';

/// Form sheet / dialog için ortak kabuk.
class AdaptiveFormContainer extends StatelessWidget {
  const AdaptiveFormContainer({
    super.key,
    required this.child,
    this.title,
    this.onClose,
  });

  final Widget child;
  final String? title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDialog = useDialogFormLayout(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final content = Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: isDialog ? EdgeInsets.zero : const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(isDialog ? 20 : 28),
          border: Border.all(color: palette.border),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, isDialog ? 20 : 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isDialog)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (onClose != null)
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Kapat',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              child,
            ],
          ),
        ),
      ),
    );

    return content;
  }
}

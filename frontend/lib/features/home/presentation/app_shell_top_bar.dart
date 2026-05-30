import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_screen_header.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';

/// Geniş web düzeninde içerik alanının üst çubuğu.
class AppShellTopBar extends ConsumerWidget {
  const AppShellTopBar({
    super.key,
    required this.tabIndex,
    required this.user,
  });

  final int tabIndex;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = _metaFor(tabIndex, user);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppScreenHeader(
            shellLayout: true,
            hideBrandLogo: true,
            sectionLabel: meta.sectionLabel,
            title: meta.title,
            subtitle: meta.subtitle,
            user: user,
            showProfileAvatar: meta.showProfileAvatar,
            showSyncChip: meta.showSyncChip,
            showCoachButton: meta.showCoachButton,
            onCoachTap: () => CoachChatScreen.open(context, user),
            bottom: meta.showMonthSelector
                ? const HeaderMonthSelector()
                : null,
          ),
          if (meta.hint != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _ShellHintChip(label: meta.hint!),
            ),
          ],
        ],
      ),
    );
  }

  _ShellTabMeta _metaFor(int index, User user) {
    final firstName = user.displayName?.split(' ').first ?? 'Kullanıcı';

    switch (index) {
      case 1:
        return const _ShellTabMeta(
          sectionLabel: 'Analiz',
          title: 'Harcama analizi',
          subtitle:
              'Kategori dağılımı, trendler ve geçen ay karşılaştırması',
          showMonthSelector: true,
          hint: '1–3 sekme · 4 profil · N işlem · K koç',
        );
      case 2:
        return const _ShellTabMeta(
          sectionLabel: 'Takvim',
          title: 'Günlük harcama takvimi',
          subtitle: 'İşlem günlerini gör, seçili günün detayına in',
          hint: '1–3 sekme · 4 profil · N işlem',
        );
      case 3:
        return _ShellTabMeta(
          sectionLabel: 'Profil',
          title: user.displayName ?? 'Hesabım',
          subtitle: 'Ayarlar, kategoriler, senkron ve hesap yönetimi',
          showProfileAvatar: false,
          showCoachButton: true,
        );
      case 0:
      default:
        return _ShellTabMeta(
          sectionLabel: 'Özet',
          title: 'Merhaba, $firstName 👋',
          subtitle:
              'Aylık bakiyeni, harcamalarını ve AI özetini tek ekranda gör',
          showMonthSelector: true,
          showSyncChip: true,
          hint: '1–3 sekme · 4 profil · N işlem · K koç',
        );
    }
  }
}

class _ShellTabMeta {
  const _ShellTabMeta({
    required this.sectionLabel,
    required this.title,
    required this.subtitle,
    this.showMonthSelector = false,
    this.showSyncChip = false,
    this.showProfileAvatar = true,
    this.showCoachButton = true,
    this.hint,
  });

  final String sectionLabel;
  final String title;
  final String subtitle;
  final bool showMonthSelector;
  final bool showSyncChip;
  final bool showProfileAvatar;
  final bool showCoachButton;
  final String? hint;
}

class _ShellHintChip extends StatelessWidget {
  const _ShellHintChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_rounded,
            size: 14,
            color: palette.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

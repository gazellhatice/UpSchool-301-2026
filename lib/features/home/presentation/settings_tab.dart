import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/sync_status_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/categories/presentation/add_category_sheet.dart';
import 'package:kisisel_harcama_kocu_1/features/legal/privacy_policy_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  bool _syncing = false;
  String? _appVersion;
  bool? _isOnline;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final info = await PackageInfo.fromPlatform();
    final connectivity = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version} (${info.buildNumber})';
        _isOnline = !connectivity.contains(ConnectivityResult.none);
      });
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      final result =
          await ref.read(financeRepositoryProvider(widget.user.uid)).sync();
      await _loadMeta();
      if (!mounted) return;

      if (!result.wasOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İnternet bağlantısı yok — senkron atlandı'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (result.success) {
        await ref.read(lastSyncAtProvider.notifier).markSynced();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senkronizasyon tamamlandı'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Senkron hatası: ${result.error}')),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _deleteCategory(CategoryItem category) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Kategoriyi sil',
      message:
          '"${category.name}" silinsin mi? Bu kategorideki işlemler "Diğer" altına taşınır.',
    );
    if (!ok) return;

    try {
      await ref
          .read(financeRepositoryProvider(widget.user.uid))
          .deleteCategory(category.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori silindi')),
        );
      }
    } on FinanceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Çıkış yap',
      message: 'Oturumunuz kapatılacak. Yerel veriler bu cihazda kalır.',
      confirmLabel: 'Çıkış yap',
      isDestructive: false,
    );
    if (!ok) return;

    await ref.read(financeRepositoryProvider(widget.user.uid)).clearLocalUserData();
    ref.read(lastSyncAtProvider.notifier).clear();
    await widget.authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final categoriesAsync = ref.watch(categoriesProvider(widget.user.uid));
    final lastSync = ref.watch(lastSyncAtProvider);
    final themeMode = ref.watch(themeModeProvider);

    final syncSubtitle = lastSync != null
        ? 'Son: ${DateFormat('d MMM HH:mm', 'tr_TR').format(lastSync)}'
        : 'Henüz senkron yapılmadı';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text(
          'Profil & Ayarlar',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: widget.user.photoURL != null
                    ? NetworkImage(widget.user.photoURL!)
                    : null,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: widget.user.photoURL == null
                    ? Text(
                        (widget.user.displayName ?? 'K')[0].toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName ?? 'Kullanıcı',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                _isOnline == true
                    ? Icons.wifi_rounded
                    : Icons.wifi_off_rounded,
                color: _isOnline == true ? AppColors.accent : AppColors.accentWarm,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulut senkron',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      syncSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _syncing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      tooltip: 'Şimdi senkronize et',
                      icon: const Icon(Icons.sync_rounded),
                      onPressed: _sync,
                    ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.palette_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Tema',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Sistem'),
                    icon: Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Açık'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Koyu'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) {
                  ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(selection.first);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.policy_outlined, color: AppColors.primary),
            title: const Text('Gizlilik politikası'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
        ),
        if (_appVersion != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${AppConstants.appName} · v$_appVersion',
              style: theme.textTheme.labelSmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kategoriler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  AddCategorySheet.show(context, widget.user.uid),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ekle'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        categoriesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Kategoriler: $e'),
          data: (categories) {
            if (categories.isEmpty) {
              return GlassCard(
                child: Text(
                  'Henüz kategori yok.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              );
            }
            return Column(
              children: categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Icon(c.icon, color: c.color),
                      title: Text(
                        c.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        c.isIncome ? 'Gelir kategorisi' : 'Gider kategorisi',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!c.synced)
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 16,
                              color: AppColors.accentWarm,
                            ),
                          if (!c.isDefault)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => AddCategorySheet.show(
                                context,
                                widget.user.uid,
                                category: c,
                              ),
                            ),
                          if (!c.isDefault)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () => _deleteCategory(c),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _signOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Çıkış yap'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

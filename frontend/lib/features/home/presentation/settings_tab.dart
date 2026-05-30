import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/csv_export.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/transactions_csv.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/budget_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/sync_status_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_screen_header.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/sign_out_action.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/budget_edit_sheet.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/edit_profile_sheet.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/profile_avatars.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/profile_categories_section.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/profile_hero_card.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/profile_preferences_cards.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/profile_stats_row.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/settings_section.dart';
import 'package:kisisel_harcama_kocu_1/features/legal/privacy_policy_screen.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _exportCsv() async {
    final month = ref.read(selectedMonthProvider);
    final summary = await ref
        .read(financeRepositoryProvider(widget.user.uid))
        .watchMonthSummary(month)
        .first;
    final transactions = summary.transactions;
    if (transactions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu ay için dışa aktarılacak işlem yok'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final monthLabel = DateFormat('yyyy-MM').format(month);
    final filename = 'islemler-$monthLabel.csv';
    try {
      downloadCsvFile(
        filename: filename,
        content: buildTransactionsCsv(transactions),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$filename indirildi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dışa aktarma başarısız: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    await performSignOut(
      context: context,
      ref: ref,
      userId: widget.user.uid,
      authService: widget.authService,
    );
  }

  Future<void> _openSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query: 'subject=${Uri.encodeComponent('${AppConstants.appName} Destek')}',
    );
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-posta açılamadı: ${AppConstants.supportEmail}')),
      );
    }
  }

  Future<void> _openEditProfile() async {
    await EditProfileSheet.show(context, widget.user);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final month = ref.watch(selectedMonthProvider);
    final budget = ref.watch(monthlyBudgetProvider(widget.user.uid));
    final lastSync = ref.watch(lastSyncAtProvider);
    final themeMode = ref.watch(themeModeProvider);
    final categories = ref.watch(categoriesProvider(widget.user.uid)).valueOrNull ?? const [];
    final summary = ref
        .watch(monthSummaryProvider((userId: widget.user.uid, month: month)))
        .valueOrNull;

    final budgetLabel = budget != null && budget > 0
        ? 'Aylık bütçe: ${formatCurrency(budget)}'
        : 'Aylık bütçe hedefi henüz ayarlanmadı';

    final wide = ResponsiveBreakpoints.isWideLayout(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        if (!wide) ...[
          AppScreenHeader(
            sectionLabel: 'Profil',
            title: widget.user.displayName ?? 'Hesabım',
            subtitle: 'Ayarlar, kategoriler, senkron ve hesap yönetimi',
            user: widget.user,
            showProfileAvatar: false,
            onCoachTap: () => CoachChatScreen.open(context, widget.user),
          ),
          const SizedBox(height: 20),
        ],
        ProfileHeroCard(
          user: widget.user,
          onEditTap: _openEditProfile,
        ),
        const SizedBox(height: 16),
        ProfileStatsRow(
          transactionCount: summary?.transactions.length ?? 0,
          categoryCount: categories.length,
        ),
        const SizedBox(height: 12),
        ProfileFinanceSnapshot(
          monthIncome: summary?.income ?? 0,
          monthExpense: summary?.expense ?? 0,
          budgetLabel: budgetLabel,
        ),
        const SizedBox(height: 24),
        SettingsSection(
          title: 'Hesap',
          children: [
            SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Profili düzenle',
              subtitle: 'Ad, avatar ve şifre',
              onTap: _openEditProfile,
            ),
            SettingsTile(
              icon: authProviderIcon(widget.user),
              title: authProviderLabel(widget.user),
              subtitle: widget.user.email ?? 'E-posta bilgisi yok',
              trailing: const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: 'Uygulama',
          subtitle: 'Senkron, tema ve bütçe ayarları',
          children: [
            ProfileSyncCard(
              isOnline: _isOnline,
              syncing: _syncing,
              lastSync: lastSync,
              onSyncTap: _syncing ? () {} : _sync,
            ),
            ProfileThemeSelector(
              themeMode: themeMode,
              onChanged: (mode) =>
                  ref.read(themeModeProvider.notifier).setThemeMode(mode),
            ),
            SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.accentWarm,
              title: 'Aylık bütçe hedefi',
              subtitle: budgetLabel,
              onTap: () => BudgetEditSheet.show(
                context,
                userId: widget.user.uid,
                currentBudget: budget,
                monthExpense: summary?.expense ?? 0,
              ),
            ),
            if (csvExportSupported)
              SettingsTile(
                icon: Icons.download_rounded,
                iconColor: AppColors.accent,
                title: 'İşlemleri CSV indir',
                subtitle: 'Seçili ay: ${DateFormat('yyyy-MM').format(month)}',
                onTap: _exportCsv,
              ),
            if (kIsWeb)
              SettingsTile(
                icon: Icons.install_mobile_rounded,
                title: 'Ana ekrana ekle',
                subtitle: 'Tarayıcı menüsünden "Uygulamayı yükle" veya "Ana ekrana ekle"',
                trailing: const SizedBox.shrink(),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: 'Kategoriler',
          subtitle: 'Gelir ve gider kategorilerini yönet',
          children: [
            ProfileCategoriesSection(
              userId: widget.user.uid,
              onDeleteCategory: _deleteCategory,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: 'Destek & yasal',
          children: [
            SettingsTile(
              icon: Icons.policy_outlined,
              title: 'Gizlilik politikası',
              subtitle: 'Veri kullanımı ve hakların',
              onTap: () {
                if (kIsWeb) {
                  context.go(AppRoutes.privacy);
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            SettingsTile(
              icon: Icons.support_agent_rounded,
              iconColor: AppColors.accent,
              title: 'Destek',
              subtitle: AppConstants.supportEmail,
              onTap: _openSupportEmail,
            ),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              title: AppConstants.appName,
              subtitle: _appVersion == null ? 'Sürüm yükleniyor...' : 'v$_appVersion',
              trailing: const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oturumu kapat',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Çıkış yaptığında yerel veriler cihazında kalır. Tekrar giriş yaparak devam edebilirsin.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Çıkış yap'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.45)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

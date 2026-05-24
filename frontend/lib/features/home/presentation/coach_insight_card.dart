import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/services/coach_api_service.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/financial_context_builder.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class CoachInsightCard extends ConsumerStatefulWidget {
  const CoachInsightCard({super.key, required this.user});

  final User user;

  @override
  ConsumerState<CoachInsightCard> createState() => _CoachInsightCardState();
}

class _CoachInsightCardState extends ConsumerState<CoachInsightCard> {
  String? _analysis;
  List<String> _bullets = const [];
  bool _loading = false;
  String? _error;
  DateTime? _cachedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCachedAnalysis());
  }

  Future<void> _loadCachedAnalysis() async {
    final month = ref.read(selectedMonthProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final text = prefs.getString(coachAnalysisCacheKey(widget.user.uid, month));
    if (text == null || text.isEmpty || !mounted) return;

    final cachedMs = prefs.getInt(
      coachAnalysisCacheTimeKey(widget.user.uid, month),
    );

    setState(() {
      _analysis = text;
      _bullets = extractInsightBullets(text);
      _cachedAt = cachedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(cachedMs);
    });
  }

  Future<void> _saveCachedAnalysis(String text) async {
    final month = ref.read(selectedMonthProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    await prefs.setString(coachAnalysisCacheKey(widget.user.uid, month), text);
    await prefs.setInt(
      coachAnalysisCacheTimeKey(widget.user.uid, month),
      now.millisecondsSinceEpoch,
    );
    _cachedAt = now;
  }

  Future<void> _loadAnalysis({bool force = false}) async {
    final month = ref.read(selectedMonthProvider);
    final summary = ref
        .read(monthSummaryProvider((userId: widget.user.uid, month: month)))
        .valueOrNull;
    final stats = ref
        .read(expenseStatsProvider((userId: widget.user.uid, month: month)))
        .valueOrNull;

    if (summary == null || summary.transactions.isEmpty) {
      setState(() {
        _error = null;
        _analysis = null;
        _bullets = const [];
      });
      return;
    }

    if (!force && _analysis != null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final context = buildFinancialContext(
        month: month,
        summary: summary,
        stats: stats ?? [],
      );
      final api = ref.read(coachApiServiceProvider);
      final text = await api.requestAnalysis(
        user: widget.user,
        financialContext: context,
      );
      final bullets = extractInsightBullets(text);
      await _saveCachedAnalysis(text);
      if (mounted) {
        setState(() {
          _analysis = text;
          _bullets = bullets;
          _loading = false;
        });
      }
    } on CoachApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Analiz alınamadı';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = ref.watch(selectedMonthProvider);
    final summary = ref
        .watch(monthSummaryProvider((userId: widget.user.uid, month: month)))
        .valueOrNull;

    ref.listen(selectedMonthProvider, (_, __) {
      setState(() {
        _analysis = null;
        _bullets = const [];
        _error = null;
        _cachedAt = null;
      });
      _loadCachedAnalysis();
    });

    final hasTransactions = summary != null && summary.transactions.isNotEmpty;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Finans Özeti',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_cachedAt != null)
                      Text(
                        'Kayıtlı özet',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                  ],
                ),
              ),
              if (_analysis != null)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: 'Yenile',
                  onPressed: _loading ? null : () => _loadAnalysis(force: true),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_bullets.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final bullet in _bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 7, right: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            bullet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          else if (_error != null)
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          else if (!hasTransactions)
            _OnboardingChecklist(
              onAddTransaction: () =>
                  TransactionFormSheet.show(context, widget.user.uid),
            )
          else
            Text(
              'Bu ayki harcamalarına göre yapay zeka destekli kişisel finans özeti al.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_analysis == null && !_loading && hasTransactions)
                FilledButton.icon(
                  onPressed: _loadAnalysis,
                  icon: const Icon(Icons.insights_rounded, size: 18),
                  label: const Text('Analiz Et'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                ),
              if (_analysis != null) ...[
                TextButton.icon(
                  onPressed: () => CoachChatScreen.show(context, widget.user),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('Koça Sor'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingChecklist extends StatelessWidget {
  const _OnboardingChecklist({required this.onAddTransaction});

  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3 adımda başla',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _ChecklistRow(text: 'İlk gelir veya giderini ekle'),
        _ChecklistRow(text: 'Kategorilerini düzenle'),
        _ChecklistRow(text: 'AI koçundan aylık özet al'),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onAddTransaction,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('İlk işlemi ekle'),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/services/coach_api_service.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/financial_context_builder.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';

class CoachInsightCard extends ConsumerStatefulWidget {
  const CoachInsightCard({super.key, required this.user});

  final User user;

  @override
  ConsumerState<CoachInsightCard> createState() => _CoachInsightCardState();
}

class _CoachInsightCardState extends ConsumerState<CoachInsightCard> {
  String? _analysis;
  bool _loading = false;
  String? _error;

  Future<void> _loadAnalysis() async {
    final month = ref.read(selectedMonthProvider);
    final summary = ref
        .read(monthSummaryProvider((userId: widget.user.uid, month: month)))
        .valueOrNull;
    final stats = ref
        .read(expenseStatsProvider((userId: widget.user.uid, month: month)))
        .valueOrNull;

    if (summary == null || summary.transactions.isEmpty) {
      setState(() {
        _error = 'Analiz için en az bir işlem ekle';
        _analysis = null;
      });
      return;
    }

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
      if (mounted) {
        setState(() {
          _analysis = text;
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
                child: Text(
                  'AI Finans Özeti',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_analysis != null)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: 'Yenile',
                  onPressed: _loading ? null : _loadAnalysis,
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
          else if (_analysis != null)
            Text(
              _analysis!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            )
          else if (_error != null)
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
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
              if (_analysis == null && !_loading)
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

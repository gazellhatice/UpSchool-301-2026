import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../auth/auth_provider.dart';
import '../database/app_database.dart';
import '../database/db_provider.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            _BalanceCard(),
            _MonthSelector(),
            const Expanded(child: _TransactionList()),
          ],
        ),
      ),
      floatingActionButton: _AddFab(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final firstName = (user?.displayName ?? 'Kullanıcı').split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba, $firstName 👋',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF888888))),
              const SizedBox(height: 2),
              Text('Finansal Özet',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSignOutDialog(context, ref),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF1DB954).withOpacity(0.2),
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(firstName[0].toUpperCase(),
                      style: GoogleFonts.inter(
                          color: const Color(0xFF1DB954),
                          fontWeight: FontWeight.bold))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Çıkış yap',
            style: GoogleFonts.inter(color: Colors.white)),
        content: Text('Hesabından çıkmak istiyor musun?',
            style: GoogleFonts.inter(color: const Color(0xFF888888))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal',
                  style: TextStyle(color: Color(0xFF888888)))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authNotifierProvider.notifier).signOut();
              },
              child: const Text('Çıkış yap',
                  style: TextStyle(color: Color(0xFFFF6B6B)))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BALANCE CARD
// ─────────────────────────────────────────────────────────────────
class _BalanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthlySummaryProvider);
    final fmt = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A1A), Color(0xFF0F1A0F)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: const Color(0xFF1DB954).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text('Net Bakiye',
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF888888))),
          const SizedBox(height: 8),
          Text(
            '₺ ${fmt.format(summary.balance)}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: summary.balance >= 0
                  ? const Color(0xFF1DB954)
                  : const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  label: 'Gelir',
                  amount: '₺ ${fmt.format(summary.totalIncome)}',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFF1DB954),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  label: 'Gider',
                  amount: '₺ ${fmt.format(summary.totalExpense)}',
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF888888))),
                const SizedBox(height: 2),
                Text(amount,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MONTH SELECTOR
// ─────────────────────────────────────────────────────────────────
class _MonthSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMonthProvider);
    final label = DateFormat('MMMM yyyy', 'tr_TR').format(selected);
    final now = DateTime.now();
    final canGoNext = selected.year < now.year ||
        (selected.year == now.year && selected.month < now.month);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('İşlemler',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Row(
            children: [
              _MonthArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () =>
                    ref.read(selectedMonthProvider.notifier).state =
                        DateTime(selected.year, selected.month - 1),
              ),
              const SizedBox(width: 4),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF1DB954),
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              _MonthArrow(
                icon: Icons.chevron_right_rounded,
                onTap: canGoNext
                    ? () =>
                        ref.read(selectedMonthProvider.notifier).state =
                            DateTime(selected.year, selected.month + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon,
          color: onTap != null
              ? const Color(0xFF888888)
              : const Color(0xFF333333),
          size: 22),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TRANSACTION LIST
// ─────────────────────────────────────────────────────────────────
class _TransactionList extends ConsumerWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);

    return txAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1DB954))),
      error: (e, _) => Center(
          child: Text('Hata: $e',
              style: const TextStyle(color: Color(0xFFFF6B6B)))),
      data: (list) {
        if (list.isEmpty) return const _EmptyState();

        final grouped = <String, List<Transaction>>{};
        for (final tx in list) {
          final key = DateFormat('d MMMM yyyy', 'tr_TR').format(tx.date);
          grouped.putIfAbsent(key, () => []).add(tx);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final date = grouped.keys.elementAt(index);
            final txList = grouped[date]!;
            return _DayGroup(date: date, transactions: txList);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DAY GROUP
// ─────────────────────────────────────────────────────────────────
class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.date, required this.transactions});
  final String date;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(date,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF555555),
                  fontWeight: FontWeight.w500)),
        ),
        ...transactions.map((tx) => _TransactionTile(tx: tx)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TRANSACTION TILE
// ─────────────────────────────────────────────────────────────────
class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.tx});
  final Transaction tx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = tx.type == 'income';
    final color = Color(tx.categoryColor);
    final fmt = NumberFormat('#,##0.00', 'tr_TR');

    return Dismissible(
      key: Key(tx.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) async {
        await ref.read(dbProvider).deleteTransaction(tx.id);
        ref.invalidate(transactionsProvider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF222222)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(tx.categoryIcon, fontFamily: 'MaterialIcons'),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.categoryName,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  if (tx.note.isNotEmpty)
                    Text(tx.note,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF555555)),
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}₺${fmt.format(tx.amount)}',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isIncome
                    ? const Color(0xFF1DB954)
                    : const Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('İşlemi sil',
            style: GoogleFonts.inter(color: Colors.white)),
        content: Text('Bu işlem kalıcı olarak silinecek.',
            style: GoogleFonts.inter(color: const Color(0xFF888888))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal',
                  style: TextStyle(color: Color(0xFF888888)))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil',
                  style: TextStyle(color: Color(0xFFFF6B6B)))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 64, color: Color(0xFF333333)),
          const SizedBox(height: 16),
          Text('Bu ay için işlem yok',
              style: GoogleFonts.inter(
                  fontSize: 16, color: const Color(0xFF555555))),
          const SizedBox(height: 8),
          Text('Yeni işlem eklemek için + butonuna bas',
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF333333))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FAB
// ─────────────────────────────────────────────────────────────────
class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // context.push('/add-transaction')  — AddTransaction ekranı gelince açılacak
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A2A1A),
            content: Text('AddTransaction ekranı yakında!',
                style: GoogleFonts.inter(color: const Color(0xFF1DB954))),
          ),
        );
      },
      backgroundColor: const Color(0xFF1DB954),
      foregroundColor: Colors.black,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: Text('Yeni İşlem',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
    );
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/config/app_config.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/coach_panel_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/services/backend_url_resolver.dart';
import 'package:kisisel_harcama_kocu_1/core/services/coach_api_service.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/financial_context_builder.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';

class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({
    super.key,
    required this.user,
    this.embedded = false,
    this.onClose,
  });

  final User user;
  final bool embedded;
  final VoidCallback? onClose;

  /// Geniş web: yan panel; dar / mobil: tam ekran.
  static void open(BuildContext context, User user) {
    if (ResponsiveBreakpoints.isWideLayout(context)) {
      try {
        ProviderScope.containerOf(context, listen: false)
            .read(coachPanelOpenProvider.notifier)
            .state = true;
        return;
      } catch (_) {
        // Provider yoksa tam ekrana düş.
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CoachChatScreen(user: user),
      ),
    );
  }

  @Deprecated('Use CoachChatScreen.open')
  static void show(BuildContext context, User user) => open(context, user);

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _loading = false;
  bool _historyLoaded = false;
  String? _connectionStatus;

  CollectionReference<Map<String, dynamic>> get _chatRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.user.uid)
      .collection('coach_chat');

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnection());
  }

  Future<void> _checkConnection() async {
    final api = ref.read(coachApiServiceProvider);
    final ok = await api.checkHealth();
    if (mounted) {
      setState(() {
        _connectionStatus = ok
            ? null
            : kIsWeb
                ? 'Backend\'e ulaşılamıyor. Terminalde: cd backend → npm run dev\n'
                    'Tarayıcıda test: http://127.0.0.1:3001/health\n'
                    'Sonra uygulamayı kapatıp .\\run_chrome.ps1 ile aç.'
                : 'Backend\'e ulaşılamıyor. PowerShell\'de:\n'
                    'adb reverse tcp:3001 tcp:3001\n'
                    'Sonra uygulamayı yeniden aç.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final snap = await _chatRef
        .orderBy('createdAt', descending: false)
        .limitToLast(50)
        .get();

    final loaded = snap.docs.map((doc) {
      final data = doc.data();
      return _Message(
        role: data['role'] as String,
        text: data['text'] as String,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _messages.addAll(loaded);
        _historyLoaded = true;
      });
      _scrollToBottom();
    }
  }

  Future<void> _saveMessage(_Message msg) async {
    await _chatRef.add({
      'role': msg.role,
      'text': msg.text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  FinancialContext? _buildContext() {
    final month = ref.read(selectedMonthProvider);
    final summary = ref
        .read(
          monthSummaryProvider(
            (userId: widget.user.uid, month: month),
          ),
        )
        .valueOrNull;
    final stats = ref
        .read(
          expenseStatsProvider(
            (userId: widget.user.uid, month: month),
          ),
        )
        .valueOrNull;

    if (summary == null) return null;
    return buildFinancialContext(
      month: month,
      summary: summary,
      stats: stats ?? [],
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    final userMsg = _Message(role: 'user', text: text);
    setState(() {
      _messages.add(userMsg);
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();
    // Firestore kaydı API'yi bekletmesin
    unawaited(_saveMessage(userMsg));

    try {
      if (kDebugMode) {
        final base = BackendUrlResolver.cached ?? AppConfig.backendBaseUrl;
        debugPrint('Coach API → $base/api/v1/coach/chat');
      }
      final api = ref.read(coachApiServiceProvider);
      final history = _messages.where((m) => m.role != 'typing').toList();
      final coachMessages = history
          .map((m) => CoachMessage(role: m.role, text: m.text))
          .toList();

      final replyText = await api.sendChat(
        user: widget.user,
        messages: coachMessages,
        financialContext: _buildContext(),
      );

      if (replyText.isEmpty) {
        _showError('Boş yanıt alındı');
        return;
      }

      final assistantMsg = _Message(role: 'assistant', text: replyText);
      setState(() {
        _messages.add(assistantMsg);
        _loading = false;
      });
      await _saveMessage(assistantMsg);
      _scrollToBottom();
    } on CoachApiException catch (e) {
      _showErrorInChat(e.message);
    } catch (e) {
      _showErrorInChat('Bağlantı hatası: $e');
    }
  }

  void _showErrorInChat(String msg) {
    setState(() {
      _loading = false;
      _messages.add(_Message(role: 'assistant', text: '⚠️ $msg'));
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showError(String msg) {
    _showErrorInChat(msg);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearHistory() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Sohbeti temizle',
      message: 'Tüm sohbet geçmişi silinecek. Emin misin?',
      confirmLabel: 'Sil',
      isDestructive: true,
    );
    if (ok != true) return;

    final snap = await _chatRef.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    setState(() => _messages.clear());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasContext = _buildContext() != null;

    final header = _CoachHeader(
      theme: theme,
      hasContext: hasContext,
      embedded: widget.embedded,
      onBack: widget.embedded
          ? widget.onClose
          : () => Navigator.of(context).pop(),
      onClear: _clearHistory,
    );

    final body = Column(
        children: [
          if (_connectionStatus != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Text(
                _connectionStatus!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (hasContext)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded,
                      size: 16, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu ayki harcama verilerin koça aktarılıyor',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: !_historyLoaded
                ? const _ChatLoadingSkeleton()
                : _messages.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        itemCount: _messages.length + (_loading ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (_loading && i == _messages.length) {
                            return _TypingIndicator();
                          }
                          return _MessageBubble(
                            message: _messages[i],
                            theme: theme,
                          );
                        },
                      ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Finans koçuna sor...',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A3E)
                          : const Color(0xFFF0F0FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'send_fab',
                  onPressed: _loading ? null : _send,
                  backgroundColor: const Color(0xFF6C63FF),
                  elevation: 0,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
    );

    if (widget.embedded) {
      return ColoredBox(
        color: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F5FF),
        child: Column(
          children: [
            header,
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F5FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: header,
      ),
      body: body,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Finans Koçun Burada!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Harcamalarını analiz et, bütçe planla,\nfinans hedeflerine ulaş.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: '💰 Bütçe nasıl yapılır?',
                  onTap: () {
                    _controller.text = 'Bütçe nasıl yapılır?';
                    _send();
                  },
                ),
                _SuggestionChip(
                  label: '📊 Tasarruf ipuçları',
                  onTap: () {
                    _controller.text = 'Tasarruf için ipuçları ver';
                    _send();
                  },
                ),
                _SuggestionChip(
                  label: '🎯 Finansal hedef',
                  onTap: () {
                    _controller.text = 'Finansal hedef nasıl belirlenir?';
                    _send();
                  },
                ),
                _SuggestionChip(
                  label: '📉 Harcamaları azalt',
                  onTap: () {
                    _controller.text =
                        'Gereksiz harcamalarımı nasıl azaltabilirim?';
                    _send();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachHeader extends StatelessWidget implements PreferredSizeWidget {
  const _CoachHeader({
    required this.theme,
    required this.hasContext,
    required this.embedded,
    required this.onBack,
    required this.onClear,
  });

  final ThemeData theme;
  final bool hasContext;
  final bool embedded;
  final VoidCallback? onBack;
  final Future<void> Function() onClear;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  embedded ? Icons.close_rounded : Icons.arrow_back_rounded,
                ),
                onPressed: onBack,
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Finans Koçu',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      hasContext
                          ? 'Verilerinle kişiselleştirilmiş'
                          : 'AI destekli asistan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Sohbeti temizle',
                onPressed: () => onClear(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatLoadingSkeleton extends StatelessWidget {
  const _ChatLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor =
        isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE8E8F5);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(4, (i) {
        final alignRight = i.isOdd;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Align(
            alignment:
                alignRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 140 + (i * 24).toDouble(),
              height: 48,
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Message {
  const _Message({required this.role, required this.text});
  final String role;
  final String text;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.theme});
  final _Message message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF6C63FF)
                    : theme.brightness == Brightness.dark
                        ? const Color(0xFF2A2A3E)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser ? Colors.white : null,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(
          reverse: true,
          period: Duration(milliseconds: 600 + i * 150),
        ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A3E)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _controllers[i],
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7 + _controllers[i].value * 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(
                          alpha: 0.4 + _controllers[i].value * 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
      side: BorderSide(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF6C63FF),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key, required this.user});

  final User user;

  static Future<void> show(BuildContext context, User user) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CoachChatScreen(user: user),
      ),
    );
  }

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _loading = false;
  bool _historyLoaded = false;

  // ⚠️ Buraya Gemini API anahtarı
  static const _apiKey = 'YOUR_GEMINI_API_KEY';
  static const _model = 'gemini-1.5-pro'; // veya gemini-1.5-flash

  static const _systemPrompt = '''
Sen "Finans Koçu" adlı kişisel bir finans asistanısın. 
Kullanıcıların kişisel harcamalarını yönetmelerine, bütçe planlamalarına ve finansal hedeflerine ulaşmalarına yardımcı olursun.
Yanıtların kısa, net ve pratik olsun. Türkçe konuş.
Kullanıcıya dostça ve motive edici bir ton kullan.
Gerektiğinde somut öneriler ve adımlar ver.
''';

  CollectionReference<Map<String, dynamic>> get _chatRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.user.uid)
      .collection('coach_chat');

  @override
  void initState() {
    super.initState();
    _loadHistory();
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
    await _saveMessage(userMsg);

    try {
      final history = _messages
          .where((m) => m.role != 'typing')
          .toList()
          .reversed
          .take(20)
          .toList()
          .reversed
          .toList();

      // Gemini formatına çevir
      final contents = history.map((m) {
        return {
          "role": m.role == "user" ? "user" : "model",
          "parts": [
            {"text": m.text}
          ]
        };
      }).toList();

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": contents,
          "systemInstruction": {
            "parts": [
              {"text": _systemPrompt}
            ]
          },
          "generationConfig": {
            "maxOutputTokens": 1024,
            "temperature": 0.7
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final replyText = data["candidates"][0]["content"]["parts"][0]["text"];

        final assistantMsg = _Message(role: 'assistant', text: replyText);

        setState(() {
          _messages.add(assistantMsg);
          _loading = false;
        });

        await _saveMessage(assistantMsg);
        _scrollToBottom();
      } else {
        _showError('Gemini API hatası: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Bağlantı hatası: $e');
    }
  }

  void _showError(String msg) {
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sohbeti temizle'),
        content: const Text('Tüm sohbet geçmişi silinecek. Emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finans Koçu',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'AI destekli asistan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Sohbeti temizle',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mesaj listesi
          Expanded(
            child: !_historyLoaded
                ? const Center(child: CircularProgressIndicator())
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

          // Input alanı
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton.small(
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
                ),
              ],
            ),
          ),
        ],
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      )..repeat(reverse: true, period: Duration(milliseconds: 600 + i * 150)),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      color: const Color(0xFF6C63FF)
                          .withValues(alpha: 0.4 + _controllers[i].value * 0.6),
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
      backgroundColor:
      const Color(0xFF6C63FF).withValues(alpha: 0.1),
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
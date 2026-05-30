import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/router/app_routes.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_section_header.dart';
import 'package:kisisel_harcama_kocu_1/features/marketing/widgets/marketing_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  static const _topics = [
    'Geri bildirim',
    'Teknik destek',
    'İş birliği',
    'Genel soru',
  ];

  String _topic = _topics.first;
  bool _sending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _copyEmail() async {
    await Clipboard.setData(ClipboardData(text: AppConstants.supportEmail));
    if (!mounted) return;
    _showSnack('E-posta adresi kopyalandı', success: true);
  }

  Future<void> _sendEmail() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showSnack('Lütfen mesajını yaz.');
      return;
    }
    if (message.length < 10) {
      _showSnack('Mesaj en az 10 karakter olmalı.');
      return;
    }

    setState(() => _sending = true);

    final name = _nameController.text.trim();
    final replyEmail = _emailController.text.trim();
    final subject = Uri.encodeComponent(
      '${AppConstants.appName} — $_topic',
    );
    final body = Uri.encodeComponent(
      'Konu: $_topic\n'
      'Ad: ${name.isEmpty ? '(belirtilmedi)' : name}\n'
      'Yanıt e-postası: ${replyEmail.isEmpty ? '(belirtilmedi)' : replyEmail}\n\n'
      '$message',
    );
    final uri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=$subject&body=$body',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (mounted) {
          _showSnack('E-posta uygulaman açıldı — göndermeyi tamamla.', success: true);
        }
      } else if (mounted) {
        await _copyEmail();
        _showSnack('E-posta uygulaması bulunamadı — adres panoya kopyalandı.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MarketingPageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MarketingSectionHeader(
            title: 'İletişim',
            subtitle:
                'Geri bildirim, demo talebi veya proje hakkında soruların için yaz — en geç 2 iş günü içinde dönüş hedeflenir.',
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final form = _ContactForm(
                palette: palette,
                nameController: _nameController,
                emailController: _emailController,
                messageController: _messageController,
                topics: _topics,
                selectedTopic: _topic,
                sending: _sending,
                onTopicChanged: (t) => setState(() => _topic = t),
                onSend: _sendEmail,
              );
              final sidebar = _ContactSidebar(
                palette: palette,
                onCopyEmail: _copyEmail,
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: form),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: sidebar),
                  ],
                );
              }
              return Column(
                children: [
                  form,
                  const SizedBox(height: 24),
                  sidebar,
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          _QuickHelpRow(palette: palette),
        ],
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  const _ContactForm({
    required this.palette,
    required this.nameController,
    required this.emailController,
    required this.messageController,
    required this.topics,
    required this.selectedTopic,
    required this.sending,
    required this.onTopicChanged,
    required this.onSend,
  });

  final AppPalette palette;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final List<String> topics;
  final String selectedTopic;
  final bool sending;
  final ValueChanged<String> onTopicChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bize yaz',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Form e-posta uygulamanı açar; mesajı oradan gönderirsin.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Konu',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((topic) {
              final selected = topic == selectedTopic;
              return FilterChip(
                label: Text(topic),
                selected: selected,
                onSelected: (_) => onTopicChanged(topic),
                showCheckmark: true,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : palette.textSecondary,
                ),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : palette.glassBorder,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Adın',
              hintText: 'Hatice',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Yanıt için e-postan (isteğe bağlı)',
              hintText: 'ornek@mail.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: messageController,
            maxLines: 6,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Mesajın',
              hintText: 'Merhaba, uygulama hakkında...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 72),
                child: Icon(Icons.edit_note_rounded),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'En az 10 karakter · Kişisel finans verisi paylaşma',
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: sending ? null : onSend,
            icon: sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(sending ? 'Açılıyor…' : 'E-posta ile gönder'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSidebar extends StatelessWidget {
  const _ContactSidebar({
    required this.palette,
    required this.onCopyEmail,
  });

  final AppPalette palette;
  final VoidCallback onCopyEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.18),
                palette.surface.withValues(alpha: 0.9),
              ],
            ),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 32),
              const SizedBox(height: 14),
              Text(
                'Doğrudan e-posta',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                AppConstants.supportEmail,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onCopyEmail,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Adresi kopyala'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.schedule_rounded,
                title: 'Yanıt süresi',
                subtitle: 'Bitirme projesi kapsamında en geç 2 iş günü',
                color: AppColors.accent,
              ),
              const SizedBox(height: 14),
              _InfoTile(
                icon: Icons.school_rounded,
                title: 'Proje',
                subtitle: 'Future Talent 2026 · Hatice Gazell',
                color: AppColors.accentWarm,
              ),
              const SizedBox(height: 14),
              _InfoTile(
                icon: Icons.lock_outline_rounded,
                title: 'Gizlilik',
                subtitle: 'Hesap şifresi veya finans verisi e-postayla gönderme',
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sık sorulan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _FaqLine(
                question: 'Demo nasıl denerim?',
                answer: 'Kayıt ol veya giriş yap — web ve mobil aynı hesap.',
              ),
              const SizedBox(height: 10),
              _FaqLine(
                question: 'Verilerim nerede?',
                answer: 'Cihazında + isteğe bağlı Firebase senkronu.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.palette.textSecondary,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqLine extends StatelessWidget {
  const _FaqLine({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.textSecondary,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}

class _QuickHelpRow extends StatelessWidget {
  const _QuickHelpRow({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.glassBorder),
        color: palette.glassSurface,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uygulamayı henüz denemedin mi?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                'Canlı demoya geç veya projeyi incele.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.about),
                child: const Text('Hakkında'),
              ),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.auth),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Canlı demo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

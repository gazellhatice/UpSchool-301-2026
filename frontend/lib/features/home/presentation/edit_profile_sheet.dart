import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.user});

  final User user;

  static Future<void> show(BuildContext context, User user) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(user: user),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _passwordConfirmCtrl;

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _showPassword = false;
  bool _showPasswordConfirm = false;
  int? _selectedAvatarIndex;

  // Renk + emoji avatar seçenekleri
  static const _avatars = [
    (emoji: '😊', color: Color(0xFF6C63FF)),
    (emoji: '🦊', color: Color(0xFFFF6B6B)),
    (emoji: '🐬', color: Color(0xFF48CAE4)),
    (emoji: '🌿', color: Color(0xFF52B788)),
    (emoji: '🔥', color: Color(0xFFFF9F1C)),
    (emoji: '⚡', color: Color(0xFFFFD60A)),
    (emoji: '🎯', color: Color(0xFFE63946)),
    (emoji: '🦋', color: Color(0xFFB5179E)),
    (emoji: '🐉', color: Color(0xFF2D6A4F)),
    (emoji: '🚀', color: Color(0xFF023E8A)),
    (emoji: '🌙', color: Color(0xFF7B2D8B)),
    (emoji: '💎', color: Color(0xFF0096C7)),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.user.displayName ?? '',
    );
    _passwordCtrl = TextEditingController();
    _passwordConfirmCtrl = TextEditingController();

    // Eğer photoURL avatar index içeriyorsa parse et
    final url = widget.user.photoURL ?? '';
    if (url.startsWith('avatar:')) {
      final idx = int.tryParse(url.replaceFirst('avatar:', ''));
      if (idx != null && idx < _avatars.length) {
        _selectedAvatarIndex = idx;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  String _getInitial() {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    return (widget.user.email ?? 'K')[0].toUpperCase();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final newName = _nameCtrl.text.trim();
      final newPassword = _passwordCtrl.text.trim();

      // İsim güncelle
      if (newName != (widget.user.displayName ?? '')) {
        await widget.user.updateDisplayName(newName);
      }

      // Avatar güncelle
      if (_selectedAvatarIndex != null) {
        final avatarUrl = 'avatar:$_selectedAvatarIndex';
        if (widget.user.photoURL != avatarUrl) {
          await widget.user.updatePhotoURL(avatarUrl);
        }
      }

      // Şifre güncelle
      if (newPassword.isNotEmpty) {
        await widget.user.updatePassword(newPassword);
      }

      await widget.user.reload();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil güncellendi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = 'Bir hata oluştu.';
        if (e.code == 'requires-recent-login') {
          msg = 'Şifre değiştirmek için tekrar giriş yapmanız gerekiyor.';
        } else if (e.code == 'weak-password') {
          msg = 'Şifre en az 6 karakter olmalı.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Profili Düzenle',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mevcut avatar önizleme
                      Center(
                        child: Stack(
                          children: [
                            _buildCurrentAvatar(theme),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: bg,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Avatar seçici
                      Text(
                        'Avatar seç',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: _avatars.length,
                        itemBuilder: (context, i) {
                          final av = _avatars[i];
                          final selected = _selectedAvatarIndex == i;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedAvatarIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: av.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? av.color
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: selected
                                    ? [
                                  BoxShadow(
                                    color:
                                    av.color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  av.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // İsim
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Ad Soyad',
                          prefixIcon:
                          const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ad boş bırakılamaz';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Yeni şifre
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Yeni şifre (isteğe bağlı)',
                          prefixIcon:
                          const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              v.length < 6) {
                            return 'Şifre en az 6 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Şifre tekrar
                      TextFormField(
                        controller: _passwordConfirmCtrl,
                        obscureText: !_showPasswordConfirm,
                        decoration: InputDecoration(
                          labelText: 'Yeni şifre tekrar',
                          prefixIcon:
                          const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPasswordConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(() =>
                            _showPasswordConfirm =
                            !_showPasswordConfirm),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (v) {
                          if (_passwordCtrl.text.isNotEmpty &&
                              v != _passwordCtrl.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Kaydet butonu
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _save,
                          style: FilledButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAvatar(ThemeData theme) {
    if (_selectedAvatarIndex != null) {
      final av = _avatars[_selectedAvatarIndex!];
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: av.color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: av.color, width: 2.5),
        ),
        child: Center(
          child: Text(av.emoji, style: const TextStyle(fontSize: 38)),
        ),
      );
    }

    // Fotoğraf varsa göster
    final photoUrl = widget.user.photoURL;
    if (photoUrl != null && !photoUrl.startsWith('avatar:')) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    // Varsayılan harf avatar
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        _getInitial(),
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
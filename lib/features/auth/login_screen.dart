import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    // Hata varsa SnackBar göster
    ref.listen(authNotifierProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2A0A0A),
            content: Text(
              _friendlyError(next.error),
              style: const TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // ── Arka plan dekoratif daireler ──────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _GlowCircle(
              size: 280,
              color: const Color(0xFF1DB954).withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -80,
            child: _GlowCircle(
              size: 220,
              color: const Color(0xFF1DB954).withOpacity(0.07),
            ),
          ),

          // ── Ana içerik ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 72),

                  // Logo / ikon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF1DB954).withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF1DB954),
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Başlık
                  Text(
                    'Harcamalarını\nkontrol et.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 40,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Alt başlık
                  Text(
                    'Gelir ve giderlerini takip et,\nhiçbir şeyi kaçırma.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.6,
                      color: const Color(0xFF888888),
                    ),
                  ),

                  const Spacer(),

                  // ── Özellik satırları ────────────────────────
                  _FeatureRow(
                    icon: Icons.pie_chart_rounded,
                    text: 'Anlık harcama grafikleri',
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.calendar_today_rounded,
                    text: 'Takvim görünümü',
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.cloud_sync_rounded,
                    text: 'Tüm cihazlarda senkronize',
                  ),

                  const Spacer(),

                  // ── Google Sign-In butonu ─────────────────────
                  _GoogleSignInButton(
                    isLoading: authAsync.isLoading,
                    onPressed: authAsync.isLoading
                        ? null
                        : () => ref
                            .read(authNotifierProvider.notifier)
                            .signInWithGoogle(),
                  ),

                  const SizedBox(height: 16),

                  // Alt not
                  Center(
                    child: Text(
                      'Giriş yaparak gizlilik politikamızı kabul etmiş olursunuz.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF444444),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyError(Object? error) {
    if (error == null) return 'Bilinmeyen hata.';
    final msg = error.toString();
    if (msg.contains('network')) return 'İnternet bağlantısı yok.';
    if (msg.contains('cancelled')) return 'Giriş iptal edildi.';
    if (msg.contains('sign_in_failed')) return 'Giriş başarısız. SHA-1 eklenmiş mi?';
    return 'Hata: $msg';
  }
}

// ── Google Sign-In butonu ─────────────────────────────────────────
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF1A1A1A),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google "G" logosu (SVG yerine Unicode trick)
                  _GoogleLogo(),
                  const SizedBox(width: 12),
                  Text(
                    'Google ile devam et',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Basit Google "G" logosu ───────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Kırmızı (sağ üst)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5, 1.6, false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke,
    );
    // Yeşil (alt)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.1, 1.2, false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke,
    );
    // Sarı (sol alt)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.3, 0.9, false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke,
    );
    // Mavi (sol üst)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.2, 1.0, false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke,
    );
    // Yatay çizgi (sağ tarafa giden kol)
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width, center.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.18,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Özellik satırı ────────────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1DB954), size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFFCCCCCC),
          ),
        ),
      ],
    );
  }
}

// ── Dekoratif glow dairesi ────────────────────────────────────────
class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

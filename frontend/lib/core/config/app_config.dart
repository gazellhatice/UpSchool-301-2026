import 'package:flutter/foundation.dart';

/// Firebase Console → Authentication → Google → Web client ID
abstract final class AppConfig {
  static const String webGoogleClientId =
      '290830664216-bnetflrliu1nejrhc7vb1480tb3t1ath.apps.googleusercontent.com';

  static const String firebaseWebAppId =
      '1:290830664216:web:dd2144a615eff70a8e796d';

  /// Denenecek backend adresleri (sırayla).
  static List<String> get backendUrlCandidates {
    const envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) return [envUrl];

    if (kIsWeb) {
      // Windows'ta localhost bazen IPv6 (::1) olur; Node çoğu zaman 127.0.0.1'de dinler.
      return [
        'http://127.0.0.1:3001',
        'http://localhost:3001',
      ];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // 127.0.0.1 → adb reverse tcp:3001 tcp:3001 ile çalışır (Windows firewall bypass)
      // 10.0.2.2 → klasik emülatör → PC yolu
      return [
        'http://127.0.0.1:3001',
        'http://10.0.2.2:3001',
      ];
    }

    return [
      'http://127.0.0.1:3001',
      'http://localhost:3001',
    ];
  }

  static String get backendBaseUrl => backendUrlCandidates.first;
}

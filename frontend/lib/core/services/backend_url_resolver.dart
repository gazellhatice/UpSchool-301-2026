import 'package:kisisel_harcama_kocu_1/core/config/app_config.dart';

/// Emülatörde çalışan backend URL'sini bulur ve önbelleğe alır.
class BackendUrlResolver {
  BackendUrlResolver._();

  static String? _cached;

  static String? get cached => _cached;

  static Future<String> resolve(Future<bool> Function(String baseUrl) ping) async {
    if (_cached != null) return _cached!;

    for (final base in AppConfig.backendUrlCandidates) {
      if (await ping(base)) {
        _cached = base;
        return base;
      }
    }

    return AppConfig.backendBaseUrl;
  }

  static void reset() => _cached = null;
}

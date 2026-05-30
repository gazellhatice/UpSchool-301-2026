import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kisisel_harcama_kocu_1/app.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/router_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:kisisel_harcama_kocu_1/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');

  final prefs = await SharedPreferences.getInstance();

  String? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    firebaseError = e.toString();
    if (kDebugMode) {
      debugPrint('Firebase init: $e\n$stack');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseInitErrorProvider.overrideWithValue(firebaseError),
      ],
      child: HarcamaKocuApp(firebaseInitError: firebaseError),
    ),
  );
}

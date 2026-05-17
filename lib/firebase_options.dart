import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:kisisel_harcama_kocu_1/core/config/app_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDsTk6frSHw84pDWK8LaW3FSnRUb7lxbPw',
    appId: AppConfig.firebaseWebAppId,
    messagingSenderId: '290830664216',
    projectId: 'kisisel-harcama-kocu',
    authDomain: 'kisisel-harcama-kocu.firebaseapp.com',
    storageBucket: 'kisisel-harcama-kocu.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsTk6frSHw84pDWK8LaW3FSnRUb7lxbPw',
    appId: '1:290830664216:android:ddb0f35fa43d81c48e796d',
    messagingSenderId: '290830664216',
    projectId: 'kisisel-harcama-kocu',
    storageBucket: 'kisisel-harcama-kocu.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCbV72pbDwYjSnaJZuA4s0CRmxroxoiJI',
    appId: '1:290830664216:ios:e87f4dd1bbe9e0618e796d',
    messagingSenderId: '290830664216',
    projectId: 'kisisel-harcama-kocu',
    storageBucket: 'kisisel-harcama-kocu.firebasestorage.app',
    iosBundleId: 'com.example.kisiselHarcamaKocuSon',
  );
}

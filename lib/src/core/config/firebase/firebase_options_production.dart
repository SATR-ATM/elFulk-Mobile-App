// File: lib/src/core/config/firebase/firebase_options_production.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Not configured for web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Not supported for this platform.');
    }
  }

  // 👇 بيانات وهمية مؤقتة لكي لا يتعطل التطبيق 
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dummy_api_key_for_android',
    appId: '1:123456789012:android:abcdef1234567890abcdef',
    messagingSenderId: '123456789012',
    projectId: 'elfulk-mobile-app-prod',
    storageBucket: 'elfulk-mobile-app-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy_api_key_for_ios',
    appId: '1:123456789012:ios:abcdef1234567890abcdef',
    messagingSenderId: '123456789012',
    projectId: 'elfulk-mobile-app-prod',
    storageBucket: 'elfulk-mobile-app-prod.appspot.com',
    iosBundleId: 'com.elfulk',
  );
}
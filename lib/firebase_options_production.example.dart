// Template only.
// Generate lib/firebase_options_production.dart locally with FlutterFire CLI.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Missing lib/firebase_options_production.dart. '
        'Generate it with FlutterFire CLI before running production flavor.',
      );
}

// File-level FirebaseOptions for both platforms.
//
// Values mirror what `flutterfire configure` would generate, taken verbatim
// from the downloaded google-services.json (Android) and
// GoogleService-Info.plist (iOS) of the Firebase project `sarhny-a0ce9`.
//
// Programmatic init means we don't need to register GoogleService-Info.plist
// as an Xcode resource — keeps the pbxproj diff to a minimum.

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Sarhny is mobile-only; no web Firebase setup.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: no config for $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBq9WZvHZRT2t7CKxVYkG6IVqmaVVOKljM',
    appId: '1:843994148290:android:54ecb229460dba926f3a5b',
    messagingSenderId: '843994148290',
    projectId: 'sarhny-a0ce9',
    storageBucket: 'sarhny-a0ce9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDyk7OCiM1o2DZswDVFbol0prbMb0slRhU',
    appId: '1:843994148290:ios:6e3c4c0baecf4d486f3a5b',
    messagingSenderId: '843994148290',
    projectId: 'sarhny-a0ce9',
    storageBucket: 'sarhny-a0ce9.firebasestorage.app',
    iosBundleId: 'com.sarhny.Sarhny',
  );
}

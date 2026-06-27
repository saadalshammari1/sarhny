import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/app.dart';
import 'core/api/dio_client.dart';
import 'core/providers/api_providers.dart';
import 'core/providers/auth_providers.dart';
import 'core/providers/storage_providers.dart';
import 'core/storage/cache_storage.dart';
import 'core/storage/prefs_storage.dart';
import 'core/storage/secure_storage.dart';
import 'firebase_options.dart';

/// Background message handler. MUST be a top-level (or static) function,
/// annotated with @pragma so tree-shaking doesn't eat it.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // We don't need to do much here â€” iOS displays the system banner from the
  // notification payload and Android does the same via the default channel
  // we register at runtime. The handler exists mainly to keep the isolate
  // alive long enough for FCM to deliver the payload.
  if (kDebugMode) {
    debugPrint('FCM background: ${message.notification?.title}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  // Initialize Firebase from baked-in options. We skip the platform plugin
  // auto-discovery (which would otherwise look for GoogleService-Info.plist
  // in the bundle) so the iOS Xcode project doesn't need a resource entry.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    }
  } catch (e) {
    if (kDebugMode) debugPrint('Firebase init skipped: $e');
  }

  // AdMob is mobile-only; web preview should boot without the native plugin.
  if (!kIsWeb) {
    unawaited(MobileAds.instance.initialize());
  }

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env optional during fresh installs
  }

  final prefs = await PrefsStorage.create();
  await prefs.incrementAppOpens(); // drives the "ask to rate after a few opens"
  final cache = await CacheStorage.init();
  final secure = SecureStorage();

  // DioClient is async â€” it provisions a PersistCookieJar against the
  // application support directory so the HttpOnly refresh cookie survives
  // app restarts (mirrors the browser cookie store on web).
  late final ProviderContainer container;
  final dio = await DioClient.create(
    secureStorage: secure,
    onUnauthorized: () async {
      await container.read(authStateProvider.notifier).clearSession();
    },
  );

  container = ProviderContainer(
    overrides: [
      prefsStorageProvider.overrideWithValue(prefs),
      cacheStorageProvider.overrideWithValue(cache),
      secureStorageProvider.overrideWithValue(secure),
      dioClientProvider.overrideWithValue(dio),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SarhnyApp(),
    ),
  );
}

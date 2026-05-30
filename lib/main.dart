import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/api/dio_client.dart';
import 'core/providers/api_providers.dart';
import 'core/providers/auth_providers.dart';
import 'core/providers/storage_providers.dart';
import 'core/storage/cache_storage.dart';
import 'core/storage/prefs_storage.dart';
import 'core/storage/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env optional during fresh installs
  }

  final prefs = await PrefsStorage.create();
  final cache = await CacheStorage.init();
  final secure = SecureStorage();

  // DioClient is async — it provisions a PersistCookieJar against the
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

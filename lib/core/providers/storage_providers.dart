import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/cache_storage.dart';
import '../storage/prefs_storage.dart';
import '../storage/secure_storage.dart';

/// مزودات التخزين — تُهيَّأ في main.dart عبر overrides.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  throw UnimplementedError('SecureStorage must be overridden in ProviderScope');
});

final prefsStorageProvider = Provider<PrefsStorage>((ref) {
  throw UnimplementedError('PrefsStorage must be overridden in ProviderScope');
});

final cacheStorageProvider = Provider<CacheStorage>((ref) {
  throw UnimplementedError('CacheStorage must be overridden in ProviderScope');
});

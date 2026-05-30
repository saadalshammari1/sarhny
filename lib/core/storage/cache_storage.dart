import 'package:hive_ce_flutter/hive_flutter.dart';

/// تخزين Cache بسيط فوق hive_ce.
/// نستعمل box واحد عام للـ JSON خفيف الوزن (feed cached, profile, إلخ).
class CacheStorage {
  CacheStorage._(this._box);

  final Box<dynamic> _box;

  static Future<CacheStorage> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>('sarhny_cache');
    return CacheStorage._(box);
  }

  T? get<T>(String key) {
    final value = _box.get(key);
    if (value is T) return value;
    return null;
  }

  Future<void> put(String key, Object value) => _box.put(key, value);

  Future<void> remove(String key) => _box.delete(key);

  Future<void> clear() => _box.clear();

  bool contains(String key) => _box.containsKey(key);
}

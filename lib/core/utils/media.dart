import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolve a backend-relative media path (e.g. `users/123/avatar.jpg`) into a
/// fully-qualified URL the device can fetch.
///
/// Backend exposes uploads under `/storage/*` (the FastAPI static mount that
/// proxies the same Laravel `storage/app/public` directory used by the web).
String? mediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = _resolveBase();
  final clean = path.startsWith('/') ? path.substring(1) : path;
  return '$base/storage/$clean';
}

String _resolveBase() {
  // Hardcoded for safety — see DioClient for the same defensive pattern.
  final envUrl = dotenv.maybeGet('API_BASE_URL') ?? '';
  final isLocalUrl = envUrl.contains('10.0.2.2') ||
      envUrl.contains('127.0.0.1') ||
      envUrl.contains('localhost');
  return (kDebugMode && isLocalUrl) ? envUrl : 'https://sarhny.com';
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolve a backend-relative media path (e.g. `users/123/avatar.jpg`) into a
/// fully-qualified URL the device can fetch.
///
/// Backend exposes uploads under `/storage/*` (the FastAPI static mount that
/// proxies the same Laravel `storage/app/public` directory used by the web).
String? mediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = dotenv.maybeGet('API_BASE_URL') ?? _defaultBase();
  final clean = path.startsWith('/') ? path.substring(1) : path;
  return '$base/storage/$clean';
}

String _defaultBase() {
  // Production CDN-fronted media URL.
  return 'https://sarhny.com';
}

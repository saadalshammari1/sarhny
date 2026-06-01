import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/secure_storage.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';

typedef OnUnauthorized = Future<void> Function();

/// Sarhny V2 Dio client.
///
/// - Bearer access token from SecureStorage on every request.
/// - HttpOnly refresh cookie persisted via PersistCookieJar (matches the
///   web flow where browsers do this automatically).
/// - Single-flight refresh on 401 → retry once → fail to onUnauthorized.
/// - Standard envelope `{success, data, error}` parsing.
class DioClient {
  DioClient._({
    required this.secureStorage,
    required this.onUnauthorized,
    required Dio dio,
    required PersistCookieJar cookieJar,
  })  : _dio = dio,
        _cookieJar = cookieJar;

  static Future<DioClient> create({
    required SecureStorage secureStorage,
    required OnUnauthorized onUnauthorized,
  }) async {
    final baseUrl = dotenv.maybeGet('API_BASE_URL') ?? _defaultBaseUrl();
    // Cookie jar dir — using a non-hidden folder name avoids iOS sandbox quirks
    // with dot-prefixed paths under Application Support.
    final cookieDir = await getApplicationSupportDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${cookieDir.path}/sarhny_cookies/'),
      ignoreExpires: false,
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // Generous timeouts for slow / cold-edge connections (Cloudflare's
        // first connection from a mobile carrier can take a few seconds).
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Sarhny/3.1.0 (mobile; flutter)',
        },
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final client = DioClient._(
      secureStorage: secureStorage,
      onUnauthorized: onUnauthorized,
      dio: dio,
      cookieJar: cookieJar,
    );
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(client._authInterceptor());
    dio.interceptors.add(client._refreshInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        compact: true,
        maxWidth: 100,
      ));
    }
    return client;
  }

  static String _defaultBaseUrl() {
    // Production: sarhny.com is the live backend (served via Nginx → uvicorn).
    // For local development override via `.env`:  API_BASE_URL=http://10.0.2.2:8030
    return 'https://sarhny.com';
  }

  final Dio _dio;
  final PersistCookieJar _cookieJar;
  final SecureStorage secureStorage;
  final OnUnauthorized onUnauthorized;

  Dio get raw => _dio;
  PersistCookieJar get cookies => _cookieJar;

  bool _refreshing = false;
  final List<Completer<void>> _waiters = [];

  InterceptorsWrapper _authInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      );

  InterceptorsWrapper _refreshInterceptor() => InterceptorsWrapper(
        onResponse: (response, handler) async {
          if (response.statusCode == 401 &&
              !_isAuthRoute(response.requestOptions.path)) {
            final retried = await _tryRefreshAndRetry(response.requestOptions);
            if (retried != null) return handler.resolve(retried);
            await onUnauthorized();
          }
          return handler.next(response);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode == 401 &&
              !_isAuthRoute(err.requestOptions.path)) {
            final retried = await _tryRefreshAndRetry(err.requestOptions);
            if (retried != null) return handler.resolve(retried);
            await onUnauthorized();
          }
          return handler.next(err);
        },
      );

  bool _isAuthRoute(String path) =>
      path.startsWith('/api/v1/auth/login') ||
      path.startsWith('/api/v1/auth/refresh') ||
      path.startsWith('/api/v1/auth/register') ||
      path.startsWith('/api/v1/auth/logout');

  Future<Response<dynamic>?> _tryRefreshAndRetry(RequestOptions original) async {
    if (_refreshing) {
      final c = Completer<void>();
      _waiters.add(c);
      await c.future;
    } else {
      _refreshing = true;
      try {
        if (!await _refreshTokens()) return null;
      } finally {
        _refreshing = false;
        for (final w in _waiters) {
          if (!w.isCompleted) w.complete();
        }
        _waiters.clear();
      }
    }
    final newToken = await secureStorage.readAccessToken();
    if (newToken == null) return null;
    original.headers['Authorization'] = 'Bearer $newToken';
    try {
      return await _dio.fetch(original);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _refreshTokens() async {
    try {
      final resp = await _dio.post<dynamic>(ApiEndpoints.refresh);
      if (resp.statusCode == 200 && resp.data is Map) {
        final data = (resp.data as Map)['data'];
        final access = data is Map ? data['access_token']?.toString() : null;
        if (access != null) {
          await secureStorage.writeTokens(accessToken: access, refreshToken: '');
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Standard envelope: returns parser(data) for success, throws on error.
  Future<T> request<T>(
    Future<Response<dynamic>> Function() send, {
    required T Function(dynamic data) parser,
  }) async {
    try {
      final resp = await send();
      final body = resp.data;
      if (body is! Map) throw const UnknownApiException('Invalid response body');
      final code = resp.statusCode ?? 0;
      if (body['success'] == true && code >= 200 && code < 300) {
        return parser(body['data']);
      }
      final rawErr = body['error'];
      final errorMsg = switch (rawErr) {
        Map() => rawErr['message']?.toString() ??
            rawErr.values.first.toString(),
        _ => rawErr?.toString() ?? 'حدث خطأ غير معروف',
      };
      throw switch (code) {
        401 => UnauthorizedException(errorMsg),
        403 => ForbiddenException(errorMsg),
        404 => NotFoundException(errorMsg),
        422 =>
          ValidationException(errorMsg, errors: _extractFieldErrors(rawErr)),
        429 => const RateLimitException(),
        _ => ServerException(errorMsg, statusCode: code),
      };
    } on DioException catch (e) {
      throw switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const TimeoutException('انقطع الاتصال'),
        DioExceptionType.connectionError ||
        DioExceptionType.unknown =>
          NetworkException(e.message ?? 'لا اتصال بالخادم'),
        _ => UnknownApiException(e.message ?? 'خطأ غير معروف'),
      };
    }
  }

  Map<String, List<String>>? _extractFieldErrors(Object? error) {
    if (error is! Map) return null;
    final out = <String, List<String>>{};
    error.forEach((k, v) {
      out[k.toString()] = v is List
          ? v.map((e) => e.toString()).toList()
          : [v.toString()];
    });
    return out.isEmpty ? null : out;
  }

  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }
}

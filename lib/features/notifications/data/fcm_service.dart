import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications_repository.dart';

/// Bridge between FCM and the V2 `/devices` endpoint.
///
/// iOS timing notes:
///   On first install after launch, APNs can take 2-10 s to deliver the
///   device token. `getToken()` returns null until APNs has answered. We
///   therefore subscribe to `onTokenRefresh` BEFORE the initial fetch so
///   a late-arriving token still reaches the backend, and we additionally
///   poll `getToken()` with exponential backoff (~25 s total) to cover the
///   first launch.
class FcmService {
  FcmService(this._notifications);
  final NotificationsRepository _notifications;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  bool _registered = false;
  String? _lastSentToken;

  String get _platform {
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
    } catch (_) {/* not mobile */}
    return 'mobile';
  }

  Future<void> _sendToken(String token) async {
    if (token.isEmpty || token == _lastSentToken) return;
    try {
      await _notifications.registerDevice(token, platform: _platform);
      _lastSentToken = token;
      if (kDebugMode) debugPrint('FCM token registered with backend');
    } catch (e) {
      // Network/auth failure — keep _lastSentToken null so we retry on the
      // next refresh tick.
      if (kDebugMode) debugPrint('FCM /devices POST failed: $e');
    }
  }

  Future<void> register() async {
    if (_registered) return;
    _registered = true;
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        debugPrint('FCM permission: ${settings.authorizationStatus}');
      }
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Subscribe FIRST so a late APNs/token arrival is still caught.
      _tokenSub?.cancel();
      _tokenSub = messaging.onTokenRefresh.listen(_sendToken);

      // Fast path: usually returns cached token immediately on re-launch.
      final cached = await messaging.getToken().catchError((_) => null);
      if (cached != null && cached.isNotEmpty) {
        await _sendToken(cached);
      } else {
        // Slow path: poll for up to ~25s on first install.
        unawaited(_pollForToken(messaging));
      }

      _foregroundSub?.cancel();
      _foregroundSub = FirebaseMessaging.onMessage.listen((msg) {
        if (kDebugMode) {
          debugPrint('FCM foreground: ${msg.notification?.title}');
        }
      });

      _openedSub?.cancel();
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        if (kDebugMode) debugPrint('FCM tap: ${msg.data}');
      });
    } catch (e) {
      if (kDebugMode) debugPrint('FcmService.register error: $e');
    }
  }

  Future<void> _pollForToken(FirebaseMessaging messaging) async {
    const delaysMs = [1000, 2000, 3000, 5000, 8000];
    for (final ms in delaysMs) {
      await Future<void>.delayed(Duration(milliseconds: ms));
      try {
        final t = await messaging.getToken();
        if (t != null && t.isNotEmpty) {
          await _sendToken(t);
          return;
        }
      } catch (_) {/* keep trying */}
    }
    if (kDebugMode) {
      debugPrint('FCM token still null after polling; onTokenRefresh will retry');
    }
  }

  Future<void> dispose() async {
    await _tokenSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    _tokenSub = null;
    _foregroundSub = null;
    _openedSub = null;
    _registered = false;
    _lastSentToken = null;
  }
}

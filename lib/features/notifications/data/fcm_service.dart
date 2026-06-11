import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications_repository.dart';

/// Bridge between FCM and the V2 `/devices` endpoint.
///
/// Lifecycle:
///   1. `main.dart` initializes Firebase once at app launch.
///   2. After auth succeeds, the auth listener calls `register()`.
///   3. `register()` asks the OS for permission, fetches the FCM token,
///      and POSTs it to `/api/v1/devices` along with platform metadata.
///   4. Token refreshes (FCM rotates them occasionally) are auto-sent.
///   5. `dispose()` is called on sign-out so subscriptions get torn down
///      and the next sign-in gets a fresh subscription set.
class FcmService {
  FcmService(this._notifications);
  final NotificationsRepository _notifications;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  bool _registered = false;

  String get _platform {
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
    } catch (_) {/* not mobile */}
    return 'mobile';
  }

  Future<void> register() async {
    if (_registered) return;
    try {
      final messaging = FirebaseMessaging.instance;

      // Ask for notification permissions. On Android 13+ this prompts the
      // user; on Android ≤12 it's a no-op (granted by default). On iOS it
      // shows the standard alert.
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        debugPrint('FCM permission: ${settings.authorizationStatus}');
      }

      // On iOS the APNS token must be available before we can request the
      // FCM token; setForegroundNotificationPresentationOptions ensures the
      // banner shows up while the app is in the foreground.
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        // Best-effort wait for APNS — short timeout so we don't hang the
        // auth flow if the simulator/sandbox is slow.
        try {
          await messaging.getAPNSToken().timeout(const Duration(seconds: 4));
        } catch (_) {/* continue; FCM will retry */}
      }

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _notifications.registerDevice(token, platform: _platform);
      }

      _tokenSub?.cancel();
      _tokenSub = messaging.onTokenRefresh.listen((t) {
        _notifications.registerDevice(t, platform: _platform);
      });

      _foregroundSub?.cancel();
      _foregroundSub = FirebaseMessaging.onMessage.listen((msg) {
        // The iOS presentation options above already show a system banner.
        // On Android the foreground banner requires a notification channel
        // + flutter_local_notifications hook — skipped for the MVP since
        // most notifications fire when the app is closed anyway.
        if (kDebugMode) {
          debugPrint('FCM foreground: ${msg.notification?.title}');
        }
      });

      _openedSub?.cancel();
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        // TODO: route to the relevant screen based on msg.data['event'].
        if (kDebugMode) {
          debugPrint('FCM tap: ${msg.data}');
        }
      });

      _registered = true;
    } catch (e) {
      // Firebase not initialised / no permission / etc — non-fatal.
      if (kDebugMode) debugPrint('FcmService.register skipped: $e');
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
  }
}

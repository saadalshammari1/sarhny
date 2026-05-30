import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications_repository.dart';

/// Bridge between FCM and the V2 `/devices` endpoint.
///
/// The caller (typically the auth gate, after sign-in) must:
///   1. Ensure FirebaseApp is initialized (`Firebase.initializeApp`).
///   2. Call `register()` to request permission, fetch the token, and POST
///      it to the backend.
///
/// We deliberately do NOT initialize Firebase here so the app can boot
/// without `google-services.json` / `GoogleService-Info.plist` during the
/// initial dev setup.
class FcmService {
  FcmService(this._notifications);
  final NotificationsRepository _notifications;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _msgSub;

  Future<void> register() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _notifications.registerDevice(token);
      }
      _tokenSub?.cancel();
      _tokenSub =
          messaging.onTokenRefresh.listen(_notifications.registerDevice);
      _msgSub?.cancel();
      _msgSub = FirebaseMessaging.onMessage.listen((msg) {
        if (kDebugMode) debugPrint('FCM foreground: ${msg.notification?.title}');
      });
    } catch (e) {
      // Firebase not initialised / iOS sim without notifications / etc.
      if (kDebugMode) debugPrint('FcmService.register skipped: $e');
    }
  }

  Future<void> dispose() async {
    await _tokenSub?.cancel();
    await _msgSub?.cancel();
  }
}

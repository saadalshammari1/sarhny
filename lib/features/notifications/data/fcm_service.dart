import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications_repository.dart';

/// FCM ↔ backend bridge with full server-side diagnostics.
///
/// On every meaningful step we POST a small payload to
/// `/api/v1/devices/diagnostic` so journalctl on the API host shows exactly
/// what stage the iOS app reached — even on TestFlight where debugPrint is
/// stripped. The diagnostic call is fire-and-forget; any failure is
/// swallowed so it never disrupts the real flow.
class FcmService {
  FcmService(this._notifications);
  final NotificationsRepository _notifications;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  Timer? _periodicTicker;
  bool _registered = false;
  String? _lastSentToken;

  String get _platform {
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
    } catch (_) {/* not mobile */}
    return 'mobile';
  }

  void _log(String msg) {
    developer.log(msg, name: 'sarhny.fcm');
  }

  Future<void> _diag(String phase, String status, [String detail = '']) async {
    _log('[$phase] $status ${detail.isEmpty ? '' : '— $detail'}');
    await _notifications.diagnostic(phase: phase, status: status, detail: detail);
  }

  Future<void> _sendToken(String token) async {
    if (token.isEmpty || token == _lastSentToken) return;
    await _diag('post_attempt', 'sending', 'tok_len=${token.length}');
    try {
      await _notifications.registerDevice(token, platform: _platform);
      _lastSentToken = token;
      await _diag('post_attempt', 'success');
      _cancelTicker();
    } catch (e) {
      await _diag('post_attempt', 'failed', '$e');
    }
  }

  Future<void> register() async {
    if (_registered) return;
    _registered = true;

    await _diag('register', 'begin', 'platform=$_platform');

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.setAutoInitEnabled(true);

      final settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );
      await _diag(
        'permission',
        settings.authorizationStatus.name,
        'alert=${settings.alert.name} badge=${settings.badge.name}',
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      var canReadFcmToken = true;
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true,
        );

        // Wait for APNs before asking Firebase for an FCM token on iOS.
        final apnsReady = await _waitForApnsToken(messaging);
        if (!apnsReady) {
          await _diag('fcm_token', 'deferred', 'waiting for APNs token');
          canReadFcmToken = false;
        }
      }

      _tokenSub?.cancel();
      _tokenSub = messaging.onTokenRefresh.listen(
        _sendToken,
        onError: (Object e) => _diag('fcm_token', 'refresh_error', '$e'),
      );

      _foregroundSub?.cancel();
      _foregroundSub = FirebaseMessaging.onMessage.listen((msg) {
        _log('foreground msg: ${msg.notification?.title}');
      });
      _openedSub?.cancel();
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        _log('tap msg: ${msg.data}');
      });

      if (!canReadFcmToken) {
        unawaited(_pollForToken(messaging));
        return;
      }

      final cached = await messaging.getToken().catchError((Object e) {
        _diag('fcm_token', 'fast_error', '$e');
        return null;
      });
      if (cached != null && cached.isNotEmpty) {
        await _diag('fcm_token', 'fast_ok', 'len=${cached.length}');
        await _sendToken(cached);
        return;
      }
      await _diag('fcm_token', 'fast_null', 'starting polling');
      unawaited(_pollForToken(messaging));
    } catch (e) {
      await _diag('register', 'error', '$e');
    }
  }

  Future<bool> _waitForApnsToken(FirebaseMessaging messaging) async {
    // Apple can be slow on first install. FCM token retrieval on iOS depends
    // on APNs, so wait before calling getToken.
    const delays = [1, 2, 3, 5, 8, 13, 21, 34];
    for (final s in delays) {
      await Future<void>.delayed(Duration(seconds: s));
      final apns = await _readApnsToken(messaging);
      if (apns != null && apns.isNotEmpty) {
        await _diag('apns_token', 'received', 'len=${apns.length}');
        return true;
      }
    }
    await _diag(
      'apns_token',
      'never_arrived',
      'Suspect: Push Notifications capability missing on App ID or aps-environment entitlement stripped during signing.',
    );
    return false;
  }

  Future<String?> _readApnsToken(FirebaseMessaging messaging) async {
    try {
      return await messaging.getAPNSToken();
    } catch (e) {
      await _diag('apns_token', 'error', '$e');
      return null;
    }
  }

  Future<void> _pollForToken(FirebaseMessaging messaging) async {
    const fastDelaysMs = [1000, 2000, 3000, 5000, 8000, 12000];
    for (final ms in fastDelaysMs) {
      await Future<void>.delayed(Duration(milliseconds: ms));
      try {
        if (Platform.isIOS) {
          final apns = await _readApnsToken(messaging);
          if (apns == null || apns.isEmpty) {
            await _diag('fcm_token', 'waiting_for_apns');
            continue;
          }
        }
        final t = await messaging.getToken();
        if (t != null && t.isNotEmpty) {
          await _diag('fcm_token', 'poll_ok', 'len=${t.length}');
          await _sendToken(t);
          return;
        }
      } catch (e) {
        await _diag('fcm_token', 'poll_error', '$e');
      }
    }

    await _diag('fcm_token', 'poll_exhausted', 'switching to 60s ticker');
    _cancelTicker();
    _periodicTicker = Timer.periodic(const Duration(seconds: 60), (_) async {
      try {
        if (Platform.isIOS) {
          final apns = await _readApnsToken(messaging);
          if (apns == null || apns.isEmpty) {
            await _diag('fcm_token', 'ticker_waiting_for_apns');
            return;
          }
        }
        final t = await messaging.getToken();
        if (t != null && t.isNotEmpty) {
          await _diag('fcm_token', 'ticker_ok', 'len=${t.length}');
          await _sendToken(t);
        }
      } catch (e) {
        await _diag('fcm_token', 'ticker_error', '$e');
      }
    });
  }

  void _cancelTicker() {
    _periodicTicker?.cancel();
    _periodicTicker = null;
  }

  Future<void> dispose() async {
    _cancelTicker();
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

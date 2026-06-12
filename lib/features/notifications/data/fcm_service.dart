import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications_repository.dart';

/// FCM ↔ backend bridge. Designed to survive every iOS edge case I could
/// think of:
///
///   * APNs token can take 2-10 s on cold install — we subscribe to
///     `onTokenRefresh` BEFORE the initial fetch so a late arrival still
///     lands at the backend.
///   * `getToken()` can return null on first call even with permission
///     granted — we poll with exponential backoff for ~30 s, then drop
///     to a 60 s repeating ticker so we eventually succeed if the user
///     left the app open in the background.
///   * Network failure on `/devices` POST doesn't burn the token — we
///     forget `_lastSentToken` on POST failure so the next refresh / poll
///     retries.
///   * All progress is logged via `developer.log` so iOS Console.app and
///     `idevicesyslog` capture it even in release / TestFlight builds.
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
    // Release builds strip kDebugMode prints, but dart:developer log is
    // routed to NSLog/Logcat — visible in Console.app (iOS) and adb logcat.
    developer.log(msg, name: 'sarhny.fcm');
  }

  Future<void> _sendToken(String token) async {
    if (token.isEmpty || token == _lastSentToken) return;
    _log('attempting /devices POST (tok=${token.substring(0, 16)}…)');
    try {
      await _notifications.registerDevice(token, platform: _platform);
      _lastSentToken = token;
      _log('/devices POST succeeded');
      _cancelTicker();
    } catch (e) {
      _log('/devices POST failed: $e');
      // Drop cache so the next stream/poll attempt retries.
    }
  }

  Future<void> register() async {
    if (_registered) return;
    _registered = true;
    _log('register() begin');
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _log('permission = ${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _log('permission denied — abort');
        return;
      }

      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true,
        );
      }

      // Subscribe BEFORE first fetch so late-arriving tokens still post.
      _tokenSub?.cancel();
      _tokenSub = messaging.onTokenRefresh.listen(
        _sendToken,
        onError: (Object e) => _log('onTokenRefresh error: $e'),
      );

      // Foreground & tap.
      _foregroundSub?.cancel();
      _foregroundSub = FirebaseMessaging.onMessage.listen((msg) {
        _log('foreground msg: ${msg.notification?.title}');
      });
      _openedSub?.cancel();
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        _log('tap msg: ${msg.data}');
      });

      // Try the fast path (cached token returns instantly).
      final cached = await messaging.getToken().catchError((Object _) => null);
      if (cached != null && cached.isNotEmpty) {
        _log('cached token available immediately');
        await _sendToken(cached);
        return;
      }

      _log('no cached token — entering polling phase');
      unawaited(_pollForToken(messaging));
    } catch (e) {
      _log('register() error: $e');
    }
  }

  /// Aggressive polling: ~30 s of exponential backoff, then a 60 s ticker
  /// that runs indefinitely until success. Stops as soon as `_sendToken`
  /// succeeds (it cancels the ticker).
  Future<void> _pollForToken(FirebaseMessaging messaging) async {
    // Phase 1 — fast exponential backoff covering most first-launch races.
    const fastDelaysMs = [1000, 2000, 3000, 5000, 8000, 12000];
    for (final ms in fastDelaysMs) {
      await Future<void>.delayed(Duration(milliseconds: ms));
      try {
        final t = await messaging.getToken();
        if (t != null && t.isNotEmpty) {
          _log('token acquired during fast polling');
          await _sendToken(t);
          return;
        }
      } catch (e) {
        _log('getToken fast-poll error: $e');
      }
    }

    // Phase 2 — slow ticker, runs until success or disposal.
    _log('fast polling exhausted; switching to 60 s ticker');
    _cancelTicker();
    _periodicTicker = Timer.periodic(const Duration(seconds: 60), (timer) async {
      try {
        final t = await messaging.getToken();
        if (t != null && t.isNotEmpty) {
          _log('token acquired during slow ticker');
          await _sendToken(t);
        } else {
          _log('slow ticker: token still null');
        }
      } catch (e) {
        _log('slow ticker getToken error: $e');
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

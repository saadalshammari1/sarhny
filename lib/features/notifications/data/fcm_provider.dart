import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../core/providers/api_providers.dart';
import 'fcm_service.dart';
import 'notifications_repository.dart';

/// Single FcmService instance per app lifetime. Auto-disposed via the
/// `keepAlive` semantics of a regular Provider — but holds StreamSubscriptions,
/// so we explicitly dispose() in onDispose for tear-down on sign-out.
final fcmServiceProvider = Provider<FcmService>((ref) {
  final dio = ref.watch(dioClientProvider);
  final repo = NotificationsRepository(dio);
  final service = FcmService(
    repo,
    onNavigate: (route) {
      try {
        ref.read(routerProvider).push(route);
      } catch (_) {/* router not ready yet — ignore */}
    },
  );
  ref.onDispose(service.dispose);
  return service;
});

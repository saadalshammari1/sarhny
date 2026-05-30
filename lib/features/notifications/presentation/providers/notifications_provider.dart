import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../data/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(dioClientProvider));
});

final notificationsListProvider =
    FutureProvider<NotificationsPage>((ref) async {
  return ref.watch(notificationsRepositoryProvider).list();
});

final unreadNotificationsCountProvider =
    FutureProvider<int>((ref) async {
  try {
    return await ref.watch(notificationsRepositoryProvider).unreadCount();
  } catch (_) {
    return 0;
  }
});

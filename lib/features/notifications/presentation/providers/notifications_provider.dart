import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/dto.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(dioClientProvider));
});

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.cursor,
    this.reachedEnd = false,
    this.loadingMore = false,
  });
  final List<NotificationDto> items;
  final int? cursor;
  final bool reachedEnd;
  final bool loadingMore;

  NotificationsState copyWith({
    List<NotificationDto>? items,
    int? cursor,
    bool? reachedEnd,
    bool? loadingMore,
  }) =>
      NotificationsState(
        items: items ?? this.items,
        cursor: cursor ?? this.cursor,
        reachedEnd: reachedEnd ?? this.reachedEnd,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class NotificationsController extends AsyncNotifier<NotificationsState> {
  @override
  Future<NotificationsState> build() async {
    final page = await ref.read(notificationsRepositoryProvider).list();
    return NotificationsState(
      items: page.items,
      cursor: page.nextCursor,
      reachedEnd: page.nextCursor == null,
    );
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || cur.loadingMore || cur.reachedEnd) return;
    state = AsyncData(cur.copyWith(loadingMore: true));
    try {
      final page = await ref
          .read(notificationsRepositoryProvider)
          .list(cursor: cur.cursor);
      state = AsyncData(cur.copyWith(
        items: [...cur.items, ...page.items],
        cursor: page.nextCursor,
        reachedEnd: page.nextCursor == null,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false));
    }
  }
}

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);

final unreadNotificationsCountProvider =
    FutureProvider<int>((ref) async {
  try {
    return await ref.watch(notificationsRepositoryProvider).unreadCount();
  } catch (_) {
    return 0;
  }
});

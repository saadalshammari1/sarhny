import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/dto.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/inbox_repository.dart';

final inboxRepositoryProvider = Provider<InboxRepository>(
  (ref) => InboxRepository(ref.watch(dioClientProvider)),
);

enum InboxFilter { all, unread, read, answered }

extension InboxFilterX on InboxFilter {
  String get apiValue => name;
  String get arabicLabel {
    switch (this) {
      case InboxFilter.all:
        return 'الكل';
      case InboxFilter.unread:
        return 'جديدة';
      case InboxFilter.read:
        return 'مقروءة';
      case InboxFilter.answered:
        return 'مُجاب عنها';
    }
  }
}

final inboxFilterProvider =
    StateProvider<InboxFilter>((_) => InboxFilter.all);

class InboxState {
  const InboxState({
    this.items = const [],
    this.cursor,
    this.reachedEnd = false,
    this.loadingMore = false,
  });
  final List<InboxItemDto> items;
  final int? cursor;
  final bool reachedEnd;
  final bool loadingMore;

  InboxState copyWith({
    List<InboxItemDto>? items,
    int? cursor,
    bool? reachedEnd,
    bool? loadingMore,
    bool clearCursor = false,
  }) =>
      InboxState(
        items: items ?? this.items,
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        reachedEnd: reachedEnd ?? this.reachedEnd,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class InboxController
    extends FamilyAsyncNotifier<InboxState, InboxFilter> {
  @override
  Future<InboxState> build(InboxFilter arg) async {
    final page = await ref
        .read(inboxRepositoryProvider)
        .list(status: arg.apiValue);
    return InboxState(
      items: page.items,
      cursor: page.nextCursor,
      reachedEnd: page.nextCursor == null,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.loadingMore || current.reachedEnd) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await ref.read(inboxRepositoryProvider).list(
            status: arg.apiValue,
            cursor: current.cursor,
          );
      state = AsyncData(current.copyWith(
        items: [...current.items, ...page.items],
        cursor: page.nextCursor,
        reachedEnd: page.nextCursor == null,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  void removeLocal(int id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: current.items.where((m) => m.id != id).toList(),
    ));
  }

  void updateLocal(int id, InboxItemDto updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: [
        for (final m in current.items)
          if (m.id == id) updated else m,
      ],
    ));
  }
}

final inboxControllerProvider = AsyncNotifierProvider.family<InboxController,
    InboxState, InboxFilter>(InboxController.new);

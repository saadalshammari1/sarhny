import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(ref.watch(dioClientProvider));
});

class FeedQuery {
  const FeedQuery({required this.scope, required this.section});
  final FeedScope scope;
  final SectionFilter section;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedQuery &&
          other.scope == scope &&
          other.section == section);

  @override
  int get hashCode => Object.hash(scope, section);
}

class FeedState {
  const FeedState({
    this.posts = const [],
    this.cursor,
    this.loadingMore = false,
    this.reachedEnd = false,
    this.error,
  });
  final List<PostDto> posts;
  final FeedCursor? cursor;
  final bool loadingMore;
  final bool reachedEnd;
  final String? error;

  FeedState copyWith({
    List<PostDto>? posts,
    FeedCursor? cursor,
    bool? loadingMore,
    bool? reachedEnd,
    String? error,
    bool clearCursor = false,
    bool clearError = false,
  }) =>
      FeedState(
        posts: posts ?? this.posts,
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        loadingMore: loadingMore ?? this.loadingMore,
        reachedEnd: reachedEnd ?? this.reachedEnd,
        error: clearError ? null : (error ?? this.error),
      );
}

class FeedController extends FamilyAsyncNotifier<FeedState, FeedQuery> {
  @override
  Future<FeedState> build(FeedQuery arg) async {
    final repo = ref.read(feedRepositoryProvider);
    final page = await repo.fetch(
      scope: arg.scope,
      section: arg.section.apiValue,
    );
    return FeedState(
      posts: page.posts,
      cursor: page.nextCursor,
      reachedEnd: page.nextCursor == null,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.loadingMore || current.reachedEnd) return;
    state = AsyncData(current.copyWith(loadingMore: true, clearError: true));
    try {
      final repo = ref.read(feedRepositoryProvider);
      final page = await repo.fetch(
        scope: arg.scope,
        section: arg.section.apiValue,
        cursor: current.cursor,
      );
      state = AsyncData(current.copyWith(
        posts: [...current.posts, ...page.posts],
        cursor: page.nextCursor,
        loadingMore: false,
        reachedEnd: page.nextCursor == null,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(
        loadingMore: false,
        error: e.toString(),
      ));
    }
  }
}

final feedControllerProvider = AsyncNotifierProvider.family<
    FeedController, FeedState, FeedQuery>(FeedController.new);

/// UI-only state — kept on the page itself but provided here so other widgets
/// (e.g. the bottom tab) can read the current scope without prop-drilling.
// Default to the user's followers feed — the global "world" view can surface
// content from strangers that the user hasn't opted into, so we land them on
// the safer/followed-only stream first.
final feedScopeProvider =
    StateProvider<FeedScope>((_) => FeedScope.following);
// Unified feed: merges V2 native posts + legacy answer archive (1.17M rows)
// by recency, with the origin question rendered above each answer-style post.
final feedSectionProvider =
    StateProvider<SectionFilter>((_) => SectionFilter.all);

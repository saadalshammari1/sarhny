import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/dto.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/comment_dto.dart';
import '../../data/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioClientProvider)),
);

final postProvider = FutureProvider.family<PostDto, int>((ref, id) {
  return ref.watch(postRepositoryProvider).getPost(id);
});

class CommentsState {
  const CommentsState({
    this.comments = const [],
    this.cursor,
    this.reachedEnd = false,
    this.loadingMore = false,
  });
  final List<CommentDto> comments;
  final int? cursor;
  final bool reachedEnd;
  final bool loadingMore;

  CommentsState copyWith({
    List<CommentDto>? comments,
    int? cursor,
    bool? reachedEnd,
    bool? loadingMore,
    bool clearCursor = false,
  }) =>
      CommentsState(
        comments: comments ?? this.comments,
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        reachedEnd: reachedEnd ?? this.reachedEnd,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class CommentsController extends FamilyAsyncNotifier<CommentsState, int> {
  @override
  Future<CommentsState> build(int arg) async {
    final page = await ref.read(postRepositoryProvider).listComments(arg);
    return CommentsState(
      comments: page.comments,
      cursor: page.nextCursor,
      reachedEnd: page.nextCursor == null,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.loadingMore || current.reachedEnd) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await ref
          .read(postRepositoryProvider)
          .listComments(arg, cursor: current.cursor);
      state = AsyncData(current.copyWith(
        comments: [...current.comments, ...page.comments],
        cursor: page.nextCursor,
        reachedEnd: page.nextCursor == null,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  Future<void> add(CommentDto c) async {
    final current = state.valueOrNull ?? const CommentsState();
    state = AsyncData(current.copyWith(comments: [c, ...current.comments]));
  }
}

final commentsControllerProvider = AsyncNotifierProvider.family<
    CommentsController, CommentsState, int>(CommentsController.new);

class AnonRepliesState {
  const AnonRepliesState({
    this.replies = const [],
    this.cursor,
    this.reachedEnd = false,
    this.loadingMore = false,
  });
  final List<AnonReplyDto> replies;
  final int? cursor;
  final bool reachedEnd;
  final bool loadingMore;

  AnonRepliesState copyWith({
    List<AnonReplyDto>? replies,
    int? cursor,
    bool? reachedEnd,
    bool? loadingMore,
    bool clearCursor = false,
  }) =>
      AnonRepliesState(
        replies: replies ?? this.replies,
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        reachedEnd: reachedEnd ?? this.reachedEnd,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class AnonRepliesController
    extends FamilyAsyncNotifier<AnonRepliesState, int> {
  @override
  Future<AnonRepliesState> build(int arg) async {
    final page =
        await ref.read(postRepositoryProvider).listAnonReplies(arg);
    return AnonRepliesState(
      replies: page.replies,
      cursor: page.nextCursor,
      reachedEnd: page.nextCursor == null,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.loadingMore || current.reachedEnd) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await ref
          .read(postRepositoryProvider)
          .listAnonReplies(arg, cursor: current.cursor);
      state = AsyncData(current.copyWith(
        replies: [...current.replies, ...page.replies],
        cursor: page.nextCursor,
        reachedEnd: page.nextCursor == null,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  Future<void> add(AnonReplyDto r) async {
    final current = state.valueOrNull ?? const AnonRepliesState();
    state = AsyncData(current.copyWith(replies: [r, ...current.replies]));
  }
}

final anonRepliesControllerProvider = AsyncNotifierProvider.family<
    AnonRepliesController, AnonRepliesState, int>(AnonRepliesController.new);

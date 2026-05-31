import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/post_repository.dart';

/// Local optimistic state for like/save toggles on any post.
///
/// Backend doesn't expose `is_liked`/`is_saved` per viewer (would cost an
/// extra join per row in the feed query), so we maintain a per-session map
/// keyed by post id. On app restart everything resets to "not liked" — that's
/// acceptable since liking is mostly an in-the-moment action and the counts
/// (which DO come from the server) remain accurate.
class PostInteractionState {
  const PostInteractionState({
    this.liked = false,
    this.saved = false,
    this.likeBusy = false,
    this.saveBusy = false,
    this.likeDelta = 0,
  });
  final bool liked;
  final bool saved;
  final bool likeBusy;
  final bool saveBusy;
  /// Used to adjust the displayed `likes_count`: +1 when we optimistically
  /// like, -1 when we unlike. PostCard reads `post.likesCount + likeDelta`.
  final int likeDelta;

  PostInteractionState copyWith({
    bool? liked,
    bool? saved,
    bool? likeBusy,
    bool? saveBusy,
    int? likeDelta,
  }) =>
      PostInteractionState(
        liked: liked ?? this.liked,
        saved: saved ?? this.saved,
        likeBusy: likeBusy ?? this.likeBusy,
        saveBusy: saveBusy ?? this.saveBusy,
        likeDelta: likeDelta ?? this.likeDelta,
      );
}

class PostInteractionController
    extends FamilyNotifier<PostInteractionState, int> {
  @override
  PostInteractionState build(int arg) => const PostInteractionState();

  Future<void> toggleLike(PostRepository repo) async {
    if (state.likeBusy) return;
    final wasLiked = state.liked;
    state = state.copyWith(
      liked: !wasLiked,
      likeBusy: true,
      likeDelta: state.likeDelta + (wasLiked ? -1 : 1),
    );
    try {
      if (wasLiked) {
        await repo.unlike(arg);
      } else {
        await repo.like(arg);
      }
    } catch (_) {
      // revert
      state = state.copyWith(
        liked: wasLiked,
        likeDelta: state.likeDelta + (wasLiked ? 1 : -1),
      );
    } finally {
      state = state.copyWith(likeBusy: false);
    }
  }

  Future<void> toggleSave(PostRepository repo) async {
    if (state.saveBusy) return;
    final wasSaved = state.saved;
    state = state.copyWith(saved: !wasSaved, saveBusy: true);
    try {
      if (wasSaved) {
        await repo.unsave(arg);
      } else {
        await repo.save(arg);
      }
    } catch (_) {
      state = state.copyWith(saved: wasSaved);
    } finally {
      state = state.copyWith(saveBusy: false);
    }
  }
}

final postInteractionProvider = NotifierProvider.family<
    PostInteractionController, PostInteractionState, int>(
  PostInteractionController.new,
);

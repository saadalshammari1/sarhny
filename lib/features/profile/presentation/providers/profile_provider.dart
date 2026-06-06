import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/dto.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioClientProvider)),
);

final publicProfileProvider =
    FutureProvider.family<PublicProfileDto, String>((ref, username) {
  return ref.watch(profileRepositoryProvider).get(username);
});

enum ProfileTab { active, moments, answers, crystals, likes }

final selectedProfileTabProvider =
    StateProvider.family<ProfileTab, String>((_, __) => ProfileTab.active);

class ProfilePostsKey {
  const ProfilePostsKey({required this.username, required this.tab});
  factory ProfilePostsKey.make(String username, ProfileTab tab) =>
      ProfilePostsKey(username: username, tab: tab);
  final String username;
  final ProfileTab tab;
  @override
  bool operator ==(Object other) =>
      other is ProfilePostsKey &&
      other.username == username &&
      other.tab == tab;
  @override
  int get hashCode => Object.hash(username, tab);
}

class ProfilePostsState {
  const ProfilePostsState({
    this.posts = const [],
    this.cursor,
    this.reachedEnd = false,
    this.loadingMore = false,
  });
  final List<PostDto> posts;
  final int? cursor;
  final bool reachedEnd;
  final bool loadingMore;

  ProfilePostsState copyWith({
    List<PostDto>? posts,
    int? cursor,
    bool? reachedEnd,
    bool? loadingMore,
  }) =>
      ProfilePostsState(
        posts: posts ?? this.posts,
        cursor: cursor ?? this.cursor,
        reachedEnd: reachedEnd ?? this.reachedEnd,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class ProfilePostsController
    extends FamilyAsyncNotifier<ProfilePostsState, ProfilePostsKey> {
  Future<ProfilePostsPage> _fetch(ProfilePostsKey key, {int? cursor}) {
    final repo = ref.read(profileRepositoryProvider);
    switch (key.tab) {
      case ProfileTab.active:
        return repo.listActive(key.username, cursor: cursor);
      case ProfileTab.moments:
        return repo.listMoments(key.username, cursor: cursor);
      case ProfileTab.answers:
        return repo.listAnswers(key.username, cursor: cursor);
      case ProfileTab.crystals:
        return repo.listCrystals(key.username, cursor: cursor);
      case ProfileTab.likes:
        return repo.listLikes(key.username, cursor: cursor);
    }
  }

  @override
  Future<ProfilePostsState> build(ProfilePostsKey arg) async {
    final page = await _fetch(arg);
    return ProfilePostsState(
      posts: page.posts,
      cursor: page.nextCursor,
      reachedEnd: page.nextCursor == null,
    );
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || cur.loadingMore || cur.reachedEnd) return;
    state = AsyncData(cur.copyWith(loadingMore: true));
    try {
      final page = await _fetch(arg, cursor: cur.cursor);
      state = AsyncData(cur.copyWith(
        posts: [...cur.posts, ...page.posts],
        cursor: page.nextCursor,
        reachedEnd: page.nextCursor == null,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false));
    }
  }
}

final profilePostsProvider = AsyncNotifierProvider.family<
    ProfilePostsController, ProfilePostsState, ProfilePostsKey>(
  ProfilePostsController.new,
);

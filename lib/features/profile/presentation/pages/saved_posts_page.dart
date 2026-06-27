import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../feed/presentation/widgets/post_card_skeleton.dart';
import '../../../post/presentation/providers/post_provider.dart';

class _SavedState {
  const _SavedState({
    this.posts = const [],
    this.cursor,
    this.reachedEnd = false,
    this.loadingMore = false,
  });
  final List<PostDto> posts;
  final int? cursor;
  final bool reachedEnd;
  final bool loadingMore;

  _SavedState copyWith({
    List<PostDto>? posts,
    int? cursor,
    bool? reachedEnd,
    bool? loadingMore,
  }) =>
      _SavedState(
        posts: posts ?? this.posts,
        cursor: cursor ?? this.cursor,
        reachedEnd: reachedEnd ?? this.reachedEnd,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class _SavedController extends AsyncNotifier<_SavedState> {
  @override
  Future<_SavedState> build() async {
    final page = await ref.read(postRepositoryProvider).listSavedPosts();
    return _SavedState(
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
      final page = await ref
          .read(postRepositoryProvider)
          .listSavedPosts(cursor: cur.cursor);
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

final _savedProvider =
    AsyncNotifierProvider<_SavedController, _SavedState>(_SavedController.new);

class SavedPostsPage extends ConsumerStatefulWidget {
  const SavedPostsPage({super.key});

  @override
  ConsumerState<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends ConsumerState<SavedPostsPage> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - 400) {
      ref.read(_savedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final state = ref.watch(_savedProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l.profileSavedTitle)),
      body: RefreshIndicator(
        color: colors.moment,
        onRefresh: () async {
          ref.invalidate(_savedProvider);
          await ref.read(_savedProvider.future);
        },
        child: state.when(
          loading: () => ListView.builder(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (_, __) => const PostCardSkeleton(),
          ),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(_savedProvider),
          ),
          data: (s) {
            if (s.posts.isEmpty) {
              return ListView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.bookmark_outline,
                    title: l.profileSavedEmptyTitle,
                    subtitle: l.profileSavedEmptySubtitle,
                  ),
                ],
              );
            }
            return ListView.separated(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 90),
              itemCount: s.posts.length + (s.reachedEnd ? 0 : 1),
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                if (i >= s.posts.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.moment,
                        ),
                      ),
                    ),
                  );
                }
                final p = s.posts[i];
                return PostCard(key: ValueKey<int>(p.id), post: p);
              },
            );
          },
        ),
      ),
    );
  }
}

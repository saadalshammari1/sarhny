import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/feed_repository.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_card_skeleton.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) {
      _loadMore();
    }
  }

  FeedQuery get _query => FeedQuery(
        scope: ref.read(feedScopeProvider),
        section: ref.read(feedSectionProvider),
      );

  void _loadMore() {
    final notifier = ref.read(feedControllerProvider(_query).notifier);
    notifier.loadMore();
  }

  Future<void> _refresh() async {
    await ref.read(feedControllerProvider(_query).notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final scope = ref.watch(feedScopeProvider);
    final section = ref.watch(feedSectionProvider);
    final query = FeedQuery(scope: scope, section: section);
    final feedState = ref.watch(feedControllerProvider(query));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: _ScopeSwitcher(
          scope: scope,
          onChanged: (s) =>
              ref.read(feedScopeProvider.notifier).state = s,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined,
                color: colors.textSecondary),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: colors.moment),
            onPressed: () => context.push('/compose'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _SectionTabs(
            current: section,
            onChanged: (s) =>
                ref.read(feedSectionProvider.notifier).state = s,
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(active: 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.moment,
        foregroundColor: Colors.black,
        onPressed: () => context.push('/compose'),
        child: const Icon(Icons.edit_outlined),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: colors.moment,
        child: feedState.when(
          loading: () => ListView.builder(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (_, __) => const PostCardSkeleton(),
          ),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: _refresh,
          ),
          data: (state) {
            if (state.posts.isEmpty) {
              return ListView(
                controller: _scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.inbox_outlined,
                    title: scope == FeedScope.following
                        ? 'لا يوجد شيء بعد من متابعيك'
                        : 'لا يوجد شيء في هذا القسم',
                    subtitle: scope == FeedScope.following
                        ? 'تابع حسابات جديدة لترى منشوراتهم هنا'
                        : 'كن أول من ينشر شيئاً ⚡',
                  ),
                ],
              );
            }
            // Use ListView.separated for guaranteed visible gaps between
            // posts, with a stable ValueKey per item so Riverpod rebuilds
            // don't accidentally collapse the list. cacheExtent pre-renders
            // ~3 cards above/below the viewport so scrolling never reveals
            // an empty stretch.
            return ListView.separated(
              key: const PageStorageKey<String>('feed-list'),
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              // ignore: deprecated_member_use
              cacheExtent: 1200,
              padding: const EdgeInsets.only(top: 4, bottom: 90),
              itemCount: state.posts.length + (state.reachedEnd ? 0 : 1),
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                if (i >= state.posts.length) {
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
                final p = state.posts[i];
                return PostCard(key: ValueKey<int>(p.id), post: p);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ScopeSwitcher extends StatelessWidget {
  const _ScopeSwitcher({required this.scope, required this.onChanged});
  final FeedScope scope;
  final ValueChanged<FeedScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(99),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: 'شاهد متابعيك',
            selected: scope == FeedScope.following,
            onTap: () => onChanged(FeedScope.following),
            colors: colors,
          ),
          _Pill(
            label: 'شاهد العالم',
            selected: scope == FeedScope.global,
            onTap: () => onChanged(FeedScope.global),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.textPrimary : colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.current, required this.onChanged});
  final SectionFilter current;
  final ValueChanged<SectionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: SectionFilter.values
            .map((s) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: _SectionChip(
                    section: s,
                    selected: s == current,
                    onTap: () => onChanged(s),
                    colors: colors,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.section,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final SectionFilter section;
  final bool selected;
  final VoidCallback onTap;
  final SarhnyColors colors;

  Color _accent() {
    switch (section) {
      case SectionFilter.moment:
        return colors.moment;
      case SectionFilter.face:
        return colors.face;
      case SectionFilter.mind:
        return colors.mind;
      case SectionFilter.questions:
        return colors.moment;
      case SectionFilter.all:
        return colors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : colors.elevated,
          border: Border.all(
            color: selected ? accent : colors.border,
            width: selected ? 1.2 : 0.6,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            Text(section.glyph, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              section.arabicLabel,
              style: TextStyle(
                color: selected ? accent : colors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _BottomNav was lifted to lib/core/widgets/app_bottom_nav.dart so the inbox /
// profile / mirrors pages can use the same nav for a consistent tab experience.

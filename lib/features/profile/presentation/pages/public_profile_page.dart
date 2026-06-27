import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/report_sheet.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../feed/presentation/widgets/post_card_skeleton.dart';
import '../providers/profile_provider.dart';
import '../widgets/anon_ask_form.dart';
import '../widgets/profile_share.dart';

class PublicProfilePage extends ConsumerWidget {
  const PublicProfilePage({super.key, required this.username});
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final profile = ref.watch(publicProfileProvider(username));
    return Scaffold(
      backgroundColor: colors.background,
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: ErrorView(
            message: e.toString(),
            onRetry: () =>
                ref.invalidate(publicProfileProvider(username)),
          ),
        ),
        data: (p) => _Body(profile: p, username: username),
      ),
    );
  }
}

Future<void> _onMenu(
  BuildContext context,
  WidgetRef ref,
  PublicProfileDto profile,
  String v,
) async {
  final l = AppLocalizations.of(context);
  if (v == 'block') {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.profileBlockUser),
        content: Text(
          l.profileBlockUserBody,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(l.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error),
            child: Text(l.profileBlock),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(profileRepositoryProvider).block(profile.user.id);
      Fluttertoast.showToast(msg: l.profileBlocked);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (_) {
      Fluttertoast.showToast(msg: l.profileBlockFailed);
    }
  } else if (v == 'report') {
    await ReportSheet.show(context,
        target: ReportTarget.user, targetId: profile.user.id);
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.profile, required this.username});
  final PublicProfileDto profile;
  final String username;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
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
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) {
      final tab = ref.read(selectedProfileTabProvider(widget.username));
      ref
          .read(
            profilePostsProvider(ProfilePostsKey.make(widget.username, tab))
                .notifier,
          )
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final profile = widget.profile;
    final username = widget.username;
    final tab = ref.watch(selectedProfileTabProvider(username));
    final posts = ref.watch(profilePostsProvider(
        ProfilePostsKey.make(username, tab)));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(publicProfileProvider(username));
        ref.invalidate(profilePostsProvider(
            ProfilePostsKey.make(username, tab)));
      },
      color: colors.moment,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.surface,
            foregroundColor: colors.textPrimary,
            elevation: 0,
            title: Text('@${profile.user.username}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: l.profileShareThis,
                onPressed: () => shareProfile(
                  context,
                  username: profile.user.username,
                  displayName: profile.user.displayName,
                ),
              ),
              if (!profile.isSelf)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: colors.textPrimary),
                  onSelected: (v) => _onMenu(context, ref, profile, v),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'block',
                      child: Row(children: [
                        const Icon(Icons.block, size: 18),
                        const SizedBox(width: 8),
                        Text(l.profileBlockUser),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'report',
                      child: Row(children: [
                        const Icon(Icons.flag_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l.profileReport),
                      ]),
                    ),
                  ],
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: _Header(profile: profile),
          ),
          if (!profile.isSelf)
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: AnonAskForm(username: username),
              ),
            ),
          SliverToBoxAdapter(
            child: _TabsBar(
              username: username,
              current: tab,
              onPick: (t) =>
                  ref.read(selectedProfileTabProvider(username).notifier).state = t,
            ),
          ),
          posts.when(
            loading: () => const SliverToBoxAdapter(
              child: Column(children: [
                PostCardSkeleton(),
                PostCardSkeleton(),
              ]),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorView(message: e.toString()),
            ),
            data: (state) {
              if (state.posts.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        l.profileNothingHere,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: state.posts.length + (state.reachedEnd ? 0 : 1),
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
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.profile});
  final PublicProfileDto profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return Column(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: profile.user.coverColor != null
                ? _parseHex(profile.user.coverColor!) ?? colors.moment
                : colors.moment.withValues(alpha: 0.15),
            image: profile.user.coverPath != null
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      mediaUrl(profile.user.coverPath) ?? '',
                    ),
                  )
                : null,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -34),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppAvatar(
                      url: mediaUrl(profile.user.avatarPath),
                      initials: profile.user.displayName,
                      size: 76,
                      ringColor: colors.background,
                      ringWidth: 3,
                    ),
                    const Spacer(),
                    if (!profile.isSelf)
                      _FollowButton(profile: profile)
                    else
                      AppButton(
                        label: l.profileEditTitle,
                        variant: AppButtonVariant.secondary,
                        expand: false,
                        // Own profile edit lives in /profile (the private
                        // route) — push so back returns to the public view.
                        onPressed: () => context.push('/profile'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.user.displayName,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile.verified) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified, size: 18, color: colors.face),
                    ],
                  ],
                ),
                Text(
                  '@${profile.user.username}',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                if ((profile.user.bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    profile.user.bio!,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _Stats(stats: profile.stats),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.stats});
  final ProfileStatsDto stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    Widget cell(String label, int value, [Color? color]) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color ?? colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        cell(l.profileFollowers, stats.followers),
        cell(l.profileFollowingStat, stats.following),
        cell(l.profileTabCrystalsShort, stats.crystals, colors.crystal),
        cell(l.profileTabActiveShort, stats.active, colors.moment),
        cell(l.profileBadgeMirrors, stats.mirrors, colors.mind),
      ],
    );
  }
}

class _FollowButton extends ConsumerStatefulWidget {
  const _FollowButton({required this.profile});
  final PublicProfileDto profile;

  @override
  ConsumerState<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<_FollowButton> {
  late bool _following = widget.profile.isFollowing;
  bool _busy = false;

  Future<void> _toggle() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final repo = ref.read(profileRepositoryProvider);
    try {
      if (_following) {
        await repo.unfollow(widget.profile.user.id);
      } else {
        await repo.follow(widget.profile.user.id);
      }
      setState(() => _following = !_following);
    } catch (_) {
      Fluttertoast.showToast(msg: l.profileActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppButton(
      label: _following ? l.profileFollowingState : l.profileFollowAction,
      variant:
          _following ? AppButtonVariant.secondary : AppButtonVariant.primary,
      expand: false,
      onPressed: _toggle,
      loading: _busy,
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({
    required this.username,
    required this.current,
    required this.onPick,
  });
  final String username;
  final ProfileTab current;
  final ValueChanged<ProfileTab> onPick;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final tabs = [
      (ProfileTab.active, l.profileTabActiveShort, Icons.flash_on_outlined),
      (ProfileTab.moments, l.profileTabMoments, Icons.bolt_outlined),
      (ProfileTab.answers, l.profileTabAnswers, Icons.question_answer_outlined),
      (ProfileTab.crystals, l.profileTabCrystalsShort, Icons.diamond_outlined),
      (ProfileTab.likes, l.profileTabLikesShort, Icons.favorite_border),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: tabs.map((t) {
          final selected = t.$1 == current;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () => onPick(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? colors.moment.withValues(alpha: 0.12)
                                  : colors.elevated,
                  border: Border.all(
                    color: selected ? colors.moment : colors.border,
                    width: selected ? 1.2 : 0.6,
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.$3,
                      size: 14,
                      color: selected ? colors.moment : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.$2,
                      style: TextStyle(
                        color: selected ? colors.moment : colors.textSecondary,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Color? _parseHex(String s) {
  final v = s.replaceFirst('#', '');
  if (v.length == 6) {
    final n = int.tryParse('FF$v', radix: 16);
    return n == null ? null : Color(n);
  }
  if (v.length == 8) {
    final n = int.tryParse(v, radix: 16);
    return n == null ? null : Color(n);
  }
  return null;
}

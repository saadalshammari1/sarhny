import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../feed/presentation/widgets/post_card_skeleton.dart';
import '../providers/profile_provider.dart';
import '../widgets/anon_ask_form.dart';

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
  if (v == 'block') {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('حظر هذا المستخدم'),
        content: const Text(
          'لن تستقبل أي رسائل أو منشورات منه، ولن يراك أيضاً. تستطيع إلغاء الحظر لاحقاً من شاشة الإعدادات.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error),
            child: const Text('حظر'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(profileRepositoryProvider).block(profile.user.id);
      Fluttertoast.showToast(msg: 'تم الحظر');
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الحظر');
    }
  } else if (v == 'report') {
    Fluttertoast.showToast(msg: 'تم إرسال البلاغ — سنراجعه');
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.profile, required this.username});
  final PublicProfileDto profile;
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
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
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.surface,
            foregroundColor: colors.textPrimary,
            elevation: 0,
            title: Text('@${profile.user.username}'),
            actions: [
              if (!profile.isSelf)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: colors.textPrimary),
                  onSelected: (v) => _onMenu(context, ref, profile, v),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'block',
                      child: Row(children: [
                        Icon(Icons.block, size: 18),
                        SizedBox(width: 8),
                        Text('حظر هذا المستخدم'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'report',
                      child: Row(children: [
                        Icon(Icons.flag_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('إبلاغ'),
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
            data: (page) {
              if (page.posts.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'لا يوجد شيء هنا بعد',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: page.posts.length,
                itemBuilder: (_, i) => PostCard(post: page.posts[i]),
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
                        label: 'تعديل البروفايل',
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
        cell('متابعون', stats.followers),
        cell('متابَعون', stats.following),
        cell('متبلور', stats.crystals, colors.crystal),
        cell('نشط', stats.active, colors.moment),
        cell('مرايا', stats.mirrors, colors.mind),
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
      Fluttertoast.showToast(msg: 'تعذّر تنفيذ الطلب');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _following ? 'تتابعه' : 'تابع',
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
    final colors = context.sarhnyColors;
    final tabs = [
      (ProfileTab.active, 'نشط', Icons.flash_on_outlined),
      (ProfileTab.crystals, 'متبلور', Icons.diamond_outlined),
      (ProfileTab.likes, 'إعجابات', Icons.favorite_border),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: tabs.map((t) {
          final selected = t.$1 == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPick(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      t.$3,
                      size: 14,
                      color:
                          selected ? colors.textPrimary : colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.$2,
                      style: TextStyle(
                        color: selected
                            ? colors.textPrimary
                            : colors.textSecondary,
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

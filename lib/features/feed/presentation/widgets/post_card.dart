import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/relative_time.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/report_sheet.dart';
import '../../../post/presentation/providers/interaction_provider.dart';
import '../../../post/presentation/providers/post_provider.dart';

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, this.tappable = true});
  final PostDto post;
  /// When false, the card renders as a static block — no whole-card InkWell
  /// that pushes /post/X. Use `false` on the post detail page itself so
  /// tapping the header doesn't push the same post onto the stack again.
  final bool tappable;

  PostSection get _section => switch (post.section) {
        PostSectionKind.moment => PostSection.moment,
        PostSectionKind.face => PostSection.face,
        PostSectionKind.mind => PostSection.mind,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final brightness = Theme.of(context).brightness;
    final sectionColor = _section.resolve(brightness);
    final sectionInk = _section.ink(brightness);

    // Push the server's truth about this viewer's like/save state into the
    // in-memory controller exactly once per render. seed() is a no-op if the
    // user has already toggled locally.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ref
          .read(postInteractionProvider(post.id).notifier)
          .seed(liked: post.isLiked, saved: post.isSaved);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: tappable ? () => context.push('/post/${post.id}') : null,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border, width: 0.6),
              boxShadow: colors.cardShadow,
            ),
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sectionColor,
                    sectionColor.withValues(alpha: 0.75),
                  ],
                ),
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(20),
                  bottomStart: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      post: post,
                      sectionColor: sectionColor,
                      sectionInk: sectionInk,
                    ),
                    if (post.originQuestion != null) ...[
                      const SizedBox(height: 10),
                      _OriginQuestion(
                        q: post.originQuestion!,
                        moment: colors.moment,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      post.body,
                      style: context.textStyles.bodyMedium?.copyWith(
                        height: 1.55,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Footer(post: post, colors: colors),
                    if (!post.isCrystallized && post.decayDeadline != null) ...[
                      const SizedBox(height: 8),
                      _LifeBar(
                        deadline: post.decayDeadline!,
                        gravityScore: post.gravityScore,
                        colors: colors,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.post,
    required this.sectionColor,
    required this.sectionInk,
  });
  final PostDto post;
  final Color sectionColor;
  final Color sectionInk;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final hideSectionBadge = post.originQuestion != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/u/${post.author.username}'),
          child: AppAvatar(
            url: mediaUrl(post.author.avatarPath),
            initials: (post.author.displayName ?? post.author.username),
            size: 38,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.author.displayName ?? post.author.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (post.author.verified) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.verified, size: 14, color: colors.face),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '@${post.author.username}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(' · ',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  Text(
                    formatRelative(context, post.createdAt),
                    style:
                        TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  if (!hideSectionBadge) ...[
                    Text(' · ',
                        style: TextStyle(color: sectionInk, fontSize: 12)),
                    Text(
                      '${switch (post.section) {
                        PostSectionKind.moment => '⚡',
                        PostSectionKind.face => '🎨',
                        PostSectionKind.mind => '🧠',
                      }} ${switch (post.section) {
                        PostSectionKind.moment => l.feedSectionMoment,
                        PostSectionKind.face => l.feedSectionFace,
                        PostSectionKind.mind => l.feedSectionMind,
                      }}',
                      style: TextStyle(color: sectionInk, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (post.isCrystallized)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.crystal.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              l.feedCrystalBadge,
              style: TextStyle(
                color: colors.crystal,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

/// Thin "life bar" rendered along the bottom of every non-crystallized post.
/// Width decays toward zero as the post approaches its decay_deadline, but
/// engagement (gravity_score) lifts the bar back up — so an actively
/// engaging post stays bright while a stale one fades away to a sliver.
/// Replaces the previous hourglass-icon badge: the user wanted an
/// always-visible underline that decays visibly.
class _LifeBar extends StatefulWidget {
  const _LifeBar({
    required this.deadline,
    required this.gravityScore,
    required this.colors,
  });
  final String deadline;
  final double gravityScore;
  final SarhnyColors colors;

  @override
  State<_LifeBar> createState() => _LifeBarState();
}

class _LifeBarState extends State<_LifeBar> {
  Timer? _ticker;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _deadline =
        DateTime.tryParse(widget.deadline.replaceAll(' ', 'T'))?.toLocal();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dl = _deadline;
    if (dl == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final remaining = dl.difference(now);
    final timeFraction =
        remaining.isNegative ? 0.0 : (remaining.inMinutes / (24 * 60)).clamp(0.0, 1.0);
    // Engagement lift: gravity 0 → no lift, gravity >= 75 (≈ crystallization
    // threshold for the face section) → full bar regardless of time.
    final engagementFraction = (widget.gravityScore / 75).clamp(0.0, 1.0);
    final progress = math.max(timeFraction, engagementFraction);
    final expired = progress <= 0;
    final c = widget.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * progress;
        return Stack(
          children: [
            // Faint base rail so the position of the bar is readable even
            // when it's almost empty.
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 3,
              width: width,
              decoration: BoxDecoration(
                color: expired
                    ? c.textSecondary.withValues(alpha: 0.4)
                    : c.crystal,
                borderRadius: BorderRadius.circular(99),
                boxShadow: expired
                    ? null
                    : [
                        BoxShadow(
                          color: c.crystal
                              .withValues(alpha: 0.45 * progress),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OriginQuestion extends StatelessWidget {
  const _OriginQuestion({required this.q, required this.moment});
  final OriginQuestionDto q;
  final Color moment;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: moment.withValues(alpha: 0.06),
        border: Border.all(color: moment.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_off_outlined,
                  size: 12, color: moment),
              const SizedBox(width: 4),
              Text(
                q.senderHidden || q.senderUsername == null
                    ? l.feedQuestionFromAnonymous
                    : '${l.feedQuestionFrom} @${q.senderUsername}',
                style: TextStyle(
                  color: moment,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q.questionText,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.post, required this.colors});
  final PostDto post;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final inter = ref.watch(postInteractionProvider(post.id));
    final repo = ref.read(postRepositoryProvider);
    // Author check — compared by username because legacy `userId` and
    // V2 `author.id` live in different keyspaces. Username is unique
    // and stable across both.
    final myUsername = ref.watch(authStateProvider).valueOrNull?.username;
    final isMine =
        myUsername != null && post.author.username == myUsername;
    final heartColor = inter.liked
        ? const Color(0xFFE2685A)
        : colors.textSecondary;
    final bookmarkColor =
        inter.saved ? colors.crystal : colors.textSecondary;
    return Row(
      children: [
        _InteractiveStat(
          icon: inter.liked ? Icons.favorite : Icons.favorite_border,
          label: '${post.likesCount + inter.likeDelta}',
          color: heartColor,
          onTap: inter.likeBusy
              ? null
              : () => ref
                  .read(postInteractionProvider(post.id).notifier)
                  .toggleLike(repo),
          pulse: inter.liked,
        ),
        const SizedBox(width: 16),
        // Unified replies count (post 3.3.6 merge of anonymous + comments).
        // Always show, even when zero, so users see an explicit invitation
        // to engage instead of a missing icon.
        _InteractiveStat(
          icon: Icons.forum_outlined,
          label: '${post.anonRepliesCount}',
          color: colors.textSecondary,
          onTap: () => context.push('/post/${post.id}'),
        ),
        const Spacer(),
        _IconButton(
          icon: inter.saved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: bookmarkColor,
          tooltip: inter.saved ? l.feedUnsave : l.feedSave,
          onTap: inter.saveBusy
              ? null
              : () => ref
                  .read(postInteractionProvider(post.id).notifier)
                  .toggleSave(repo),
        ),
        const SizedBox(width: 4),
        _IconButton(
          icon: Icons.ios_share_rounded,
          color: colors.textSecondary,
          tooltip: l.commonShare,
          onTap: () => _share(context, post),
        ),
        const SizedBox(width: 2),
        // Author-only delete. Lives next to Report so non-authors see
        // Report there; authors see Delete instead — same slot, no
        // shifting layout when ownership toggles.
        if (isMine)
          _IconButton(
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFFD22F2F),
            tooltip: l.commonDelete,
            onTap: () => _confirmDelete(context, ref, post, repo),
          )
        else
          _IconButton(
            icon: Icons.flag_outlined,
            color: colors.textSecondary,
            tooltip: l.commonReport,
            onTap: () => ReportSheet.show(
              context,
              target: ReportTarget.post,
              targetId: post.id,
            ),
          ),
      ],
    );
  }

  Future<void> _share(BuildContext context, PostDto p) async {
    final l = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    // Canonical web URL is locale-prefixed (next-intl middleware
    // forces it). `/post/X` would 308 to `/ar/post/X` anyway — sending
    // the canonical form skips a redirect hop.
    final url = 'https://sarhny.com/ar/post/${p.id}';
    final body = p.body.length > 120 ? '${p.body.substring(0, 117)}…' : p.body;
    await Share.share(
      '$body\n\n${l.feedShareFooter}\n$url',
      subject: l.appName,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PostDto p,
    dynamic repo,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.feedDeleteTitle),
        content: Text(
          l.feedDeleteBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD22F2F),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await repo.deletePost(p.id);
      Fluttertoast.showToast(msg: l.feedDeleteSuccess);
      // If we were on the detail page, pop back to wherever brought us
      // here so the now-deleted post doesn't linger on screen.
      if (context.mounted) {
        if (context.canPop()) {
          context.pop();
        }
      }
    } catch (_) {
      Fluttertoast.showToast(msg: l.feedDeleteFailed);
    }
  }
}

class _InteractiveStat extends StatelessWidget {
  const _InteractiveStat({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.pulse = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool pulse;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color)
                .animate(target: pulse ? 1 : 0)
                .scaleXY(begin: 1.0, end: 1.25, duration: 120.ms)
                .then()
                .scaleXY(begin: 1.25, end: 1.0, duration: 120.ms),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}


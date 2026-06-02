import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../post/presentation/providers/interaction_provider.dart';
import '../../../post/presentation/providers/post_provider.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});
  final PostDto post;

  PostSection get _section => switch (post.section) {
        PostSectionKind.moment => PostSection.moment,
        PostSectionKind.face => PostSection.face,
        PostSectionKind.mind => PostSection.mind,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final brightness = Theme.of(context).brightness;
    final sectionColor = _section.resolve(brightness);
    final sectionInk = _section.ink(brightness);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/post/${post.id}'),
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
                    _formatRelative(post.createdAt),
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
                        PostSectionKind.moment => 'لحظات',
                        PostSectionKind.face => 'صور',
                        PostSectionKind.mind => 'أفكار',
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
              '✦ متبلور',
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

class _OriginQuestion extends StatelessWidget {
  const _OriginQuestion({required this.q, required this.moment});
  final OriginQuestionDto q;
  final Color moment;

  @override
  Widget build(BuildContext context) {
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
                    ? 'سؤال من مجهول'
                    : 'سؤال من @${q.senderUsername}',
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
    final inter = ref.watch(postInteractionProvider(post.id));
    final repo = ref.read(postRepositoryProvider);
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
        _InteractiveStat(
          icon: Icons.chat_bubble_outline,
          label: '${post.commentsCount}',
          color: colors.textSecondary,
          onTap: () => context.push('/post/${post.id}'),
        ),
        if (post.anonRepliesCount > 0) ...[
          const SizedBox(width: 16),
          _InteractiveStat(
            icon: Icons.visibility_off_outlined,
            label: '${post.anonRepliesCount}',
            color: colors.moment,
            onTap: () => context.push('/post/${post.id}'),
          ),
        ],
        const Spacer(),
        _IconButton(
          icon: inter.saved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: bookmarkColor,
          tooltip: inter.saved ? 'إلغاء الحفظ' : 'حفظ',
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
          tooltip: 'مشاركة',
          onTap: () => _share(context, post),
        ),
      ],
    );
  }

  Future<void> _share(BuildContext context, PostDto p) async {
    final box = context.findRenderObject() as RenderBox?;
    final url = 'https://sarhny.com/post/${p.id}';
    final body = p.body.length > 120 ? '${p.body.substring(0, 117)}…' : p.body;
    await Share.share(
      '$body\n\n— من صارحني\n$url',
      subject: 'صارحني',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
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

String _formatRelative(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final delta = DateTime.now().toUtc().difference(dt.toUtc());
  if (delta.inMinutes < 1) return 'الآن';
  if (delta.inMinutes < 60) return 'قبل ${delta.inMinutes} د';
  if (delta.inHours < 24) return 'قبل ${delta.inHours} س';
  if (delta.inDays < 7) return 'قبل ${delta.inDays} يوم';
  return intl.DateFormat('d MMM', 'ar').format(dt.toLocal());
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../data/comment_dto.dart';
import '../providers/post_provider.dart';

class CommentsSection extends ConsumerStatefulWidget {
  const CommentsSection({super.key, required this.postId});
  final int postId;

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final c =
          await ref.read(postRepositoryProvider).createComment(widget.postId, txt);
      await ref
          .read(commentsControllerProvider(widget.postId).notifier)
          .add(c);
      _ctrl.clear();
      Fluttertoast.showToast(msg: 'تم النشر');
    } on UnauthorizedException {
      Fluttertoast.showToast(msg: 'سجّل دخولك للتعليق');
    } on ValidationException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر النشر');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final state = ref.watch(commentsControllerProvider(widget.postId));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.chat_bubble_outline,
                color: colors.textSecondary, size: 18),
            const SizedBox(width: 6),
            Text(
              'التعليقات',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            state.when(
              data: (s) => Text(
                '${s.comments.length}',
                style:
                    TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              loading: () => const SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              error: (_, __) => const SizedBox(),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'اكتب تعليقاً…',
                      hintStyle: TextStyle(color: colors.textSecondary),
                      isCollapsed: true,
                    ),
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 1.6),
                        )
                      : Icon(Icons.send_rounded, color: colors.moment),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          state.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'تعذّر تحميل التعليقات',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            ),
            data: (s) {
              if (s.comments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'كن أول من يعلّق',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                );
              }
              return Column(children: [
                for (final c in s.comments)
                  _CommentTile(comment: c, colors: colors),
                if (!s.reachedEnd)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () => ref
                          .read(commentsControllerProvider(widget.postId)
                              .notifier)
                          .loadMore(),
                      child: Text(
                        s.loadingMore ? 'جارٍ التحميل…' : 'تحميل المزيد',
                        style: TextStyle(color: colors.moment),
                      ),
                    ),
                  ),
              ]);
            },
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.colors});
  final CommentDto comment;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final hasAuthor = !comment.isAnonymous && comment.author != null;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 0.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAuthor)
            GestureDetector(
              onTap: () => context.push('/u/${comment.author!.username}'),
              child: AppAvatar(
                url: mediaUrl(comment.author!.avatarPath),
                initials: comment.author!.displayName ??
                    comment.author!.username,
                size: 30,
              ),
            )
          else
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.person_outline,
                  size: 16, color: colors.textSecondary),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAuthor
                      ? (comment.author!.displayName ??
                          '@${comment.author!.username}')
                      : 'مجهول',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.body,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

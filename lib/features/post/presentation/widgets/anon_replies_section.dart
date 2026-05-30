import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/post_provider.dart';

class AnonRepliesSection extends ConsumerStatefulWidget {
  const AnonRepliesSection({super.key, required this.postId});
  final int postId;

  @override
  ConsumerState<AnonRepliesSection> createState() =>
      _AnonRepliesSectionState();
}

class _AnonRepliesSectionState extends ConsumerState<AnonRepliesSection> {
  final _msgCtrl = TextEditingController();
  bool _hidden = true;
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final reply =
          await ref.read(postRepositoryProvider).createAnonReply(
                widget.postId,
                message: text,
                senderHidden: _hidden,
              );
      await ref
          .read(anonRepliesControllerProvider(widget.postId).notifier)
          .add(reply);
      _msgCtrl.clear();
      Fluttertoast.showToast(msg: 'تم الإرسال 🌙');
    } on ValidationException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } on UnauthorizedException {
      Fluttertoast.showToast(msg: 'سجّل دخولك للرد');
    } on RateLimitException {
      Fluttertoast.showToast(msg: 'تمهّل قليلاً قبل الإرسال');
    } catch (e) {
      Fluttertoast.showToast(msg: 'تعذّر الإرسال');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final state = ref.watch(anonRepliesControllerProvider(widget.postId));
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
          Row(
            children: [
              Icon(Icons.visibility_off_outlined,
                  color: colors.moment, size: 18),
              const SizedBox(width: 6),
              Text(
                'ردود مجهولة',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              state.when(
                data: (s) => Text(
                  '${s.replies.length}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                loading: () => const SizedBox(
                  width: 12, height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Composer(
            controller: _msgCtrl,
            hidden: _hidden,
            onToggle: (v) => setState(() => _hidden = v),
            onSend: _send,
            sending: _sending,
            colors: colors,
          ),
          const SizedBox(height: 12),
          state.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'تعذّر تحميل الردود',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            ),
            data: (s) {
              if (s.replies.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'لا توجد ردود بعد. كن أوّل من يفتح حواراً 🌙',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final r in s.replies)
                    _ReplyTile(reply: r, colors: colors),
                  if (!s.reachedEnd)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () => ref
                            .read(anonRepliesControllerProvider(widget.postId)
                                .notifier)
                            .loadMore(),
                        child: Text(
                          s.loadingMore ? 'جارٍ التحميل…' : 'تحميل المزيد',
                          style: TextStyle(color: colors.moment),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hidden,
    required this.onToggle,
    required this.onSend,
    required this.sending,
    required this.colors,
  });
  final TextEditingController controller;
  final bool hidden;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSend;
  final bool sending;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLength: 600,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'اكتب ردك…',
              hintStyle: TextStyle(color: colors.textSecondary),
              counterText: '',
              isCollapsed: true,
            ),
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () => onToggle(!hidden),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hidden
                        ? colors.moment.withValues(alpha: 0.12)
                        : Colors.transparent,
                    border: Border.all(
                      color: hidden ? colors.moment : colors.border,
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 14,
                        color:
                            hidden ? colors.moment : colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hidden ? 'مجهول' : 'باسمي',
                        style: TextStyle(
                          color: hidden ? colors.moment : colors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'إرسال',
                expand: false,
                loading: sending,
                onPressed: onSend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.reply, required this.colors});
  final AnonReplyDto reply;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final senderRevealed =
        !reply.isSenderHidden && reply.sender != null;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 0.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (senderRevealed)
            GestureDetector(
              onTap: () => context.push('/u/${reply.sender!.username}'),
              child: AppAvatar(
                url: mediaUrl(reply.sender!.avatarPath),
                initials: reply.sender!.displayName ??
                    reply.sender!.username,
                size: 32,
              ),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.moment.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.visibility_off_outlined,
                  size: 16, color: colors.moment),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderRevealed
                      ? '@${reply.sender!.username}'
                      : 'مجهول',
                  style: TextStyle(
                    color: senderRevealed
                        ? colors.textPrimary
                        : colors.moment,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (reply.message != null && reply.message!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reply.message!,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

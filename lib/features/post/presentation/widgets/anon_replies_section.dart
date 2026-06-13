import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart' as audio;

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/utils/media.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../providers/post_provider.dart';
import 'media_composer.dart';

class AnonRepliesSection extends ConsumerStatefulWidget {
  const AnonRepliesSection({super.key, required this.postId});
  final int postId;

  @override
  ConsumerState<AnonRepliesSection> createState() =>
      _AnonRepliesSectionState();
}

class _AnonRepliesSectionState extends ConsumerState<AnonRepliesSection> {
  // Default to "باسمي" — anonymity is opt-in via the chip on the right of the
  // composer. Previously defaulted to hidden, which conflated with the old
  // separate Comments box.
  bool _hidden = false;

  Future<bool> _handleSend(ComposedMedia m) async {
    try {
      final reply =
          await ref.read(postRepositoryProvider).createAnonReply(
                widget.postId,
                message: m.message ?? '',
                senderHidden: _hidden,
                mediaType: m.mediaType,
                mediaRef: m.mediaRef,
              );
      await ref
          .read(anonRepliesControllerProvider(widget.postId).notifier)
          .add(reply);
      Fluttertoast.showToast(msg: 'تم الإرسال 🌙');
      return true;
    } on UnauthorizedException {
      Fluttertoast.showToast(msg: 'سجّل دخولك للرد');
      return false;
    } on ValidationException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      return false;
    } on RateLimitException {
      Fluttertoast.showToast(msg: 'تمهّل قليلاً قبل الإرسال');
      return false;
    } on ApiException catch (e) {
      // Surface real reasons (e.g. 402 رصيد الانتباه غير كافٍ) instead of a
      // generic toast, which is what was masking failed sends.
      Fluttertoast.showToast(msg: e.message);
      return false;
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الإرسال');
      return false;
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
              Icon(Icons.forum_outlined,
                  color: colors.moment, size: 18),
              const SizedBox(width: 6),
              Text(
                'الردود',
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
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MediaComposer(
            placeholder: 'اكتب ردّك…',
            onSend: _handleSend,
            hiddenSwitch: _HiddenChip(
              hidden: _hidden,
              onTap: () => setState(() => _hidden = !_hidden),
              colors: colors,
            ),
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

class _HiddenChip extends StatelessWidget {
  const _HiddenChip({
    required this.hidden,
    required this.onTap,
    required this.colors,
  });
  final bool hidden;
  final VoidCallback onTap;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              size: 13,
              color: hidden ? colors.moment : colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              hidden ? 'مجهول' : 'باسمي',
              style: TextStyle(
                color: hidden ? colors.moment : colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
    final senderRevealed = !reply.isSenderHidden && reply.sender != null;
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
                initials: reply.sender!.displayName ?? reply.sender!.username,
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
                  senderRevealed ? '@${reply.sender!.username}' : 'مجهول',
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
                if (reply.mediaType == 'voice' && reply.mediaRef != null) ...[
                  const SizedBox(height: 6),
                  _VoiceBubble(url: mediaUrl(reply.mediaRef), colors: colors),
                ],
                if (reply.mediaType == 'image' && reply.mediaRef != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      mediaUrl(reply.mediaRef) ?? '',
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 60,
                        color: colors.elevated,
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image,
                            color: colors.textSecondary),
                      ),
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

class _VoiceBubble extends StatefulWidget {
  const _VoiceBubble({required this.url, required this.colors});
  final String? url;
  final SarhnyColors colors;
  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  final _player = audio.AudioPlayer();
  bool _ready = false;
  bool _playing = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.url == null) return;
    try {
      await _player.setUrl(widget.url!);
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _pos = p);
      });
      _player.durationStream.listen((d) {
        if (mounted) setState(() => _dur = d ?? Duration.zero);
      });
      _player.playerStateStream.listen((s) {
        if (mounted) setState(() => _playing = s.playing);
      });
      if (mounted) setState(() => _ready = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final progress = _dur.inMilliseconds == 0
        ? 0.0
        : (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.moment.withValues(alpha: 0.08),
        border: Border.all(color: c.moment.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: !_ready
                ? null
                : () async {
                    if (_playing) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                  },
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.moment,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: c.moment.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(c.moment),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_pos.inSeconds}/${_dur.inSeconds == 0 ? '?' : _dur.inSeconds}',
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

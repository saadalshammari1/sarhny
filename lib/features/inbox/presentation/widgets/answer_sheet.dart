import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/api/dto.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/inbox_provider.dart';

class AnswerSheet extends ConsumerStatefulWidget {
  const AnswerSheet({super.key, required this.item});
  final InboxItemDto item;

  @override
  ConsumerState<AnswerSheet> createState() => _AnswerSheetState();
}

class _AnswerSheetState extends ConsumerState<AnswerSheet> {
  final _bodyCtrl = TextEditingController();
  final _layer3Ctrl = TextEditingController();
  bool _showLayer3 = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Live rebuild as the user types so the "publish" button enables.
    _bodyCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _bodyCtrl.removeListener(_onChanged);
    _bodyCtrl.dispose();
    _layer3Ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_error != null) setState(() => _error = null);
    setState(() {});
  }

  bool get _canSubmit =>
      _bodyCtrl.text.trim().isNotEmpty && !_sending;

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) {
      setState(() => _error = l.inboxAnswerEmptyError);
      return;
    }
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final postId = await ref.read(inboxRepositoryProvider).answer(
            widget.item.id,
            body: body,
            layer3: _showLayer3 ? _layer3Ctrl.text.trim() : null,
          );
      ref
          .read(inboxControllerProvider(ref.read(inboxFilterProvider))
              .notifier)
          .removeLocal(widget.item.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: l.inboxReplyPublished);
      if (postId > 0) context.push('/post/$postId');
    } on ValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on UnauthorizedException {
      if (mounted) setState(() => _error = l.inboxSessionExpired);
    } on RateLimitException {
      if (mounted) setState(() => _error = l.inboxRateLimited);
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _error =
            '${l.inboxConnectionFailed} ${e.response?.statusCode ?? e.type.name}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = '${l.errorUnexpected}: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle + close button
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: l.commonClose,
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // balance the close icon width
              ],
            ),
            const SizedBox(height: 6),
            // The message + reply fields scroll, while the publish button below
            // stays pinned. Without this, a long incoming message plus the
            // keyboard pushed the button off-screen with no way to reach it.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.moment.withValues(alpha: 0.06),
                        border: Border.all(
                            color: colors.moment.withValues(alpha: 0.25)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.visibility_off_outlined,
                              size: 14, color: colors.moment),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.item.message,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.inboxYourReplyLabel,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _bodyCtrl,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: 2000,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l.inboxReplyHint,
                        counterText: '${_bodyCtrl.text.length}/2000',
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _showLayer3 = !_showLayer3),
                          icon: Icon(
                            _showLayer3
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline,
                            size: 16,
                          ),
                          label: Text(_showLayer3
                              ? l.inboxHideLayer3
                              : l.inboxAddLayer3),
                        ),
                      ],
                    ),
                    if (_showLayer3)
                      TextField(
                        controller: _layer3Ctrl,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 4000,
                        decoration:
                            InputDecoration(hintText: l.inboxLayer3Hint),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.danger.withValues(alpha: 0.10),
                          border: Border.all(
                              color: colors.danger.withValues(alpha: 0.30)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Icon(Icons.error_outline,
                              color: colors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                  color: colors.danger, fontSize: 13),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l.inboxPublishReply,
              onPressed: _canSubmit ? _send : null,
              loading: _sending,
            ),
          ],
        ),
      ),
    );
  }
}

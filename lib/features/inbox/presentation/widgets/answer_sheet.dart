import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _layer3Ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
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
      Fluttertoast.showToast(msg: 'تم نشر الرد ✨');
      context.push('/post/$postId');
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
            Center(
              child: Container(
                width: 36,
                height: 3,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.moment.withValues(alpha: 0.06),
                border:
                    Border.all(color: colors.moment.withValues(alpha: 0.25)),
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
              'ردك (سيُنشر كمنشور 🎨)',
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
              maxLength: 4000,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'اكتب ردك…'),
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
                      ? 'إخفاء الطبقة ٣'
                      : 'إضافة طبقة ٣ — تأمل'),
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
                    const InputDecoration(hintText: 'تأمّلك (اختياري)'),
              ),
            const SizedBox(height: 12),
            AppButton(
              label: 'نشر الرد',
              onPressed: _send,
              loading: _sending,
            ),
          ],
        ),
      ),
    );
  }
}

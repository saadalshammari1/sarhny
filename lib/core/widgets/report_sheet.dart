import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../app/localization/generated/app_localizations.dart';
import '../api/api_endpoints.dart';
import '../providers/api_providers.dart';

/// What we're reporting. The backend distinguishes by URL, but UX-wise we
/// only need to know "post or user" to render the right reasons.
enum ReportTarget { post, user }

/// Pre-baked reasons keep the report flow fast (one tap + optional notes).
/// Free-text "Other" lets the user write a custom reason.
List<String> _reasonsPost(AppLocalizations l) => <String>[
  l.reportReasonPostAbusive,
  l.reportReasonPostHarassment,
  l.reportReasonPostSexual,
  l.reportReasonPostRacism,
  l.reportReasonPostSpam,
  l.reportReasonPostPrivacy,
  l.reportReasonPostMisinfo,
  l.reportReasonOther,
];
List<String> _reasonsUser(AppLocalizations l) => <String>[
  l.reportReasonUserAbusive,
  l.reportReasonUserImpersonation,
  l.reportReasonUserScam,
  l.reportReasonUserMinors,
  l.reportReasonUserSpamMessages,
  l.reportReasonUserProfile,
  l.reportReasonOther,
];

class ReportSheet extends ConsumerStatefulWidget {
  const ReportSheet({
    super.key,
    required this.target,
    required this.targetId,
  });
  final ReportTarget target;
  final int targetId;

  /// Convenience launcher — call from any tap handler.
  static Future<void> show(
    BuildContext context, {
    required ReportTarget target,
    required int targetId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReportSheet(target: target, targetId: targetId),
      ),
    );
  }

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  String? _picked;
  final _noteCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final reasonBase = _picked;
    if (reasonBase == null) return;
    final isOther = reasonBase == l.reportReasonOther;
    final note = _noteCtrl.text.trim();
    if (isOther && note.length < 5) {
      Fluttertoast.showToast(msg: l.reportNeedClearReason);
      return;
    }
    setState(() => _sending = true);
    try {
      final reason = isOther
          ? note
          : (note.isEmpty ? reasonBase : '$reasonBase — $note');
      final dio = ref.read(dioClientProvider).raw;
      final form = FormData.fromMap(
        widget.target == ReportTarget.post
            ? {'report_post_id': widget.targetId, 'reason': reason}
            : {'report_user_id': widget.targetId, 'reason': reason},
      );
      final url = widget.target == ReportTarget.post
          ? ApiEndpoints.reportPost
          : ApiEndpoints.reportUser;
      final r = await dio.post<dynamic>(
        url,
        data: form,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      final ok = (r.data is Map) && (r.data as Map)['success'] == true;
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: l.reportReceived);
      } else {
        Fluttertoast.showToast(msg: l.reportSendFailed);
      }
    } catch (_) {
      Fluttertoast.showToast(msg: l.reportSendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reasons = widget.target == ReportTarget.post ? _reasonsPost(l) : _reasonsUser(l);
    final isOther = _picked == l.reportReasonOther;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Row(children: [
              Icon(Icons.flag_rounded, color: theme.colorScheme.error, size: 22),
              const SizedBox(width: 8),
              Text(
                widget.target == ReportTarget.post
                    ? l.reportTitlePost
                    : l.reportTitleUser,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              l.reportConfidentialNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            // RadioGroup wraps once and provides the groupValue/onChanged to
            // every RadioListTile child — the per-tile parameters were
            // deprecated in Flutter 3.32 and break --fatal-infos analyze runs.
            RadioGroup<String>(
              groupValue: _picked,
              onChanged: (v) => setState(() => _picked = v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final r in reasons)
                    RadioListTile<String>(
                      value: r,
                      title: Text(r, style: const TextStyle(fontSize: 14)),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              minLines: 2,
              maxLines: 4,
              maxLength: 250,
              decoration: InputDecoration(
                hintText: isOther
                    ? l.reportExplainBriefly
                    : l.reportExtraDetails,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _picked == null || _sending ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l.reportSubmit, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/localization/generated/app_localizations.dart';
import '../../app/theme/app_theme.dart';
import '../providers/storage_providers.dart';
import '../storage/prefs_storage.dart';

/// Smart "rate the app" flow that protects the store rating.
///
/// Instead of throwing the native review sheet at everyone (which surfaces
/// unhappy users straight to a 1-star box), we first ask a private satisfaction
/// question:
///   • "Loving it"  → trigger the native In-App Review sheet (App Store / Play).
///   • "Could be better" → open an in-app feedback box that emails us — the
///     complaint stays private and never becomes a public low rating.
///
/// Trigger policy (cheap to satisfy, hard to annoy):
///   • Only after the app has cold-started a few times ([_minOpens]).
///   • Once the user reacts (rates or sends feedback) we never ask again.
///   • "Later" snoozes for a few more opens instead of nagging.
class RateAppService {
  RateAppService(this._prefs);

  final PrefsStorage _prefs;

  static const int _minOpens = 3; // earliest open we'd ever ask on
  static const int _snoozeOpens = 4; // re-ask delay after "Later"
  static const String _feedbackEmail = 's.sarhny@gmail.com';

  bool get _eligible =>
      !_prefs.ratePromptDone &&
      _prefs.appOpens >= _minOpens &&
      _prefs.appOpens >= _prefs.rateNextEligibleOpen;

  /// Show the prompt if the policy allows. Safe to call on every landing —
  /// it self-gates. [context] must be mounted.
  Future<void> maybePrompt(BuildContext context) async {
    if (!_eligible) return;
    if (!context.mounted) return;

    final choice = await _askSatisfaction(context);
    switch (choice) {
      case _Sentiment.love:
        await _prefs.setRatePromptDone();
        await _requestStoreReview();
      case _Sentiment.meh:
        await _prefs.setRatePromptDone();
        if (context.mounted) await _collectFeedback(context);
      case _Sentiment.later:
      case null:
        await _prefs.setRateNextEligibleOpen(_prefs.appOpens + _snoozeOpens);
    }
  }

  Future<void> _requestStoreReview() async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    } catch (_) {
      // Never let a store-SDK hiccup bubble up into the UI.
    }
  }

  Future<void> _collectFeedback(BuildContext context) async {
    final text = await _askFeedback(context);
    if (text == null || text.trim().isEmpty) return;
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      query: _encodeQuery({
        'subject': 'Sarhny feedback',
        'body': text.trim(),
      }),
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {/* best-effort */}
    if (context.mounted) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.rateThanks)),
      );
    }
  }

  static String _encodeQuery(Map<String, String> params) => params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<_Sentiment?> _askSatisfaction(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    return showDialog<_Sentiment>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💜', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              l.rateEnjoyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Text(
          l.rateEnjoyBody,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 13.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(_Sentiment.love),
                  child: Text(l.rateLove),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(_Sentiment.meh),
                  child: Text(l.rateMeh),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(_Sentiment.later),
                child: Text(l.rateLater,
                    style: TextStyle(color: colors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _askFeedback(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.sarhnyColors;
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(l.rateFeedbackTitle,
            style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          minLines: 2,
          autofocus: true,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: l.rateFeedbackHint,
            hintStyle: TextStyle(color: colors.textSecondary),
            filled: true,
            fillColor: colors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.rateLater,
                style: TextStyle(color: colors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text(l.rateSend),
          ),
        ],
      ),
    );
  }
}

enum _Sentiment { love, meh, later }

final rateAppServiceProvider = Provider<RateAppService>((ref) {
  return RateAppService(ref.read(prefsStorageProvider));
});

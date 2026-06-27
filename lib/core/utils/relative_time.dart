import 'package:flutter/widgets.dart';

import '../../app/localization/generated/app_localizations.dart';

/// Localized relative time across the FULL ladder:
/// now → seconds → minutes → hours → days → weeks → months → years.
///
/// Timezone-safe: both sides are normalized to UTC before diffing, so a
/// backend timestamp parsed without an offset still reconciles correctly.
/// A future timestamp (clock skew) collapses to "now" rather than going
/// negative.
String formatRelative(BuildContext context, String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final l = AppLocalizations.of(context);
  final d = DateTime.now().toUtc().difference(dt.toUtc());
  final seconds = d.inSeconds;
  if (seconds < 5) return l.feedTimeNow;
  if (seconds < 60) return l.feedTimeSeconds(seconds);
  if (d.inMinutes < 60) return l.feedTimeMinutes(d.inMinutes);
  if (d.inHours < 24) return l.feedTimeHours(d.inHours);
  if (d.inDays < 7) return l.feedTimeDays(d.inDays);
  if (d.inDays < 30) return l.feedTimeWeeks(d.inDays ~/ 7);
  if (d.inDays < 365) return l.feedTimeMonths(d.inDays ~/ 30);
  return l.feedTimeYears(d.inDays ~/ 365);
}

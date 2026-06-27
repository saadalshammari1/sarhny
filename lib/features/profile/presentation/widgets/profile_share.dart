import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/generated/app_localizations.dart';

/// Share or copy a profile's public URL.
///
/// Order of preference:
/// 1. Native share sheet (iOS Share + Android `ACTION_SEND`) — gives the
///    user every messenger they already use (WhatsApp, X, SMS, email).
/// 2. Clipboard fallback when the share sheet is unavailable or the user
///    dismisses it.
///
/// [context] is needed to anchor the share-sheet on iPad (otherwise the
/// share dialog throws a "missing source rect" exception on tablet).
Future<void> shareProfile(
  BuildContext context, {
  required String username,
  required String displayName,
}) async {
  final l = AppLocalizations.of(context);
  final url = 'https://sarhny.com/u/$username';
  // Short, recognisable share text — readers see who, then the link.
  final text = '$displayName (@$username)\n$url\n\n— ${l.appName}';
  final box = context.findRenderObject() as RenderBox?;
  try {
    final result = await Share.share(
      text,
      subject: '${l.appName} — $displayName',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
    if (result.status == ShareResultStatus.dismissed) {
      // User backed out — still useful to leave the link in clipboard so
      // they can paste it manually wherever they meant to go.
      await Clipboard.setData(ClipboardData(text: url));
      Fluttertoast.showToast(msg: l.profileLinkCopied);
    }
  } catch (_) {
    // Share sheet completely unavailable — clipboard is the safety net.
    await Clipboard.setData(ClipboardData(text: url));
    Fluttertoast.showToast(msg: l.profileLinkCopied);
  }
}

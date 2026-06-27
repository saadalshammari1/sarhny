import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';

enum LegalKind { terms, privacy, contentPolicy }

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.kind});
  final LegalKind kind;

  String _title(AppLocalizations l) => switch (kind) {
        LegalKind.terms => l.settingsTerms,
        LegalKind.privacy => l.settingsPrivacyPolicy,
        LegalKind.contentPolicy => l.settingsContentPolicy,
      };

  String get _webUrl => switch (kind) {
        LegalKind.terms => 'https://sarhny.com/ar/terms',
        LegalKind.privacy => 'https://sarhny.com/ar/privacy',
        LegalKind.contentPolicy => 'https://sarhny.com/ar/content-policy',
      };

  String _summary(AppLocalizations l) => switch (kind) {
        LegalKind.terms => l.helpLegalTermsSummary,
        LegalKind.privacy => l.helpLegalPrivacySummary,
        LegalKind.contentPolicy => l.helpLegalContentSummary,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(_title(l))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 0.6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.moment, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.helpLegalLastUpdated,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _summary(l),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l.helpLegalReadFull),
            onPressed: () => launchUrl(
              Uri.parse(_webUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}

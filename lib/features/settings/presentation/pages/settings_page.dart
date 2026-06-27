import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/providers/app_settings_providers.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/subscription_repository.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final state = ref.watch(settingsStateProvider);
    final subState = ref.watch(subscriptionStateProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: RefreshIndicator(
        color: colors.moment,
        onRefresh: () async {
          ref.invalidate(settingsStateProvider);
          ref.invalidate(subscriptionStateProvider);
        },
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(settingsStateProvider),
          ),
          data: (s) {
            final account =
                (s['account'] as Map?)?.cast<String, dynamic>() ?? {};
            final privacy =
                (s['privacy'] as Map?)?.cast<String, dynamic>() ?? {};
            final notif =
                (s['notifications'] as Map?)?.cast<String, dynamic>() ?? {};
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _SubscriptionCard(state: subState),
                _SectionTitle(l10n.settingsAccount),
                _Tile(
                  icon: Icons.alternate_email,
                  title: l10n.settingsEmail,
                  subtitle: account['email']?.toString() ?? '—',
                  onTap: () =>
                      _showEmailDialog(context, ref, account['email']?.toString()),
                ),
                _Tile(
                  icon: Icons.lock_outline,
                  title: l10n.settingsChangePassword,
                  onTap: () => _showPasswordDialog(context, ref),
                ),
                _SectionTitle(l10n.settingsPrivacy),
                _SwitchTile(
                  icon: Icons.visibility_off_outlined,
                  title: l10n.settingsAnonymousReceive,
                  value: (privacy['anonymous_questions'] ?? 1) != 0,
                  onChanged: (v) async {
                    try {
                      await ref
                          .read(settingsRepositoryProvider)
                          .updatePrivacy({'anonymous_questions': v ? 1 : 0});
                      ref.invalidate(settingsStateProvider);
                    } catch (_) {
                      Fluttertoast.showToast(msg: l10n.settingsUpdateFailed);
                    }
                  },
                ),
                _SwitchTile(
                  icon: Icons.mic_none_outlined,
                  title: l10n.settingsVoiceReceive,
                  value: (privacy['accept_anon_voice'] ?? 0) != 0,
                  onChanged: (v) =>
                      _toggle(context, ref, 'accept_anon_voice', v),
                ),
                _SwitchTile(
                  icon: Icons.image_outlined,
                  title: l10n.settingsImageReceive,
                  value: (privacy['accept_anon_image'] ?? 0) != 0,
                  onChanged: (v) =>
                      _toggle(context, ref, 'accept_anon_image', v),
                ),
                _SwitchTile(
                  icon: Icons.verified_user_outlined,
                  title: l10n.settingsRegisteredOnly,
                  value: (privacy['accept_anon_from_registered_only'] ?? 0) !=
                      0,
                  onChanged: (v) => _toggle(
                      context, ref, 'accept_anon_from_registered_only', v),
                ),
                _Tile(
                  icon: Icons.block_outlined,
                  title: l10n.settingsBlockedAccounts,
                  onTap: () => context.push(AppRoutes.blockedAccounts),
                ),
                _SectionTitle(l10n.settingsNotifications),
                _SwitchTile(
                  icon: Icons.favorite_outline,
                  title: l10n.settingsLikes,
                  value: (notif['likes'] ?? 1) != 0,
                  onChanged: (v) async {
                    try {
                      await ref
                          .read(settingsRepositoryProvider)
                          .updateNotifications({'likes': v ? 1 : 0});
                      ref.invalidate(settingsStateProvider);
                    } catch (_) {
                      Fluttertoast.showToast(msg: l10n.settingsUpdateFailed);
                    }
                  },
                ),
                _SwitchTile(
                  icon: Icons.chat_bubble_outline,
                  title: l10n.settingsComments,
                  value: (notif['comments'] ?? 1) != 0,
                  onChanged: (v) async {
                    try {
                      await ref
                          .read(settingsRepositoryProvider)
                          .updateNotifications({'comments': v ? 1 : 0});
                      ref.invalidate(settingsStateProvider);
                    } catch (_) {
                      Fluttertoast.showToast(msg: l10n.settingsUpdateFailed);
                    }
                  },
                ),
                _SwitchTile(
                  icon: Icons.person_add_alt_1_outlined,
                  title: l10n.settingsFollowers,
                  value: (notif['followers'] ?? 1) != 0,
                  onChanged: (v) async {
                    try {
                      await ref
                          .read(settingsRepositoryProvider)
                          .updateNotifications({'followers': v ? 1 : 0});
                      ref.invalidate(settingsStateProvider);
                    } catch (_) {
                      Fluttertoast.showToast(msg: l10n.settingsUpdateFailed);
                    }
                  },
                ),
                _SectionTitle(l10n.settingsAppearance),
                _ThemeSelector(
                  l10n: l10n,
                  mode: themeMode,
                  onChange: (m) =>
                      ref.read(themeModeProvider.notifier).set(m),
                ),
                _LanguageSelector(
                  l10n: l10n,
                  locale: locale,
                  isAuto: ref.read(localeProvider.notifier).isAuto,
                  onPickerOpen: () => _openLanguagePicker(context, ref),
                ),
                _SectionTitle(l10n.settingsGeneral),
                _Tile(
                  icon: Icons.help_outline,
                  title: l10n.settingsHelpCenter,
                  onTap: () => context.push(AppRoutes.help),
                ),
                _Tile(
                  icon: Icons.gavel_outlined,
                  title: l10n.settingsTerms,
                  onTap: () => context.push(AppRoutes.terms),
                ),
                _Tile(
                  icon: Icons.shield_outlined,
                  title: l10n.settingsPrivacyPolicy,
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                _Tile(
                  icon: Icons.policy_outlined,
                  title: l10n.settingsContentPolicy,
                  onTap: () => context.push(AppRoutes.contentPolicy),
                ),
                _SectionTitle(l10n.settingsDangerZone),
                _Tile(
                  icon: Icons.logout,
                  title: l10n.settingsLogout,
                  color: colors.danger,
                  onTap: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
                _Tile(
                  icon: Icons.delete_forever,
                  title: l10n.settingsDeleteAccount,
                  color: colors.danger,
                  onTap: () => _showDeleteDialog(context, ref),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggle(
      BuildContext context, WidgetRef ref, String key, bool value) async {
    final failMsg = AppLocalizations.of(context).settingsUpdateFailed;
    try {
      await ref
          .read(settingsRepositoryProvider)
          .updatePrivacy({key: value ? 1 : 0});
      ref.invalidate(settingsStateProvider);
    } catch (_) {
      Fluttertoast.showToast(msg: failMsg);
    }
  }

  Future<void> _showEmailDialog(
      BuildContext context, WidgetRef ref, String? current) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: current ?? '');
    bool saving = false;
    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(builder: (c, set) {
        return AlertDialog(
          title: Text(l10n.settingsEmail),
          content: AppTextField(
            controller: ctrl,
            label: l10n.settingsEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: Text(l10n.commonCancel)),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      set(() => saving = true);
                      try {
                        await ref
                            .read(settingsRepositoryProvider)
                            .updateAccount(email: ctrl.text.trim());
                        if (context.mounted) Navigator.of(c).pop();
                        Fluttertoast.showToast(msg: l10n.settingsUpdated);
                        ref.invalidate(settingsStateProvider);
                      } on ApiException catch (e) {
                        Fluttertoast.showToast(msg: e.message);
                      } finally {
                        set(() => saving = false);
                      }
                    },
              child: Text(saving ? '…' : l10n.commonSave),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _showPasswordDialog(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final cur = TextEditingController();
    final next = TextEditingController();
    bool saving = false;
    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(builder: (c, set) {
        return AlertDialog(
          title: Text(l10n.settingsChangePassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: cur,
                label: l10n.settingsPasswordCurrent,
                obscure: true,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: next,
                label: l10n.settingsPasswordNew,
                obscure: true,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: Text(l10n.commonCancel)),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (next.text.length < 8) {
                        Fluttertoast.showToast(msg: l10n.settingsPasswordShort);
                        return;
                      }
                      set(() => saving = true);
                      try {
                        await ref
                            .read(settingsRepositoryProvider)
                            .updatePassword(
                              currentPassword: cur.text,
                              newPassword: next.text,
                            );
                        if (context.mounted) Navigator.of(c).pop();
                        Fluttertoast.showToast(msg: l10n.settingsUpdated);
                      } on ValidationException catch (e) {
                        Fluttertoast.showToast(msg: e.message);
                      } catch (_) {
                        Fluttertoast.showToast(msg: l10n.settingsUpdateFailed);
                      } finally {
                        set(() => saving = false);
                      }
                    },
              child: Text(saving ? '…' : l10n.commonSave),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final pwdCtrl = TextEditingController();
    bool busy = false;
    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(builder: (c, set) {
        return AlertDialog(
          title: Text(l10n.settingsDeleteConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.settingsDeleteConfirmBody),
              const SizedBox(height: 12),
              AppTextField(
                controller: pwdCtrl,
                label: l10n.settingsDeleteConfirmField,
                obscure: true,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: Text(l10n.commonCancel)),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(c).colorScheme.error),
              onPressed: busy
                  ? null
                  : () async {
                      set(() => busy = true);
                      try {
                        await ref
                            .read(settingsRepositoryProvider)
                            .deleteAccount(password: pwdCtrl.text);
                        if (context.mounted) Navigator.of(c).pop();
                        await ref
                            .read(authStateProvider.notifier)
                            .clearSession();
                        if (context.mounted) context.go(AppRoutes.login);
                      } catch (e) {
                        Fluttertoast.showToast(msg: l10n.settingsDeleteFailed);
                      } finally {
                        set(() => busy = false);
                      }
                    },
              child: Text(busy ? '…' : l10n.settingsDeleteAction),
            ),
          ],
        );
      }),
    );
  }
}

/// Opens a bottom sheet listing every supported language in its own script
/// plus an "Auto (device language)" row that clears the user's pick and
/// reverts to platform detection. Tapping a row sets locale and closes.
Future<void> _openLanguagePicker(BuildContext context, WidgetRef ref) async {
  final colors = context.sarhnyColors;
  final l10n = AppLocalizations.of(context);
  final notifier = ref.read(localeProvider.notifier);
  final current = ref.read(localeProvider);
  final supported = AppLocalizations.supportedLocales;
  final isAuto = notifier.isAuto;

  await showModalBottomSheet(
    context: context,
    backgroundColor: colors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.settingsLanguage,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.smartphone_rounded,
                  color: colors.textSecondary, size: 20),
              title: Text(l10n.settingsLanguageAuto),
              trailing: isAuto
                  ? Icon(Icons.check_rounded, color: colors.moment)
                  : null,
              onTap: () async {
                await notifier.resetToDevice();
                if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
              },
            ),
            Divider(height: 1, color: colors.border),
            for (final loc in supported)
              ListTile(
                title: Text(
                  kLanguageDisplayNames[loc.languageCode] ?? loc.languageCode,
                ),
                trailing: !isAuto && loc.languageCode == current.languageCode
                    ? Icon(Icons.check_rounded, color: colors.moment)
                    : null,
                onTap: () async {
                  await notifier.set(loc);
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
              ),
          ],
        ),
      );
    },
  );
}

class _SubscriptionCard extends ConsumerWidget {
  const _SubscriptionCard({required this.state});
  final AsyncValue state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    return state.when(
      loading: () => const SizedBox(height: 100),
      error: (e, _) => const SizedBox(),
      data: (s) => GestureDetector(
        onTap: () => _openSubscriptionSheet(context, ref),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                colors.crystal.withValues(alpha: 0.15),
                colors.mind.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: colors.crystal.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.crystal.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Text('✦',
                    style: TextStyle(color: colors.crystal, fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.settingsPackagePrefix} ${_tierLabel(l, s.tier as String)}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.balance != null && s.dailyMax != null
                          ? '${l.settingsAttentionPrefix} ${s.balance}/${s.dailyMax}'
                          : l.settingsManageSubscription,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: colors.textSecondary),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }
}

void _openSubscriptionSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SubscriptionSheet(),
  );
}

String _tierLabel(AppLocalizations l, String tier) {
  switch (tier) {
    case 'pro':
      return l.settingsTierPro;
    case 'creator':
      return l.settingsTierCreator;
    case 'eternal':
      return l.settingsTierEternal;
    default:
      return l.settingsTierFree;
  }
}

class _SubscriptionSheet extends ConsumerWidget {
  const _SubscriptionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    final tiers = ref.watch(subscriptionTiersProvider);
    final me = ref.watch(subscriptionStateProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: tiers.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(message: e.toString()),
          data: (list) {
            final currentTier = me.value?.tier ?? 'free';
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
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
                Text(
                  l.settingsPlansTitle,
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.settingsPlansSubtitle,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                for (final t in list)
                  _TierCard(
                    tier: t,
                    isCurrent: t.key == currentTier,
                    onUpgrade: () async {
                      try {
                        await ref
                            .read(subscriptionRepositoryProvider)
                            .upgrade(t.key);
                        ref.invalidate(subscriptionStateProvider);
                        if (context.mounted) Navigator.of(context).pop();
                        Fluttertoast.showToast(msg: l.settingsUpgraded);
                      } catch (_) {
                        Fluttertoast.showToast(msg: l.settingsUpgradeFailed);
                      }
                    },
                    onCancel: () async {
                      try {
                        await ref
                            .read(subscriptionRepositoryProvider)
                            .cancel();
                        ref.invalidate(subscriptionStateProvider);
                        if (context.mounted) Navigator.of(context).pop();
                        Fluttertoast.showToast(msg: l.settingsSubscriptionCancelled);
                      } catch (_) {
                        Fluttertoast.showToast(msg: l.settingsCancelFailed);
                      }
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.isCurrent,
    required this.onUpgrade,
    required this.onCancel,
  });
  final SubscriptionTier tier;
  final bool isCurrent;
  final VoidCallback onUpgrade;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent
            ? colors.crystal.withValues(alpha: 0.10)
            : colors.elevated,
        border: Border.all(
          color: isCurrent ? colors.crystal : colors.border,
          width: isCurrent ? 1.4 : 0.6,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _tierLabel(l, tier.key),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (tier.priceLabel != null)
                Text(
                  tier.priceLabel!,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (tier.dailyMax != null) ...[
            const SizedBox(height: 6),
            Text(
              '${l.settingsDailyAttentionPrefix} ${tier.dailyMax}',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
          if (tier.features.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final f in tier.features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 12, color: colors.mind),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 10),
          if (isCurrent)
            tier.key == 'free'
                ? Text(
                    l.settingsCurrentPlan,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : AppButton(
                    label: l.settingsCancelSubscription,
                    variant: AppButtonVariant.secondary,
                    onPressed: onCancel,
                  )
          else
            AppButton(
              label: l.settingsUpgrade,
              onPressed: onUpgrade,
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final fg = color ?? colors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 0.4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: fg, fontSize: 14)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(color: colors.textPrimary)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.moment,
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.l10n,
    required this.mode,
    required this.onChange,
  });
  final AppLocalizations l10n;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChange;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.color_lens_outlined,
                size: 18, color: colors.textPrimary),
            const SizedBox(width: 8),
            Text(l10n.settingsAppearance,
                style: TextStyle(color: colors.textPrimary)),
          ]),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                  value: ThemeMode.light, label: Text(l10n.themeLight)),
              ButtonSegment(
                  value: ThemeMode.dark, label: Text(l10n.themeDark)),
              ButtonSegment(
                  value: ThemeMode.system, label: Text(l10n.settingsThemeAuto)),
            ],
            selected: {mode},
            onSelectionChanged: (s) => onChange(s.first),
          ),
        ],
      ),
    );
  }
}

/// Single-row language tile that opens a full bottom-sheet picker on tap.
/// Replaces the old 2-option SegmentedButton — a segmented button doesn't
/// scale past 3 choices, and we now support 14 languages.
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.l10n,
    required this.locale,
    required this.isAuto,
    required this.onPickerOpen,
  });
  final AppLocalizations l10n;
  final Locale locale;
  final bool isAuto;
  final VoidCallback onPickerOpen;
  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final currentLabel = isAuto
        ? l10n.settingsLanguageAuto
        : (kLanguageDisplayNames[locale.languageCode] ?? locale.languageCode);
    return InkWell(
      onTap: onPickerOpen,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 0.4),
        ),
        child: Row(
          children: [
            Icon(Icons.translate, size: 18, color: colors.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsLanguage,
                      style: TextStyle(color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    currentLabel,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

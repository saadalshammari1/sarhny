import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../../data/xo_repository.dart';

/// XO lobby — mirror of the RPS lobby but tighter. Pick mood + opponent
/// type (random / invite a friend / paste invite code), tap to start.
class XoLobbyPage extends ConsumerStatefulWidget {
  const XoLobbyPage({super.key});
  @override
  ConsumerState<XoLobbyPage> createState() => _XoLobbyPageState();
}

class _XoLobbyPageState extends ConsumerState<XoLobbyPage> {
  String _mood = 'light';
  bool _busy = false;
  final _inviteCtrl = TextEditingController();

  @override
  void dispose() {
    _inviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _join({String? inviteCode, bool createInvite = false}) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    GameHaptics.uiPop();
    try {
      final r = await ref.read(xoRepositoryProvider).join(
            mood: _mood,
            inviteCode: inviteCode,
            createInvite: createInvite,
          );
      if (!mounted) return;
      context.go('/xo/play/${r.snapshot.gameId}');
    } on XoApiException catch (e) {
      Fluttertoast.showToast(msg: xoErrorMessage(e.message, l10n));
    } catch (_) {
      Fluttertoast.showToast(msg: l10n.errorGameStart);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'XO',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            GameHaptics.tap();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.gamesHub);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Hero(colors: colors),
              const Gap(20),
              _SectionLabel(l10n.moodChoose, colors),
              const Gap(10),
              Row(
                children: [
                  _MoodTile(
                    label: l10n.moodLight,
                    emoji: '🌤️',
                    selected: _mood == 'light',
                    onTap: () {
                      GameHaptics.tap();
                      setState(() => _mood = 'light');
                    },
                    colors: colors,
                  ),
                  const Gap(8),
                  _MoodTile(
                    label: l10n.moodBold,
                    emoji: '🔥',
                    selected: _mood == 'bold',
                    onTap: () {
                      GameHaptics.tap();
                      setState(() => _mood = 'bold');
                    },
                    colors: colors,
                  ),
                  const Gap(8),
                  _MoodTile(
                    label: l10n.moodFunny,
                    emoji: '😂',
                    selected: _mood == 'funny',
                    onTap: () {
                      GameHaptics.tap();
                      setState(() => _mood = 'funny');
                    },
                    colors: colors,
                  ),
                ],
              ),
              const Gap(22),
              _SectionLabel(l10n.lobbyStartMatchSection, colors),
              const Gap(10),
              _PrimaryAction(
                label: l10n.lobbyVsAi,
                sublabel: l10n.lobbyVsAiSub,
                icon: Icons.psychology_rounded,
                accent: colors.crystal,
                colors: colors,
                busy: false,
                onTap: () {
                  GameHaptics.uiPop();
                  context.push(AppRoutes.xoLocal);
                },
              ),
              const Gap(10),
              _PrimaryAction(
                label: l10n.lobbyVsRandom,
                sublabel: l10n.lobbyVsRandomSub,
                icon: Icons.public_rounded,
                accent: colors.moment,
                colors: colors,
                busy: _busy,
                onTap: () => _join(),
              ),
              const Gap(10),
              _PrimaryAction(
                label: l10n.lobbyInviteFriend,
                sublabel: l10n.lobbyInviteFriendSub,
                icon: Icons.group_add_rounded,
                accent: colors.face,
                colors: colors,
                busy: _busy,
                onTap: () => _join(createInvite: true),
              ),
              const Gap(14),
              _SectionLabel(l10n.lobbyJoinByCode, colors),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inviteCtrl,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: colors.surface,
                        hintText: 'XXXXXX',
                        hintStyle: TextStyle(
                          color: colors.textSecondary,
                          letterSpacing: 4,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.border.withValues(alpha: 0.6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.border.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _busy || _inviteCtrl.text.trim().isEmpty
                          ? null
                          : () => _join(inviteCode: _inviteCtrl.text.trim()),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                      label: Text(l10n.actionJoin),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Hero — explains what XO is in two short lines (Sarhny twist: question)
// ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.colors});
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.moment.withValues(alpha: 0.18),
            colors.face.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(color: colors.moment.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.xoPageTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const Gap(4),
                Text(
                  l10n.xoLobbyHeroDescription,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colors.moment.withValues(alpha: 0.25),
              border: Border.all(color: colors.moment.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Text(
              '×O',
              style: TextStyle(
                color: colors.moment,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.colors);
  final String text;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      );
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? colors.moment.withValues(alpha: 0.20)
                : colors.surface,
            border: Border.all(
              color: selected
                  ? colors.moment.withValues(alpha: 0.85)
                  : colors.border.withValues(alpha: 0.6),
              width: selected ? 1.4 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const Gap(4),
              Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.accent,
    required this.colors,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final Color accent;
  final SarhnyColors colors;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: colors.border.withValues(alpha: 0.55), width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.25),
                      accent.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: accent.withValues(alpha: 0.35), width: 0.8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent, size: 22),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      sublabel,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: accent,
                    size: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

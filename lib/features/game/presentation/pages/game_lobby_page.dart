import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/game_repository.dart';
import '../providers/game_providers.dart';

/// Entry to the game. Pick a mood, then either invite a friend (creates a
/// shareable code) or queue up for a random opponent.
class GameLobbyPage extends ConsumerStatefulWidget {
  const GameLobbyPage({super.key});
  @override
  ConsumerState<GameLobbyPage> createState() => _GameLobbyPageState();
}

class _GameLobbyPageState extends ConsumerState<GameLobbyPage> {
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
    try {
      final r = await ref.read(gameRepositoryProvider).join(
            mood: _mood,
            inviteCode: inviteCode,
            createInvite: createInvite,
          );
      if (!mounted) return;
      // If we created an invite, we still navigate to the play page where
      // the invite code is rendered prominently while we wait.
      context.go('/game/play/${r.snapshot.gameId}');
    } on GameApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
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
      // Explicit leading — go_router-pushed routes sometimes don't expose
      // canPop to Material's auto back-arrow, so make it bulletproof here.
      appBar: AppBar(
        title: Text(l10n.gamePageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.actionBack,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mood picker
              Text(
                l10n.moodChoose,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _MoodCard(
                    label: l10n.moodLight,
                    emoji: '🌤️',
                    selected: _mood == 'light',
                    onTap: () => setState(() => _mood = 'light'),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _MoodCard(
                    label: l10n.moodBold,
                    emoji: '🔥',
                    selected: _mood == 'bold',
                    onTap: () => setState(() => _mood = 'bold'),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _MoodCard(
                    label: l10n.moodFunny,
                    emoji: '😂',
                    selected: _mood == 'funny',
                    onTap: () => setState(() => _mood = 'funny'),
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Local vs AI — tap-to-play, no waiting.
              _PrimaryCta(
                label: l10n.lobbyVsAi,
                subtitle: l10n.lobbyVsAiSub,
                icon: Icons.psychology_rounded,
                onTap: _busy
                    ? null
                    : () => context.push('/game/local'),
                colors: colors,
              ),
              const SizedBox(height: 12),

              // Random match
              _PrimaryCta(
                label: l10n.lobbyVsRandom,
                subtitle: l10n.gameLobbyRandomSub,
                icon: Icons.shuffle_rounded,
                onTap: _busy ? null : () => _join(),
                colors: colors,
              ),
              const SizedBox(height: 12),

              // Invite friend
              _PrimaryCta(
                label: l10n.lobbyInviteFriend,
                subtitle: l10n.lobbyInviteFriendSub,
                icon: Icons.person_add_alt_1_rounded,
                onTap: _busy ? null : () => _join(createInvite: true),
                colors: colors,
              ),
              const SizedBox(height: 24),

              // Accept invite
              Text(
                l10n.lobbyJoinByCode,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inviteCtrl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l10n.lobbyPasteCode,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _join(inviteCode: _inviteCtrl.text.trim()),
                    child: Text(l10n.actionJoin),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              // Rules
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.border, width: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.gameRulesTitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._rule(colors, '• ${l10n.gameRule1}'),
                    ..._rule(colors, '• ${l10n.gameRule2}'),
                    ..._rule(colors, '• ${l10n.gameRule3}'),
                    ..._rule(colors, '• ${l10n.gameRule4}'),
                    ..._rule(colors, '• ${l10n.gameRule5}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> _rule(SarhnyColors colors, String text) sync* {
    yield Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(color: colors.textSecondary, fontSize: 12, height: 1.6),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? colors.moment.withValues(alpha: 0.12) : colors.elevated,
            border: Border.all(
              color: selected ? colors.moment : colors.border,
              width: selected ? 1.4 : 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? colors.moment : colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border, width: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.moment.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.moment),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
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

/// Tiny helper if other pages need to copy the invite code to the clipboard.
Future<void> copyInviteCode(BuildContext context, String code) async {
  final l10n = AppLocalizations.of(context);
  await Clipboard.setData(ClipboardData(text: code));
  Fluttertoast.showToast(msg: l10n.errorClipboardCopied);
}

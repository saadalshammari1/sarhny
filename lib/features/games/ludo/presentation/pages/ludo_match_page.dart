import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../application/ludo_controllers.dart';
import '../../application/ludo_match_state.dart';
import '../../domain/ludo_state.dart';
import '../widgets/ludo_board.dart';
import '../widgets/ludo_board_geometry.dart';
import '../widgets/ludo_chat_bubble.dart';
import '../widgets/ludo_dice.dart';
import '../widgets/ludo_player_card.dart';
import '../widgets/ludo_quick_chat_bar.dart';

/// شاشة المباراة الكاملة — board + dice + player cards + chat.
class LudoMatchPage extends ConsumerStatefulWidget {
  const LudoMatchPage({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<LudoMatchPage> createState() => _LudoMatchPageState();
}

/// عنصر bubble نشِط على الشاشة — نحتفظ بقائمة لأن chats قد تتلاحق.
class _ActiveChatBubble {
  _ActiveChatBubble({
    required this.id,
    required this.emoji,
    required this.text,
    required this.fromSeat,
    required this.accent,
  });
  final int id;
  final String emoji;
  final String text;
  final int fromSeat;
  final Color accent;
}

class _LudoMatchPageState extends ConsumerState<LudoMatchPage> {
  final LudoDiceController _diceCtrl = LudoDiceController();
  bool _navigatedToOver = false;
  int? _lastDiceShown;
  DateTime? _lastChatTs;
  int _bubbleSeq = 0;
  final List<_ActiveChatBubble> _activeBubbles = [];
  static const int _maxBubbles = 3;

  Future<void> _confirmConcede() async {
    final colors = context.sarhnyColors;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('الاستسلام؟'),
        content: const Text(
          'إذا انسحبت الآن، يخسر دخولك للـ pot وتُحتسب الخسارة الأخيرة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('تراجع'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('استسلام'),
          ),
        ],
      ),
    );
    if (result == true) {
      ref
          .read(ludoMatchControllerProvider(widget.roomId).notifier)
          .concede();
    }
  }

  void _pushChatBubble(LudoIncomingChat chat, LudoState? gameState) {
    // Look up the preset from the cached provider (sync if available).
    final presetsAsync = ref.read(ludoChatPresetsProvider);
    String emoji = '💬';
    String text = chat.presetKey;
    presetsAsync.whenData((data) {
      for (final p in data.presets) {
        if (p.key == chat.presetKey) {
          emoji = p.emoji;
          text = p.ar;
          break;
        }
      }
    });

    // Resolve sender seat + accent color from the live game state.
    int seat = 0;
    Color accent = const Color(0xFF607D8B);
    if (gameState != null) {
      for (final p in gameState.players) {
        if (p.userId == chat.fromUserId) {
          seat = p.seat;
          accent = p.color.primary;
          break;
        }
      }
    }

    HapticFeedback.selectionClick();

    setState(() {
      _activeBubbles.add(_ActiveChatBubble(
        id: ++_bubbleSeq,
        emoji: emoji,
        text: text,
        fromSeat: seat,
        accent: accent,
      ));
      while (_activeBubbles.length > _maxBubbles) {
        _activeBubbles.removeAt(0);
      }
    });
  }

  void _dismissBubble(int id) {
    if (!mounted) return;
    setState(() {
      _activeBubbles.removeWhere((b) => b.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final snap = ref.watch(ludoMatchControllerProvider(widget.roomId));
    final state = snap.state;
    final ctrl = ref.read(ludoMatchControllerProvider(widget.roomId).notifier);

    // Listen for dice rolls + game over + new incoming chat.
    ref.listen<LudoMatchSnapshot>(
      ludoMatchControllerProvider(widget.roomId),
      (prev, next) {
        // dice rolled — trigger animation
        if (next.lastDiceRoll != null &&
            next.lastDiceRoll != prev?.lastDiceRoll &&
            next.lastDiceRoll!.value != _lastDiceShown) {
          _lastDiceShown = next.lastDiceRoll!.value;
          _diceCtrl.rollTo(next.lastDiceRoll!.value);
        }
        // new incoming chat — compare by ts (handles repeats of same key).
        final incoming = next.lastIncomingChat;
        if (incoming != null && incoming.ts != prev?.lastIncomingChat?.ts) {
          if (_lastChatTs != incoming.ts) {
            _lastChatTs = incoming.ts;
            _pushChatBubble(incoming, next.state);
          }
        }
        // error toast
        if (next.lastError != null && prev?.lastError != next.lastError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: ${next.lastError}')),
          );
          ctrl.clearError();
        }
        // game over
        if (next.outcome != null && !_navigatedToOver) {
          _navigatedToOver = true;
          final outcome = next.outcome;
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted) return;
            // ignore: use_build_context_synchronously
            context.pushReplacement(
              AppRoutes.ludoGameOver(widget.roomId),
              extra: outcome,
            );
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('لودو'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _confirmConcede,
        ),
        actions: [
          if (state != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.crystal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colors.crystal.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '✦',
                      style: TextStyle(
                        color: colors.crystal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.pot}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: state == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Column(
                    children: [
                      if (!snap.connectionUp)
                        Container(
                          width: double.infinity,
                          color: colors.danger.withValues(alpha: 0.18),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child:
                                    CircularProgressIndicator(strokeWidth: 1.4),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'إعادة الاتصال…',
                                style: TextStyle(
                                  color: colors.danger,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Player cards — top row (2 seats) + bottom row (2 seats)
                      // for 4p. For 2p we still show top/bottom.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: LudoPlayerCard(
                                player: state.playerAt(0),
                                isYou: state.yourSeat == 0,
                                isCurrentTurn: state.turnSeat == 0,
                                isOnline: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LudoPlayerCard(
                                player: state.playerAt(1),
                                isYou: state.yourSeat == 1,
                                isCurrentTurn: state.turnSeat == 1,
                                isOnline: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Board
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: LudoBoard(
                            state: state,
                            moveStream: ctrl.moveStream,
                            brightness: Theme.of(context).brightness,
                            onTokenTap: ctrl.move,
                          ),
                        ),
                      ),

                      // Player cards — bottom (if 4p)
                      if (state.mode == LudoMode.fourPlayer)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: LudoPlayerCard(
                                  player: state.playerAt(3),
                                  isYou: state.yourSeat == 3,
                                  isCurrentTurn: state.turnSeat == 3,
                                  isOnline: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LudoPlayerCard(
                                  player: state.playerAt(2),
                                  isYou: state.yourSeat == 2,
                                  isCurrentTurn: state.turnSeat == 2,
                                  isOnline: true,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Dice + status row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.yourTurn
                                        ? (state.dice == null
                                            ? 'دورك — ارمِ الزهر'
                                            : (snap.pendingMove
                                                ? 'جاري التحريك…'
                                                : 'اختر قطعة لتحريكها'))
                                        : 'دور ${_seatLabel(state.turnSeat)}',
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.yourTurn && state.dice != null
                                        ? 'القطع القابلة للتحريك مضيئة بالأخضر'
                                        : 'بدوافع الزهر تتقدم الخطى',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            LudoDice(
                              controller: _diceCtrl,
                              myTurn:
                                  state.yourTurn && state.dice == null,
                              initialValue: state.dice,
                              onTap: ctrl.roll,
                            ),
                          ],
                        ),
                      ),

                      // Quick chat
                      LudoQuickChatBar(onSend: ctrl.sendChat),
                    ],
                  ),
                  // Chat-bubble overlay — positioned per seat.
                  ..._activeBubbles.map((b) {
                    return _positionedBubble(b);
                  }),
                ],
              ),
      ),
    );
  }

  Widget _positionedBubble(_ActiveChatBubble b) {
    final bubble = LudoChatBubble(
      key: ValueKey('ludo-chat-bubble-${b.id}'),
      emoji: b.emoji,
      text: b.text,
      fromSeat: b.fromSeat,
      accentColor: b.accent,
      onDismissed: () => _dismissBubble(b.id),
    );
    switch (b.fromSeat) {
      case 1:
        return Positioned(
          left: 16,
          top: MediaQuery.of(context).size.height * 0.5,
          child: bubble,
        );
      case 2:
        return Positioned(
          top: 100,
          right: 16,
          child: bubble,
        );
      case 3:
        return Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height * 0.5,
          child: bubble,
        );
      case 0:
      default:
        return Positioned(
          bottom: 100,
          left: 16,
          child: bubble,
        );
    }
  }

  String _seatLabel(int seat) {
    switch (seat) {
      case 0:
        return 'الأحمر';
      case 1:
        return 'الأخضر';
      case 2:
        return 'الأصفر';
      case 3:
        return 'الأزرق';
    }
    return 'الخصم';
  }
}

import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/providers/auth_providers.dart';
import '../../application/carrom_match_state.dart';
import '../../domain/carrom_state.dart';
import '../../domain/shot_result.dart';
import '../widgets/carrom_board.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/opponent_card.dart';
import '../widgets/quick_chat_bar.dart';
import '../widgets/striker_aim_overlay.dart';
import '../widgets/wallet_chip.dart';

/// شاشة المباراة الكاملة — تربط FlameGame + overlay + chat + score.
class CarromMatchPage extends ConsumerStatefulWidget {
  const CarromMatchPage({super.key, required this.roomId});
  final String roomId;
  @override
  ConsumerState<CarromMatchPage> createState() => _CarromMatchPageState();
}

class _CarromMatchPageState extends ConsumerState<CarromMatchPage> {
  CarromBoardGame? _game;
  StreamSubscription<CarromShotResult>? _shotSub;
  bool _navigatedToGameOver = false;

  @override
  void dispose() {
    _shotSub?.cancel();
    super.dispose();
  }

  void _ensureGame(CarromState s, int? myUserId) {
    if (_game != null) {
      _game!.applyState(s);
      return;
    }
    _game = CarromBoardGame(
      initialState: s,
      myUserId: myUserId,
      onShoot: (_) {}, // shot يُرسل من overlay عبر controller
    );
    // اشتبك مع stream الـ shot result من الـ controller.
    final ctrl =
        ref.read(carromMatchControllerProvider(widget.roomId).notifier);
    _shotSub = ctrl.shotStream.listen((r) {
      _game?.playShotResult(r);
    });
  }

  Future<void> _confirmConcede() async {
    final colors = context.sarhnyColors;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('الاستسلام؟'),
        content: const Text(
          'إذا انسحبت الآن، يفوز خصمك بالنقاط كاملة.',
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
          .read(carromMatchControllerProvider(widget.roomId).notifier)
          .concede();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final myUserId = ref.watch(authStateProvider).value?.userId;
    final snap = ref.watch(carromMatchControllerProvider(widget.roomId));
    final state = snap.state;

    // Show error toast على last error
    ref.listen<CarromMatchSnapshot>(
      carromMatchControllerProvider(widget.roomId),
      (prev, next) {
        if (next.lastError != null && prev?.lastError != next.lastError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: ${next.lastError}')),
          );
          ref
              .read(carromMatchControllerProvider(widget.roomId).notifier)
              .clearError();
        }
        // Game over → navigate
        if (next.outcome != null && !_navigatedToGameOver) {
          _navigatedToGameOver = true;
          // أعطِ الـ board 1.2s لإنهاء آخر animation قبل الانتقال.
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted) return;
            // ignore: use_build_context_synchronously
            context.pushReplacement(
              AppRoutes.carromGameOver(widget.roomId),
              extra: next.outcome,
            );
          });
        }
      },
    );

    if (state == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _ensureGame(state, myUserId);
    final game = _game!;

    final isMyTurn = state.yourTurn && state.status == CarromStatus.playing;
    final canShoot = isMyTurn && snap.pendingShot != true;

    final myScore = state.scoreFor(myUserId);
    final oppScore = state.opponentScoreFor(myUserId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmConcede();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('كيرم'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _confirmConcede,
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: CarromWalletChip(compact: true),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (!snap.connectionUp)
                Container(
                  width: double.infinity,
                  color: colors.danger.withValues(alpha: 0.15),
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Text(
                    'إعادة الاتصال بالخادم...',
                    style: TextStyle(
                      color: colors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (snap.opponentReconnectDeadline != null)
                _OpponentDisconnectBanner(
                  deadline: snap.opponentReconnectDeadline!,
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CarromOpponentCard(
                        score: myScore,
                        isTurn: isMyTurn,
                        online: true,
                        isYou: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CarromOpponentCard(
                        score: oppScore,
                        isTurn:
                            !isMyTurn && state.status == CarromStatus.playing,
                        online: snap.opponentReconnectDeadline == null,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (ctx, c) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: GameWidget<CarromBoardGame>(game: game),
                            ),
                            // Aim overlay — يطفو فوق
                            Positioned.fill(
                              child: StrikerAimOverlay(
                                state: state,
                                myUserId: myUserId,
                                enabled: canShoot,
                                onShoot: (input) {
                                  ref
                                      .read(carromMatchControllerProvider(
                                              widget.roomId)
                                          .notifier)
                                      .shoot(input);
                                },
                              ),
                            ),
                            // chat bubble overlay
                            if (snap.lastIncomingChat != null)
                              Positioned(
                                top: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: CarromChatBubble(
                                    chat: snap.lastIncomingChat!,
                                  ),
                                ),
                              ),
                            // turn overlay
                            if (state.status == CarromStatus.playing &&
                                !isMyTurn)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.55),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'دور الخصم',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (snap.pendingShot == true)
                              const Positioned.fill(
                                child: ColoredBox(
                                  color: Color(0x33000000),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              CarromQuickChatBar(
                onSend: (k) {
                  ref
                      .read(carromMatchControllerProvider(widget.roomId)
                          .notifier)
                      .sendChat(k);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpponentDisconnectBanner extends StatefulWidget {
  const _OpponentDisconnectBanner({required this.deadline});
  final DateTime deadline;

  @override
  State<_OpponentDisconnectBanner> createState() =>
      _OpponentDisconnectBannerState();
}

class _OpponentDisconnectBannerState
    extends State<_OpponentDisconnectBanner> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final remaining =
        widget.deadline.difference(DateTime.now()).inSeconds.clamp(0, 999);
    return Container(
      width: double.infinity,
      color: colors.warning.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        'خصمك انقطع — في انتظاره ($remaining ث)',
        style: TextStyle(
          color: colors.warning,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// SarhnyColors helpers — warning lookup
extension on SarhnyColors {
  Color get warning => const Color(0xFFE8B14C);
}

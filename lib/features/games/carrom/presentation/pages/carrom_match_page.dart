import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/providers/auth_providers.dart';
import '../../application/carrom_match_state.dart';
import '../../domain/carrom_state.dart';
import '../../domain/shot_result.dart';
import '../widgets/carrom_alert_banner.dart';
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
  // Counts every connectionUp → !connectionUp transition so we can show
  // "محاولة #N" without touching the controller's state.
  int _reconnectAttempt = 0;
  // Banner state — driven by shot_result events. A new key resets the banner
  // widget so re-occurring fouls of the same kind re-animate.
  int _alertSeq = 0;
  String? _alertKind;
  String? _alertMessage;

  @override
  void dispose() {
    _shotSub?.cancel();
    super.dispose();
  }

  void _showAlert(String kind, String message) {
    if (!mounted) return;
    setState(() {
      _alertSeq += 1;
      _alertKind = kind;
      _alertMessage = message;
    });
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
      // Surface foul + queen-pending feedback via the floating alert banner.
      // Server stamps the foul reason; client maps it via CarromAlertBanner.
      if (r.foul && r.foulReason != null) {
        _showAlert('foul', CarromAlertBanner.localizedFoul(r.foulReason!));
      } else if (r.queenPending) {
        _showAlert('queen', CarromAlertBanner.localizedFoul('queen_pending'));
      }
    });
  }

  Future<void> _confirmConcede() async {
    HapticFeedback.mediumImpact();
    final colors = context.sarhnyColors;
    final pot =
        ref.read(carromMatchControllerProvider(widget.roomId)).state?.pot ?? 0;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة تحذير داخل دائرة حمراء فاتحة.
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade700.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'هل تستسلم؟',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'إذا انسحبت الآن سيفوز خصمك بـ $pot نقطة. لا يمكن التراجع.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: colors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text(
                        'متابعة المباراة',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        Navigator.of(ctx).pop(true);
                      },
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text(
                        'أستسلم',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

    // Show error toast على last error + navigate عند انتهاء المباراة.
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
        // Game over → انتقل فوراً (game-over page يعرض الـ celebration).
        if (next.outcome != null && !_navigatedToGameOver) {
          _navigatedToGameOver = true;
          // ignore: use_build_context_synchronously
          context.pushReplacement(
            AppRoutes.carromGameOver(widget.roomId),
            extra: next.outcome,
          );
        }
        // عدّ محاولات إعادة الاتصال (true → false transitions).
        if (prev != null && prev.connectionUp && !next.connectionUp) {
          _reconnectAttempt += 1;
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
    final gameOver = snap.outcome != null;

    return PopScope(
      canPop: gameOver,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // إذا انتهت المباراة (race condition قبل ما الـ canPop يحدّث) — اسمح.
        if (snap.outcome != null) {
          if (mounted) context.go(AppRoutes.carromLobby);
          return;
        }
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
              if (_alertKind != null && _alertMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Center(
                    child: CarromAlertBanner(
                      key: ValueKey('alert_$_alertSeq'),
                      kind: _alertKind!,
                      message: _alertMessage!,
                    ),
                  ),
                ),
              if (!snap.connectionUp)
                _ReconnectBanner(
                  attempt: _reconnectAttempt,
                  color: colors.danger,
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

/// Banner reconnect — يدور spinner صغير + عداد المحاولات.
class _ReconnectBanner extends StatelessWidget {
  const _ReconnectBanner({required this.attempt, required this.color});
  final int attempt;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = attempt > 0
        ? 'إعادة الاتصال... (محاولة #$attempt)'
        : 'إعادة الاتصال بالخادم...';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      color: color.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

class _OpponentDisconnectBannerState extends State<_OpponentDisconnectBanner>
    with SingleTickerProviderStateMixin {
  Timer? _t;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _t?.cancel();
    _pulse.dispose();
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // نقطة نابضة قبل النص.
          FadeTransition(
            opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_pulse),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.warning,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'خصمك انقطع — في انتظاره ',
            style: TextStyle(
              color: colors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$remaining ث',
            style: TextStyle(
              color: colors.warning,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// SarhnyColors helpers — warning lookup
extension on SarhnyColors {
  Color get warning => const Color(0xFFE8B14C);
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/localization/generated/app_localizations.dart';
import '../../carrom3/data/carrom_sfx.dart';
import '../logic/ludo_game.dart';
import '../theme/cosmetics.dart';
import '../theme/ludo_theme.dart';
import '../widgets/board_painter.dart';
import '../widgets/pawn_widget.dart';
import '../widgets/dice_widget.dart';

const _bgTop = Color(0xFF1B1740);
const _bgBottom = Color(0xFF0A0A1E);
const _accent = Color(0xFF7B3FE4);
const _panel = Color(0xFF14102E);
const _gold = Color(0xFFE3BD5E);

/// صفحة الراوتر.
class LudoPowerPage extends StatelessWidget {
  const LudoPowerPage({super.key, this.withPowers = true});
  final bool withPowers;
  @override
  Widget build(BuildContext context) => Scaffold(body: LudoPowerScreen(withPowers: withPowers));
}

/// لودو ملكي — ٤ لاعبين بقدرات على اللوحة، شاشة لعب كاملة.
class LudoPowerScreen extends StatefulWidget {
  const LudoPowerScreen({super.key, this.withPowers = true});
  final bool withPowers;
  @override
  State<LudoPowerScreen> createState() => _LudoPowerScreenState();
}

class _LudoPowerScreenState extends State<LudoPowerScreen> {
  late LudoGame game;
  bool busy = false;
  bool _muted = false;
  String? toastMsg;
  Timer? _toastTimer;
  int diceShown = 6;
  PowerSkin _skin = PowerSkin.royal;
  KnightStyle _knight = KnightStyle.classic;

  static const int turnSeconds = 15;
  Timer? _turnTimer;
  int _secs = turnSeconds;

  static const _coins = [1250, 1870, 1430, 980];

  @override
  void initState() {
    super.initState();
    CarromSfx.instance.init();
    game = LudoGame(onEvent: _onEvent, withPowers: widget.withPowers);
    LudoPowerPrefs.instance().then((p) {
      if (!mounted) return;
      _safeSetState(() {
        _skin = p.skin;
        _knight = p.knight;
      });
    });
    _restartTimer();
  }

  // ── Sound ────────────────────────────────────────────────────────────────
  void _sfx(void Function() play) {
    if (_muted) return;
    CarromSfx.instance.enabled = true;
    play();
  }

  void _onEvent(GameEvent e) {
    final l = AppLocalizations.of(context);
    switch (e.kind) {
      case 'capture':
        _sfx(() => CarromSfx.instance.pocket());
        _showToast(l.ludoEvCapture);
        break;
      case 'tornado':
        _sfx(() => CarromSfx.instance.pocket());
        _showToast(l.ludoEvTornado);
        break;
      case 'rocket':
        _sfx(() => CarromSfx.instance.hit(0.6));
        _showToast(l.ludoEvRocket(e.value ?? 0));
        break;
      case 'freeze':
        _sfx(() => CarromSfx.instance.hit(0.6));
        _showToast(l.ludoEvFreeze);
        break;
      case 'portal':
        _sfx(() => CarromSfx.instance.hit(0.6));
        _showToast(l.ludoEvPortal(e.value ?? 0));
        break;
      case 'shuffle':
        _sfx(() => CarromSfx.instance.hit(0.6));
        _showToast(l.ludoEvShuffle);
        break;
      case 'win':
        _sfx(() => CarromSfx.instance.win());
        _showWin(e.player!);
        break;
    }
  }

  void _showToast(String m) {
    _safeSetState(() => toastMsg = m);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _safeSetState(() => toastMsg = null);
    });
  }

  // ── Turn clock (human autopilot on timeout) ───────────────────────────────
  bool get _humanWaiting =>
      !busy && !game.gameOver && game.current == LudoGame.humanPlayer;

  void _restartTimer() {
    _turnTimer?.cancel();
    if (!_humanWaiting) return;
    _secs = turnSeconds;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secs -= 1;
      if (_secs <= 0) {
        _turnTimer?.cancel();
        _autoPlayHuman();
      }
      if (mounted) _safeSetState(() {});
    });
  }

  void _stopTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  // All async continuations (bot turns, dice animations) route through this so
  // a back-press mid-animation can't trigger setState() after dispose().
  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  String _playerName(int p, AppLocalizations l) {
    switch (p) {
      case 0:
        return l.ludoColorGold;
      case 1:
        return l.ludoColorBlue;
      case 2:
        return l.ludoColorPurple;
      default:
        return l.ludoColorYou;
    }
  }

  Future<void> _autoPlayHuman() async {
    if (!mounted) return;
    if (!_humanWaiting) return;
    _showToast(AppLocalizations.of(context).ludoAutoPlayed);
    if (!game.rolled) {
      final v = game.rollDice();
      _safeSetState(() => diceShown = v);
      final moves = game.legalMoves(game.current, v);
      if (moves.isEmpty) {
        Future.delayed(const Duration(milliseconds: 700), _endTurn);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 400));
      _doMove(game.botChoose(moves));
    } else {
      final moves = game.legalMoves(game.current, game.dice);
      if (moves.isEmpty) {
        _endTurn();
      } else {
        _doMove(game.botChoose(moves));
      }
    }
  }

  // ── Rolling / moving ──────────────────────────────────────────────────────
  Future<void> _roll() async {
    if (busy || game.rolled || game.gameOver || game.current != LudoGame.humanPlayer) return;
    _stopTimer();
    _sfx(() => CarromSfx.instance.hit(0.6));
    _safeSetState(() => busy = true);
    for (int i = 0; i < 9; i++) {
      _safeSetState(() => diceShown = 1 + (DateTime.now().microsecond % 6));
      await Future.delayed(const Duration(milliseconds: 55));
    }
    final v = game.rollDice();
    _safeSetState(() {
      diceShown = v;
      busy = false;
    });
    _afterRoll();
  }

  void _afterRoll() {
    if (!mounted) return;
    final moves = game.legalMoves(game.current, game.dice);
    if (moves.isEmpty) {
      _showToast(AppLocalizations.of(context).ludoNoMove);
      Future.delayed(const Duration(milliseconds: 750), _endTurn);
      return;
    }
    if (game.current == LudoGame.humanPlayer) {
      _restartTimer(); // human picks a pawn within the clock
      _safeSetState(() {});
    } else {
      Future.delayed(const Duration(milliseconds: 600), () => _doMove(game.botChoose(moves)));
    }
  }

  Future<void> _doMove(Move m) async {
    if (!mounted) return;
    _stopTimer();
    _safeSetState(() => busy = true);
    final player = game.current;
    _sfx(() => CarromSfx.instance.hit(0.4));
    final extra = game.applyMove(player, m);
    _safeSetState(() {});
    await Future.delayed(const Duration(milliseconds: 450));
    if (game.gameOver) {
      _safeSetState(() => busy = false);
      return;
    }
    _safeSetState(() => busy = false);
    if (extra) {
      game.rolled = false;
      _safeSetState(() => diceShown = 6);
      if (player == LudoGame.humanPlayer) {
        _restartTimer();
      } else {
        Future.delayed(const Duration(milliseconds: 550), _rollForBot);
      }
    } else {
      _endTurn();
    }
  }

  void _endTurn() {
    if (!mounted) return;
    game.endTurn();
    _safeSetState(() => diceShown = 6);
    if (game.current != LudoGame.humanPlayer && !game.gameOver) {
      Future.delayed(const Duration(milliseconds: 650), _rollForBot);
    } else {
      _restartTimer();
    }
  }

  Future<void> _rollForBot() async {
    if (!mounted) return;
    if (game.gameOver) return;
    _safeSetState(() => busy = true);
    for (int i = 0; i < 6; i++) {
      _safeSetState(() => diceShown = 1 + (DateTime.now().microsecond % 6));
      await Future.delayed(const Duration(milliseconds: 50));
    }
    final v = game.rollDice();
    _safeSetState(() {
      diceShown = v;
      busy = false;
    });
    _afterRoll();
  }

  void _tapBoard(Offset local, double boardSize) {
    if (busy || !game.rolled || game.gameOver || game.current != LudoGame.humanPlayer) return;
    final s = boardSize / 15.0;
    final gx = local.dx / s, gy = local.dy / s;
    final moves = game.legalMoves(LudoGame.humanPlayer, game.dice);
    Move? pick;
    double pd = 1e9;
    for (final m in moves) {
      final g = game.gridOf(LudoGame.humanPlayer, m.from, m.piece);
      final d = (g[0] - gx) * (g[0] - gx) + (g[1] - gy) * (g[1] - gy);
      if (d < pd) {
        pd = d;
        pick = m;
      }
    }
    if (pick != null && pd < 1.7) _doMove(pick);
  }

  void _showWin(int player) {
    _stopTimer();
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: Text(player == LudoGame.humanPlayer ? l.ludoYouWon : l.ludoPlayerWon(_playerName(player, l)),
            style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
        content: Text(
            player == LudoGame.humanPlayer ? l.ludoWinSub : l.ludoLoseSub,
            style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _gold),
              onPressed: () {
                Navigator.pop(context);
                _safeSetState(() {
                  game.reset();
                  diceShown = 6;
                });
                _restartTimer();
              },
              child: Text(l.ludoNewGame, style: const TextStyle(color: Color(0xFF1C1409), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _stopTimer();
    super.dispose();
  }

  bool get _canRoll => _humanWaiting && !game.rolled;

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(center: Alignment(0, -0.8), radius: 1.3, colors: [_bgTop, _bgBottom]),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Column(
                children: [
                  _topBar(),
                  _cardRow(0, 1), // yellow TL • blue TR
                  Expanded(child: Center(child: _board())),
                  _bottomArea(), // green BL (human) • dice • purple BR
                  _buttons(),
                ],
              ),
              if (toastMsg != null)
                Positioned(top: 92, left: 0, right: 0, child: Center(child: _toast(toastMsg!))),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  // Top bar: mute • crown/turn/countdown • coins.
  Widget _topBar() {
    final isHuman = game.current == LudoGame.humanPlayer;
    final l = AppLocalizations.of(context);
    final turnText = game.gameOver
        ? l.ludoEnded
        : isHuman ? l.ludoYourTurn : l.ludoPlayerTurn(_playerName(game.current, l));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBtn(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              () => _safeSetState(() => _muted = !_muted)),
          const Spacer(),
          Column(children: [
            const Icon(Icons.workspace_premium_rounded, color: _gold, size: 24),
            const SizedBox(height: 2),
            _turnPill(turnText),
            const SizedBox(height: 6),
            _countdown(),
          ]),
          const Spacer(),
          _coinsPill(2450),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _turnPill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold, width: 1.2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF43BD3F), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      );

  Widget _countdown() {
    final show = _canRoll || (game.rolled && game.current == LudoGame.humanPlayer && !busy);
    final frac = show ? (_secs / turnSeconds).clamp(0.0, 1.0) : 1.0;
    return SizedBox(
      width: 46, height: 46,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 46, height: 46,
          child: CircularProgressIndicator(
            value: frac, strokeWidth: 4,
            backgroundColor: const Color(0x33FFFFFF),
            valueColor: AlwaysStoppedAnimation(frac > 0.4 ? const Color(0xFF43BD3F) : const Color(0xFFE23B32)),
          ),
        ),
        Text(show ? '$_secs' : '•', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ]),
    );
  }

  Widget _coinsPill(int coins) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🪙', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text('$coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFF2FA84F), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 14)),
        ]),
      );

  // Player cards.
  Widget _cardRow(int left, int right) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _playerCard(left, avatarLeft: true),
          _playerCard(right, avatarLeft: false),
        ]),
      );

  Widget _bottomArea() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(children: [
          Expanded(child: _playerCard(3, avatarLeft: true)), // green BL = human
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: _diceRing()),
          Expanded(child: _playerCard(2, avatarLeft: false)), // purple BR
        ]),
      );

  Widget _playerCard(int p, {required bool avatarLeft}) {
    final key = BoardScheme.playerColors[p];
    final c = ludoColors[key]!;
    final active = game.current == p && !game.gameOver;
    final frozen = game.frozen[p] > 0;
    final avatar = Container(
      width: 42, height: 42,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.light, c.dark]), border: Border.all(color: c.base, width: 2)),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
    );
    final info = Column(
      crossAxisAlignment: avatarLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (frozen) const Text('❄️ ', style: TextStyle(fontSize: 11)),
          Text(_playerName(p, AppLocalizations.of(context)), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
        const SizedBox(height: 2),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🪙', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text('${_coins[p]}', style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 2),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (int i = 0; i < 4; i++)
            Opacity(opacity: game.pieces[p][i] == 57 ? 0.3 : 1, child: SizedBox(width: 13, child: PawnWidget(colorKey: key, size: 11, style: _knight))),
        ]),
      ],
    );
    final kids = avatarLeft ? [avatar, const SizedBox(width: 8), info] : [info, const SizedBox(width: 8), avatar];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? c.base : Colors.white12, width: active ? 2 : 1),
        boxShadow: active ? [BoxShadow(color: c.base.withValues(alpha: 0.55), blurRadius: 14)] : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: kids),
    );
  }

  Widget _diceRing() => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [Color(0xFF2A1F55), _panel]),
          border: Border.all(color: _accent, width: 2),
          boxShadow: _canRoll ? [BoxShadow(color: _accent.withValues(alpha: 0.7), blurRadius: 16, spreadRadius: 1)] : null,
        ),
        child: DiceWidget(value: diceShown, size: 52, onTap: _roll, enabled: _canRoll),
      );

  Widget _board() {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest.shortestSide.clamp(0.0, 460.0).toDouble();
      return GestureDetector(
        onTapDown: (d) => _tapBoard(d.localPosition, size),
        child: Container(
          width: size, height: size,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: SkinPalette.of(_skin).frame,
            ),
            borderRadius: BorderRadius.circular(size * 0.05),
            boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.04),
            child: Stack(children: [
              CustomPaint(size: Size(size - 14, size - 14), painter: BoardPainter(game, skin: _skin)),
              ..._buildPawns(size - 14),
            ]),
          ),
        ),
      );
    });
  }

  List<Widget> _buildPawns(double boardSize) {
    final s = boardSize / 15.0;
    final widgets = <Widget>[];
    final Map<String, List<List<int>>> occ = {};
    for (int p = 0; p < 4; p++) {
      for (int i = 0; i < 4; i++) {
        final g = game.gridOf(p, game.pieces[p][i], i);
        final key = '${g[0].toStringAsFixed(2)},${g[1].toStringAsFixed(2)}';
        occ.putIfAbsent(key, () => []).add([p, i]);
      }
    }
    occ.forEach((key, list) {
      for (int k = 0; k < list.length; k++) {
        final p = list[k][0], i = list[k][1];
        final g = game.gridOf(p, game.pieces[p][i], i);
        double ox = 0, oy = 0;
        final prog = game.pieces[p][i];
        if (list.length > 1 && prog >= 1 && prog <= 51) {
          final ang = (k / list.length) * 6.2831853;
          ox = 0.16 * s * math.cos(ang);
          oy = 0.16 * s * math.sin(ang);
        }
        final pawnSize = s * 0.8;
        final cx = g[0] * s + ox, cy = g[1] * s + oy;
        widgets.add(Positioned(
          left: cx - pawnSize / 2,
          top: cy - pawnSize * 1.5 + s * 0.5,
          child: PawnWidget(colorKey: BoardScheme.playerColors[p], size: pawnSize, glow: game.isMovable(p, i), style: _knight),
        ));
      }
    });
    return widgets;
  }

  Widget _buttons() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(children: [
          _pill('💬 ${AppLocalizations.of(context).ludoChat}', _panel, () {}, border: Colors.white24),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _canRoll ? _roll : null,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_accent, Color(0xFF4B2FA0)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _canRoll ? [BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 12)] : null,
                ),
                child: Text(AppLocalizations.of(context).ludoRollDice, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _pill('${AppLocalizations.of(context).ludoExit} ↩', const Color(0x33E23B32), () => Navigator.maybePop(context),
              border: const Color(0xFFE23B32), textColor: const Color(0xFFFF8A80)),
        ]),
      );

  Widget _pill(String label, Color bg, VoidCallback onTap, {Color border = Colors.transparent, Color textColor = Colors.white}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      );

  Widget _toast(String m) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_gold, Color(0xFFB8893A)]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 12)],
        ),
        child: Text(m, style: const TextStyle(color: Color(0xFF1C1409), fontWeight: FontWeight.bold, fontSize: 14)),
      );
}

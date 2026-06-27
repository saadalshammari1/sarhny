import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ads/interstitial_service.dart';
import '../../../game/data/random_question_repo.dart';
import '../data/ludo3_prefs.dart';
import '../domain/ludo_cosmetics.dart';
import '../engine/ludo_ai.dart';
import '../engine/ludo_models.dart';
import '../engine/magic.dart';
import '../../carrom3/data/carrom_sfx.dart';
import 'ludo3_board.dart';
import 'ludo3_local_match_page.dart' show kLudoChat;
import 'magic_controller.dart';
import 'widgets/ludo_dice.dart';

const _bgTop = Color(0xFF1B1740);
const _bgBottom = Color(0xFF0A0A1E);
const _accent = Color(0xFF7B3FE4);

/// Magic Ludo — same premium board/screen as classic, with AUTOMATIC board
/// magic (🎁 Mystery Boxes, 🌀 Wormholes) that self-resolve and self-target.
class Ludo3MagicMatchPage extends ConsumerStatefulWidget {
  const Ludo3MagicMatchPage({super.key, required this.mode, this.difficulty = LudoDifficulty.normal});
  final LudoMode mode;
  final LudoDifficulty difficulty;

  @override
  ConsumerState<Ludo3MagicMatchPage> createState() => _MagicMatchState();
}

class _MagicMatchState extends ConsumerState<Ludo3MagicMatchPage> {
  late MagicController _ctrl;
  final _rng = math.Random();
  bool _muted = false;
  bool _overShown = false;
  LudoBoardSkin _skin = LudoBoardSkin.royal;
  LudoPawnStyle _pawn = LudoPawnStyle.classic;
  String? _myChat, _botChat, _magicToast;
  Timer? _myChatTimer, _botChatTimer, _toastTimer;

  static const _coins = [1430, 1250, 1870, 1430];

  @override
  void initState() {
    super.initState();
    CarromSfx.instance.init();
    ref.read(interstitialAdServiceProvider).preload();
    Ludo3Prefs.instance().then((p) {
      if (!mounted) return;
      setState(() {
        _skin = p.boardSkin;
        _pawn = p.pawnStyle;
      });
    });
    _start();
  }

  void _start() {
    _overShown = false;
    final names = ['أنت', for (var i = 1; i < widget.mode.seats; i++) 'بوت $i'];
    final state = LudoState.local(mode: widget.mode, names: names);
    _ctrl = MagicController(state: state, humanSeats: {0}, difficulty: widget.difficulty);
    _ctrl.onRollSfx = () { _sfx(() => CarromSfx.instance.hit(0.6)); };
    _ctrl.onMoveSfx = () { _sfx(() => CarromSfx.instance.hit(0.4)); };
    _ctrl.onCaptureSfx = () { _sfx(() => CarromSfx.instance.pocket()); };
    _ctrl.onFinishSfx = () { _sfx(() => CarromSfx.instance.pocket()); };
    _ctrl.onMagic = _onMagic;
    _ctrl.onMoveApplied = _onMoveApplied;
    _ctrl.onGameOver = (_, __) {
      _sfx(() => CarromSfx.instance.win());
      ref.read(interstitialAdServiceProvider).onMatchCompleted();
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGameOver());
    };
    _ctrl.addListener(_onTick);
    setState(() {});
  }

  void _sfx(void Function() play) {
    if (_muted) return;
    CarromSfx.instance.enabled = true;
    play();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    CarromSfx.instance.enabled = !_muted;
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _onMagic(MagicEvent e) {
    final text = switch (e.kind) {
      'shield' => '🛡️ درع تلقائي على أهم قطعة',
      'shieldBreak' => '🛡️💥 انكسر الدرع — نجت القطعة',
      'freeze' => '❄️ تجميد الخصم الأخطر',
      'frozenSkip' => '❄️ دور متجمّد — تخطّيناه',
      'wormhole' => '🌀 ثقب دودي — انتقال!',
      'mystery' => switch (e.detail) {
          'shield' => '🎁 صندوق سحري: درع!',
          'freeze' => '🎁 صندوق سحري: تجميد!',
          'extraRoll' => '🎁 صندوق سحري: رمية إضافية!',
          _ => '🎁 صندوق سحري: لعنة — رجعت للخلف',
        },
      _ => null,
    };
    if (text == null) return;
    _sfx(() => CarromSfx.instance.pocket());
    setState(() => _magicToast = text);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _magicToast = null);
    });
  }

  void _onMoveApplied(int seat, bool captured, bool finished, bool six) {
    final isHuman = _ctrl.humanSeats.contains(seat);
    if (isHuman) {
      if (captured) {
        _say('🔥 رجعتك البيت!', human: true);
      } else if (finished) {
        _say('🏠 وحدة وصلت!', human: true);
      }
      return;
    }
    if (captured && _rng.nextDouble() < 0.85) {
      _say(['😎 شوف وتعلّم', '😏 رجعتك البيت!', '🎯 بالضبط'][_rng.nextInt(3)], human: false);
    } else if (_rng.nextDouble() < 0.16) {
      final c = kLudoChat[_rng.nextInt(kLudoChat.length)];
      _say('${c.emoji} ${c.text}', human: false);
    }
  }

  void _say(String text, {required bool human}) {
    if (human) {
      setState(() => _myChat = text);
      _myChatTimer?.cancel();
      _myChatTimer = Timer(const Duration(milliseconds: 2600), () {
        if (mounted) setState(() => _myChat = null);
      });
    } else {
      setState(() => _botChat = text);
      _botChatTimer?.cancel();
      _botChatTimer = Timer(const Duration(milliseconds: 2600), () {
        if (mounted) setState(() => _botChat = null);
      });
    }
  }

  @override
  void dispose() {
    _myChatTimer?.cancel();
    _botChatTimer?.cancel();
    _toastTimer?.cancel();
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  bool get _humanWon {
    final s = _ctrl.state;
    final me = s.playerBySeat(0);
    return widget.mode == LudoMode.team2v2
        ? (me != null && s.winnerTeam == teamOf(me.color))
        : s.winnerUserId == me?.userId;
  }

  Future<void> _showGameOver() async {
    if (_overShown || !mounted) return;
    _overShown = true;
    final won = _humanWon;
    String? q;
    if (!won) {
      q = await ref.read(randomQuestionRepoProvider).fetch(fallback: 'وش أكثر شي يفرحك؟');
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2330),
        title: Text(won ? '🎉 فزت!' : '😮 خسرت',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(won ? 'سيطرت بالسحر ووصلت أول!' : (q ?? 'حظ أوفر المرة الجاية'),
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); Navigator.maybePop(context); }, child: const Text('خروج')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.removeListener(_onTick);
              _ctrl.dispose();
              _start();
            },
            child: const Text('إعادة'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmExit() async {
    if (_ctrl.state.status == LudoStatus.finished) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2330),
        title: const Text('تترك اللعبة؟', style: TextStyle(color: Colors.white)),
        content: const Text('إذا طلعت بينتهي الشوط ويفوز الخصم.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('أكمل')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('اطلع')),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final s = _ctrl.state;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmExit();
        if (!leave || !context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment(0, -0.8), radius: 1.3, colors: [_bgTop, _bgBottom]),
          ),
          child: SafeArea(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Stack(
              children: [
                Column(
                  children: [
                    _topBar(s),
                    _topCards(s),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Ludo3Board(
                              state: s,
                              movable: _ctrl.canSelect ? _ctrl.movable : const [],
                              activeSeat: s.turnSeat,
                              interactive: _ctrl.canSelect,
                              onTapToken: (i) => _ctrl.applyTokenMove(i),
                              mysteryCells: kMysteryTiles,
                              wormholeCells: kWormholes.keys.toSet(),
                              skin: _skin,
                              pawnStyle: _pawn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _bottomArea(s),
                    _buttonsRow(),
                  ],
                ),
                if (_botChat != null) Positioned(top: 96, left: 16, child: _bubble(_botChat!, false)),
                if (_myChat != null) Positioned(bottom: 150, right: 16, child: _bubble(_myChat!, true)),
                if (_magicToast != null)
                  Positioned(top: 8, left: 0, right: 0, child: Center(child: _toast(_magicToast!))),
                if (_ctrl.autopilotFlash)
                  Positioned(top: 50, left: 0, right: 0, child: Center(child: _flash('⏱️ انتهى وقتك — لعبنا بدالك'))),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(LudoState s) {
    final isHuman = _ctrl.isHumanTurn;
    final turnText = s.status == LudoStatus.finished
        ? 'انتهت'
        : isHuman ? 'دورك' : 'دور ${s.current?.name ?? ''}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBtn(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, _toggleMute),
          const Spacer(),
          Column(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFFC9A6FF), size: 26),
              const SizedBox(height: 2),
              _turnPill(turnText),
              const SizedBox(height: 6),
              _countdown(s),
            ],
          ),
          const Spacer(),
          _coinsPill(2450),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );

  Widget _turnPill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF14102E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accent, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF43BD3F), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      );

  Widget _countdown(LudoState s) {
    final showTimer = _ctrl.isHumanTurn && (_ctrl.canRoll || _ctrl.canSelect) && s.status == LudoStatus.playing;
    final frac = showTimer ? (_ctrl.secondsLeft / MagicController.turnSeconds).clamp(0.0, 1.0) : 1.0;
    final val = showTimer ? '${_ctrl.secondsLeft}' : '•';
    return SizedBox(
      width: 50, height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50, height: 50,
            child: CircularProgressIndicator(
              value: frac,
              strokeWidth: 4,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: AlwaysStoppedAnimation(frac > 0.4 ? const Color(0xFF43BD3F) : const Color(0xFFE23B32)),
            ),
          ),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _coinsPill(int coins) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF14102E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('$coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(color: Color(0xFF2FA84F), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ],
        ),
      );

  Widget _topCards(LudoState s) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _playerCard(s, LudoColor.red, avatarLeft: true),
            _playerCard(s, LudoColor.green, avatarLeft: false),
          ],
        ),
      );

  Widget _bottomArea(LudoState s) {
    final cur = s.current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(child: _playerCard(s, LudoColor.blue, avatarLeft: true)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: _diceRing(cur?.color ?? LudoColor.blue)),
          Expanded(child: _playerCard(s, LudoColor.yellow, avatarLeft: false)),
        ],
      ),
    );
  }

  Widget _diceRing(LudoColor color) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFF2A1F55), Color(0xFF14102E)]),
              border: Border.all(color: _accent, width: 2),
              boxShadow: _ctrl.canRoll ? [BoxShadow(color: _accent.withValues(alpha: 0.7), blurRadius: 16, spreadRadius: 1)] : null,
            ),
            child: LudoDice(
              value: _ctrl.dice,
              rolling: _ctrl.diceRolling,
              enabled: _ctrl.canRoll,
              color: color,
              size: 50,
              onTap: _ctrl.humanRoll,
            ),
          ),
          _pendingChips(),
        ],
      );

  Widget _pendingChips() {
    final pending = _ctrl.pending;
    final show = pending.isNotEmpty && (pending.length > 1 || _ctrl.isRollingPhase);
    if (!show) return const SizedBox(height: 4);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < pending.length; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 20, height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (_ctrl.isMoving && i == 0) ? _accent : const Color(0xFF14102E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: (_ctrl.isMoving && i == 0) ? Colors.white : Colors.white24),
              ),
              child: Text('${pending[i]}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _playerCard(LudoState s, LudoColor color, {required bool avatarLeft}) {
    final p = s.players.where((x) => x.color == color).firstOrNull;
    if (p == null) return const SizedBox(width: 110);
    final active = s.turnSeat == p.seat && s.status == LudoStatus.playing;
    final frozen = _ctrl.magic.isFrozen(p.seat);
    final avatar = Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.light, color.dark]),
        border: Border.all(color: color.base, width: 2),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
    );
    final info = Column(
      crossAxisAlignment: avatarLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (frozen) const Text('❄️ ', style: TextStyle(fontSize: 12)),
            Text(p.name ?? color.wire, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text('${_coins[p.seat % 4]}', style: const TextStyle(color: Color(0xFFE3BD5E), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 4; i++)
              Opacity(
                opacity: p.tokens[i].position == kFinishedPosition ? 0.3 : 1,
                child: LudoPawnPreview(color: color, style: _pawn, size: 13),
              ),
          ],
        ),
      ],
    );
    final children = avatarLeft ? [avatar, const SizedBox(width: 8), info] : [info, const SizedBox(width: 8), avatar];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14102E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? color.base : Colors.white12, width: active ? 2 : 1),
        boxShadow: active ? [BoxShadow(color: color.base.withValues(alpha: 0.55), blurRadius: 14)] : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buttonsRow() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            _pillBtn('💬 دردشة', const Color(0xFF14102E), _openChatSheet, border: Colors.white24),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _ctrl.canRoll ? _ctrl.humanRoll : null,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_accent, Color(0xFF4B2FA0)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _ctrl.canRoll ? [BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 12)] : null,
                  ),
                  child: const Text('ارم النرد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _pillBtn('خروج ↩', const Color(0x33E23B32), () => Navigator.maybePop(context),
                border: const Color(0xFFE23B32), textColor: const Color(0xFFFF8A80)),
          ],
        ),
      );

  Widget _pillBtn(String label, Color bg, VoidCallback onTap, {Color border = Colors.transparent, Color textColor = Colors.white}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      );

  void _openChatSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B2330),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in kLudoChat)
              ActionChip(
                backgroundColor: const Color(0xFF2A3444),
                label: Text('${c.emoji} ${c.text}', style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.maybePop(context);
                  _say('${c.emoji} ${c.text}', human: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _flash(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      );

  Widget _toast(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_accent, Color(0xFF2475E0)]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10)],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );

  Widget _bubble(String text, bool mine) => Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: mine ? _accent : const Color(0xFF2A3444), borderRadius: BorderRadius.circular(16)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );
}

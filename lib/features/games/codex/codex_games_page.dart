import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/haptics/game_haptics.dart';

class CodexLudoPage extends StatefulWidget {
  const CodexLudoPage({super.key});

  @override
  State<CodexLudoPage> createState() => _CodexLudoPageState();
}

class _CodexLudoPageState extends State<CodexLudoPage> {
  final _rng = Random();
  final _positions = List<int>.filled(4, 0);
  final _frozen = List<int>.filled(4, 0);
  int _turn = 0;
  int _dice = 0;
  String _event = 'كود اكس لودو: اضغط النرد وراقب القدرات';

  static const _finish = 32;
  static const _rockets = <int>{5, 18};
  static const _freeze = <int>{9, 24};
  static const _gates = <int, int>{12: 22, 26: 15};
  static const _cyclones = <int>{7, 28};

  Color _color(int player) => const [
        Color(0xFFE73F46),
        Color(0xFF23B965),
        Color(0xFFFFC857),
        Color(0xFF3B82F6),
      ][player];

  void _roll() {
    if (_positions[_turn] >= _finish) {
      _nextTurn();
      return;
    }
    if (_frozen[_turn] > 0) {
      setState(() {
        _frozen[_turn] -= 1;
        _event = 'اللاعب ${_turn + 1} مجمد، بقي ${_frozen[_turn]}';
      });
      GameHaptics.capture();
      _nextTurn(delay: 500);
      return;
    }
    final roll = _rng.nextInt(6) + 1;
    var next = min(_finish, _positions[_turn] + roll);
    var text = 'اللاعب ${_turn + 1} رمى $roll';

    if (_rockets.contains(next)) {
      final boost = _rng.nextInt(6) + 1;
      next = min(_finish, next + boost);
      text = 'صاروخ كود اكس: +$boost خطوات';
      GameHaptics.uiPop();
    } else if (_freeze.contains(next)) {
      final target = (_turn + 1) % 4;
      _frozen[target] = 3;
      text = 'تجميد اللاعب ${target + 1} لثلاث رميات';
      GameHaptics.capture();
    } else if (_gates.containsKey(next)) {
      next = _gates[next]!;
      text = 'بوابة كود اكس نقلتك إلى خانة $next';
      GameHaptics.uiPop();
    } else if (_cyclones.contains(next)) {
      next = _rng.nextInt(_finish - 3) + 2;
      text = 'إعصار: موقع جديد غير متوقع';
      GameHaptics.capture();
    }

    setState(() {
      _dice = roll;
      _positions[_turn] = next;
      _event = next >= _finish ? 'اللاعب ${_turn + 1} وصل للنهاية' : text;
    });
    GameHaptics.diceRoll();
    _nextTurn(
        delay: roll == 6 && next < _finish ? 900 : 650,
        keepTurn: roll == 6 && next < _finish);
  }

  void _nextTurn({int delay = 0, bool keepTurn = false}) {
    Future<void>.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      if (keepTurn) {
        setState(() => _event = 'ستة: اللاعب ${_turn + 1} يلعب مرة أخرى');
        return;
      }
      var next = _turn;
      for (var i = 0; i < 4; i++) {
        next = (next + 1) % 4;
        if (_positions[next] < _finish) break;
      }
      setState(() => _turn = next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      appBar: _CodexAppBar(title: 'كود اكس لودو', colors: colors),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: _CodexPowerStrip(colors: colors),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _LudoScoreRow(
                  turn: _turn,
                  positions: _positions,
                  frozen: _frozen,
                  colorOf: _color),
            ),
            const Gap(10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: CustomPaint(
                  painter: _CodexLudoPainter(
                      positions: _positions, turn: _turn, colorOf: _color),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: Row(
                children: [
                  Expanded(child: _CodexStatus(text: _event, colors: colors)),
                  const Gap(12),
                  _CodexDice(dice: _dice, onTap: _roll),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CodexCarromPage extends StatefulWidget {
  const CodexCarromPage({super.key});

  @override
  State<CodexCarromPage> createState() => _CodexCarromPageState();
}

class _CodexCarromPageState extends State<CodexCarromPage> {
  final _rng = Random();
  final List<Offset> _coins = [];
  Offset _striker = const Offset(.5, .84);
  Offset? _drag;
  int _score = 0;
  String _status = 'اسحب من المضرب ثم اتركه للتصويب';

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _coins
      ..clear()
      ..addAll([
        const Offset(.5, .48),
        const Offset(.46, .44),
        const Offset(.54, .44),
        const Offset(.42, .50),
        const Offset(.58, .50),
        const Offset(.46, .56),
        const Offset(.54, .56),
        const Offset(.5, .40),
        const Offset(.5, .60),
      ]);
    _striker = const Offset(.5, .84);
    _score = 0;
    _status = 'كود اكس كيرم: اسحب واضرب';
  }

  void _shoot(Size size) {
    if (_drag == null) return;
    final start = Offset(_striker.dx * size.width, _striker.dy * size.height);
    final vector = start - _drag!;
    if (vector.distance < 16) return;
    final direction = vector / vector.distance;
    final travel = min(size.width * .45, vector.distance * 1.7);
    final endPx = start + direction * travel;
    final end = Offset((endPx.dx / size.width).clamp(.08, .92),
        (endPx.dy / size.height).clamp(.08, .92));

    var hit = -1;
    var best = 999.0;
    for (var i = 0; i < _coins.length; i++) {
      final coinPx =
          Offset(_coins[i].dx * size.width, _coins[i].dy * size.height);
      final d = _distanceToSegment(coinPx, start, endPx);
      if (d < best) {
        best = d;
        hit = i;
      }
    }

    setState(() {
      _striker = end;
      _drag = null;
      if (hit >= 0 && best < 34) {
        final coin = _coins.removeAt(hit);
        final pocketed = coin.dx < .25 ||
            coin.dx > .75 ||
            coin.dy < .25 ||
            coin.dy > .75 ||
            _rng.nextBool();
        if (pocketed) {
          _score += 1;
          _status = 'ضربة ناجحة: +1';
          GameHaptics.capture();
        } else {
          _status = 'لم تدخل القطعة، عدّل الزاوية';
          GameHaptics.tap();
        }
      } else {
        _status = 'لم تلمس قطعة';
        GameHaptics.tap();
      }
      if (_coins.isEmpty) _status = 'أنهيت الطاولة بنتيجة $_score';
    });
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final t =
        (ap.dx * ab.dx + ap.dy * ab.dy) / max(1, ab.dx * ab.dx + ab.dy * ab.dy);
    final clamped = t.clamp(0.0, 1.0);
    return (p - (a + ab * clamped)).distance;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      appBar: _CodexAppBar(title: 'كود اكس كيرم', colors: colors),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  Expanded(child: _CodexStatus(text: _status, colors: colors)),
                  const Gap(10),
                  _ScoreBadge(score: _score),
                ],
              ),
            ),
            const Gap(12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final size = Size(c.maxWidth, c.maxWidth);
                    return Center(
                      child: GestureDetector(
                        onPanStart: (d) =>
                            setState(() => _drag = d.localPosition),
                        onPanUpdate: (d) =>
                            setState(() => _drag = d.localPosition),
                        onPanEnd: (_) => _shoot(size),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CustomPaint(
                            painter: _CodexCarromPainter(
                                coins: _coins, striker: _striker, drag: _drag),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(_reset),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('إعادة الطاولة'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodexAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CodexAppBar({required this.title, required this.colors});
  final String title;
  final SarhnyColors colors;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF070A12),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () => context.go(AppRoutes.gamesHub),
      ),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      centerTitle: false,
    );
  }
}

class _CodexPowerStrip extends StatelessWidget {
  const _CodexPowerStrip({required this.colors});
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
            child: _PowerCard(
                label: 'صاروخ',
                icon: Icons.rocket_launch_rounded,
                color: Color(0xFFFF7A1A))),
        Gap(8),
        Expanded(
            child: _PowerCard(
                label: 'تجميد',
                icon: Icons.ac_unit_rounded,
                color: Color(0xFF38BDF8))),
        Gap(8),
        Expanded(
            child: _PowerCard(
                label: 'بوابة',
                icon: Icons.door_front_door_rounded,
                color: Color(0xFFA66BFF))),
        Gap(8),
        Expanded(
            child: _PowerCard(
                label: 'إعصار',
                icon: Icons.cyclone_rounded,
                color: Color(0xFF15C6A8))),
      ],
    );
  }
}

class _PowerCard extends StatelessWidget {
  const _PowerCard(
      {required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: .45)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 18),
        const Gap(3),
        FittedBox(
            child: Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w900, fontSize: 11))),
      ]),
    );
  }
}

class _CodexStatus extends StatelessWidget {
  const _CodexStatus({required this.text, required this.colors});
  final String text;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: .55)),
      ),
      alignment: Alignment.center,
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13)),
    );
  }
}

class _CodexDice extends StatelessWidget {
  const _CodexDice({required this.dice, required this.onTap});
  final int dice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB13B),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFFB13B).withValues(alpha: .32),
                blurRadius: 24)
          ],
        ),
        alignment: Alignment.center,
        child: Text(dice == 0 ? 'رمي' : dice.toString(),
            style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _LudoScoreRow extends StatelessWidget {
  const _LudoScoreRow(
      {required this.turn,
      required this.positions,
      required this.frozen,
      required this.colorOf});
  final int turn;
  final List<int> positions;
  final List<int> frozen;
  final Color Function(int) colorOf;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final active = turn == i;
        final color = colorOf(i);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: active ? .28 : .12),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: color.withValues(alpha: active ? .9 : .35)),
            ),
            child: Column(children: [
              Text('P${i + 1}',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w900, fontSize: 11)),
              const Gap(3),
              Text(frozen[i] > 0 ? 'ثلج ${frozen[i]}' : '${positions[i]}/32',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10)),
            ]),
          ),
        );
      }),
    );
  }
}

class _CodexLudoPainter extends CustomPainter {
  const _CodexLudoPainter(
      {required this.positions, required this.turn, required this.colorOf});
  final List<int> positions;
  final int turn;
  final Color Function(int) colorOf;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
              colors: [Color(0xFF10162A), Color(0xFF151A34), Color(0xFF0A2730)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(rect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(26)), bg);
    final center = rect.center;
    final radius = size.shortestSide * .38;
    final points = List.generate(32, (i) {
      final a = -pi / 2 + i * pi * 2 / 32;
      return center + Offset(cos(a) * radius, sin(a) * radius);
    });
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .11
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .08);
    canvas.drawPath(Path()..addPolygon(points, true), track);
    for (var i = 0; i < points.length; i++) {
      final special = {5, 7, 9, 12, 18, 24, 26, 28}.contains(i);
      canvas.drawCircle(
          points[i],
          size.shortestSide * (special ? .033 : .025),
          Paint()
            ..color =
                special ? const Color(0xFFFFD166) : const Color(0xFFEAF0FF));
    }
    final homeCenters = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomRight,
      Alignment.bottomLeft
    ];
    for (var p = 0; p < 4; p++) {
      final zone = homeCenters[p].inscribe(
          Size(size.width * .26, size.height * .26), rect.deflate(22));
      canvas.drawRRect(RRect.fromRectAndRadius(zone, const Radius.circular(20)),
          Paint()..color = colorOf(p).withValues(alpha: .88));
      canvas.drawCircle(zone.center, size.shortestSide * .055,
          Paint()..color = Colors.white.withValues(alpha: .88));
      final pos = positions[p];
      final pawnCenter =
          pos >= 32 ? center : points[(p * 8 + pos).clamp(0, 31)];
      canvas.drawCircle(
          pawnCenter + const Offset(0, 3),
          size.shortestSide * .038,
          Paint()..color = Colors.black.withValues(alpha: .35));
      canvas.drawCircle(
          pawnCenter,
          size.shortestSide * (turn == p ? .044 : .037),
          Paint()..color = colorOf(p));
      canvas.drawCircle(pawnCenter, size.shortestSide * .018,
          Paint()..color = Colors.white.withValues(alpha: .35));
    }
    canvas.drawCircle(center, size.shortestSide * .09,
        Paint()..color = Colors.white.withValues(alpha: .92));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CodexCarromPainter extends CustomPainter {
  const _CodexCarromPainter(
      {required this.coins, required this.striker, required this.drag});
  final List<Offset> coins;
  final Offset striker;
  final Offset? drag;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final board =
        RRect.fromRectAndRadius(rect.deflate(10), const Radius.circular(28));
    final bg = Paint()
      ..shader = const LinearGradient(
              colors: [Color(0xFFD29A43), Color(0xFFF5D98C), Color(0xFFC48732)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(rect);
    canvas.drawRRect(board, bg);
    final rail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = const Color(0xFF44240F);
    canvas.drawRRect(board.deflate(14), rail);
    final pocket = Paint()..color = const Color(0xFF090604);
    for (final p in [
      board.outerRect.topLeft + const Offset(25, 25),
      board.outerRect.topRight + const Offset(-25, 25),
      board.outerRect.bottomLeft + const Offset(25, -25),
      board.outerRect.bottomRight + const Offset(-25, -25)
    ]) {
      canvas.drawCircle(p, 24, pocket);
    }
    final center = rect.center;
    canvas.drawCircle(
        center,
        size.width * .13,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: .35));
    for (var i = 0; i < coins.length; i++) {
      final p = Offset(coins[i].dx * size.width, coins[i].dy * size.height);
      canvas.drawCircle(p + const Offset(0, 2), 13,
          Paint()..color = Colors.black.withValues(alpha: .25));
      canvas.drawCircle(
          p,
          12,
          Paint()
            ..color = i == 0
                ? const Color(0xFFC80034)
                : (i.isEven
                    ? const Color(0xFFF7EFE0)
                    : const Color(0xFF17110E)));
    }
    final s = Offset(striker.dx * size.width, striker.dy * size.height);
    if (drag != null) {
      canvas.drawLine(
          s,
          drag!,
          Paint()
            ..color = Colors.white.withValues(alpha: .75)
            ..strokeWidth = 3);
      canvas.drawCircle(
          drag!, 8, Paint()..color = Colors.white.withValues(alpha: .8));
    }
    canvas.drawCircle(s + const Offset(0, 3), 18,
        Paint()..color = Colors.black.withValues(alpha: .25));
    canvas.drawCircle(s, 18, Paint()..color = Colors.white);
    canvas.drawCircle(s, 7, Paint()..color = const Color(0xFF3B82F6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 58,
      decoration: BoxDecoration(
          color: const Color(0xFFFFB13B),
          borderRadius: BorderRadius.circular(18)),
      alignment: Alignment.center,
      child: Text(score.toString(),
          style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900)),
    );
  }
}

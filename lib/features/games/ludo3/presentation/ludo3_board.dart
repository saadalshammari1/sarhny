import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/ludo_cosmetics.dart';
import '../engine/ludo_geometry.dart';
import '../engine/ludo_models.dart';
import '../engine/ludo_rules.dart';

String _tk(LudoColor c, int i) => '${c.wire}_$i';

/// The Ludo board: a richly painted 15×15 background (wood frame, glossy homes,
/// inlaid track, glowing stars, a 3D centre) with tokens layered on top as
/// [AnimatedPositioned] widgets so every move and capture glides for free. Tap
/// a highlighted token to move it.
class Ludo3Board extends StatefulWidget {
  const Ludo3Board({
    super.key,
    required this.state,
    required this.movable,
    required this.activeSeat,
    required this.interactive,
    required this.onTapToken,
    this.highlightCells = const {},
    this.targetableCells = const {},
    this.onTargetCell,
    this.canTargetToken,
    this.onTargetToken,
    this.portalFirst,
    this.mysteryCells = const {},
    this.wormholeCells = const {},
    this.trapCells = const {},
    this.skin = LudoBoardSkin.royal,
    this.pawnStyle = LudoPawnStyle.classic,
  });

  final LudoState state;
  final List<int> movable; // token indices movable THIS turn (active seat)
  final int activeSeat;
  final bool interactive;
  final void Function(int tokenIndex) onTapToken;

  /// Optional set of track indices to highlight (magic-mode targeting).
  final Set<int> highlightCells;

  /// Magic targeting: track cells the player can tap, and the callback.
  final Set<int> targetableCells;
  final void Function(int trackIndex)? onTargetCell;

  /// Magic targeting: which tokens are tappable, and the callback.
  final bool Function(LudoColor color, int idx)? canTargetToken;
  final void Function(LudoColor color, int idx)? onTargetToken;

  /// First portal cell already picked (drawn distinctly).
  final int? portalFirst;

  /// Magic board elements to draw: Mystery Boxes, Quantum Wormholes, and the
  /// viewer's own Shadow Traps (track indices).
  final Set<int> mysteryCells;
  final Set<int> wormholeCells;
  final Set<int> trapCells;

  /// Selected cosmetics.
  final LudoBoardSkin skin;
  final LudoPawnStyle pawnStyle;

  @override
  State<Ludo3Board> createState() => _Ludo3BoardState();
}

class _Ludo3BoardState extends State<Ludo3Board>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _move;

  /// Last-seen position per token, to detect a move and walk it cell-by-cell.
  final Map<String, int> _lastPos = {};

  /// The token currently walking, and its path of cell-unit centres.
  String? _animKey;
  List<Offset>? _animPath;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 150))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          setState(() {
            _animKey = null;
            _animPath = null;
          });
        }
      });
    for (final p in widget.state.players) {
      for (final t in p.tokens) {
        _lastPos[_tk(p.color, t.index)] = t.position;
      }
    }
  }

  @override
  void didUpdateWidget(Ludo3Board old) {
    super.didUpdateWidget(old);
    _detectMove();
  }

  /// Find a single token that advanced 1..6 sequential steps and animate it
  /// along the real track path. Other position changes (captures home,
  /// teleports) fall through to the AnimatedPositioned glide.
  void _detectMove() {
    for (final p in widget.state.players) {
      for (final t in p.tokens) {
        final k = _tk(p.color, t.index);
        final prev = _lastPos[k];
        final cur = t.position;
        if (prev == null || prev == cur) continue;
        // Is `cur` reachable from `prev` in 1..6 forward steps?
        final path = _sequentialPath(p.color, prev, cur, t.index);
        _lastPos[k] = cur;
        if (path != null && _animKey == null) {
          _animKey = k;
          _animPath = path;
          _move.duration = Duration(milliseconds: (path.length - 1) * kStepMs);
          _move.forward(from: 0);
        }
      }
    }
  }

  List<Offset>? _sequentialPath(LudoColor color, int from, int to, int idx) {
    for (var k = 1; k <= 6; k++) {
      if (projectPosition(color, from, k) == to) {
        final pts = <Offset>[LudoGeometry.tokenCenter(color, from, idx)];
        for (var j = 1; j <= k; j++) {
          final pos = projectPosition(color, from, j);
          if (pos != null) pts.add(LudoGeometry.tokenCenter(color, pos, idx));
        }
        return pts.length >= 2 ? pts : null;
      }
    }
    return null;
  }

  Offset _along(List<Offset> pts, double t) {
    final n = pts.length - 1;
    if (n <= 0) return pts.first;
    final x = (t * n).clamp(0.0, n.toDouble());
    final i = x.floor().clamp(0, n - 1);
    return Offset.lerp(pts[i], pts[i + 1], x - i)!;
  }

  @override
  void dispose() {
    _pulse.dispose();
    _move.dispose();
    super.dispose();
  }

  /// Compute a render offset (in cell units) for every token, fanning out
  /// tokens that share a cell so a stack stays readable.
  Map<({LudoColor color, int idx}), Offset> _layout() {
    final out = <({LudoColor color, int idx}), Offset>{};
    final byCell = <String, List<({LudoColor color, int idx})>>{};

    for (final p in widget.state.players) {
      for (final t in p.tokens) {
        final c = LudoGeometry.tokenCenter(p.color, t.position, t.index);
        final key = (color: p.color, idx: t.index);
        out[key] = c;
        if (t.position != kHomeBasePosition) {
          final ck = '${c.dx.toStringAsFixed(2)},${c.dy.toStringAsFixed(2)}';
          (byCell[ck] ??= []).add(key);
        }
      }
    }

    for (final group in byCell.values) {
      if (group.length < 2) continue;
      const r = 0.26;
      for (var i = 0; i < group.length; i++) {
        final ang = (2 * math.pi / group.length) * i - math.pi / 2;
        final base = out[group[i]]!;
        out[group[i]] = base + Offset(r * math.cos(ang), r * math.sin(ang));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.maxWidth;
        final cell = size / LudoGeometry.grid;
        final layout = _layout();
        // Compact 3D pawn: footprint sits on the cell, head just above it.
        final pieceW = cell * 0.74;
        final pieceH = pieceW * 1.24;
        double leftOf(double cxUnits) => cxUnits * cell - pieceW / 2;
        double topOf(double cyUnits) => cyUnits * cell - pieceH + pieceW * 0.62;

        final tokens = <Widget>[];
        for (final p in widget.state.players) {
          for (final t in p.tokens) {
            final key = (color: p.color, idx: t.index);
            final centre = layout[key]!;
            final isMovable = widget.interactive &&
                p.seat == widget.activeSeat &&
                widget.movable.contains(t.index);
            final isTargetable =
                widget.canTargetToken?.call(p.color, t.index) ?? false;
            final color = p.color;
            final idx = t.index;
            VoidCallback? onTap;
            if (isTargetable) {
              onTap = () => widget.onTargetToken?.call(color, idx);
            } else if (isMovable) {
              onTap = () => widget.onTapToken(idx);
            }

            final tokenWidget = _TokenWidget(
              color: p.color,
              movable: isMovable || isTargetable,
              pulse: _pulse,
              style: widget.pawnStyle,
              onTap: onTap,
            );

            final k = _tk(p.color, t.index);
            if (k == _animKey && _animPath != null) {
              // Walk the token cell-by-cell along its real path.
              tokens.add(AnimatedBuilder(
                animation: _move,
                builder: (context, child) {
                  final pos = _along(_animPath!, _move.value);
                  return Positioned(
                    left: leftOf(pos.dx),
                    top: topOf(pos.dy),
                    width: pieceW,
                    height: pieceH,
                    child: child!,
                  );
                },
                child: tokenWidget,
              ));
            } else {
              tokens.add(AnimatedPositioned(
                key: ValueKey('tok_${p.color.wire}_${t.index}'),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                left: leftOf(centre.dx),
                top: topOf(centre.dy),
                width: pieceW,
                height: pieceH,
                child: tokenWidget,
              ));
            }
          }
        }

        // Persistent magic hazards drawn on their track cells.
        final hazards = <Widget>[];
        Widget hazardIcon(int i, String emoji, Color glow) {
          final c = LudoGeometry.trackCenter(i);
          return Positioned(
            left: c.dx * cell - cell / 2,
            top: c.dy * cell - cell / 2,
            width: cell,
            height: cell,
            child: IgnorePointer(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.6), blurRadius: 8)],
                ),
                child: Text(emoji, style: TextStyle(fontSize: cell * 0.6)),
              ),
            ),
          );
        }

        for (final i in widget.mysteryCells) {
          hazards.add(hazardIcon(i, '🎁', Colors.amberAccent));
        }
        for (final i in widget.wormholeCells) {
          hazards.add(hazardIcon(i, '🌀', Colors.cyanAccent));
        }
        for (final i in widget.trapCells) {
          hazards.add(hazardIcon(i, '🕳️', Colors.redAccent));
        }

        final glowCells = {...widget.highlightCells, ...widget.targetableCells};
        final cellTaps = <Widget>[];
        for (final i in widget.targetableCells) {
          if (i < 0 || i >= LudoGeometry.track.length) continue;
          final c = LudoGeometry.trackCenter(i);
          cellTaps.add(Positioned(
            left: c.dx * cell - cell / 2,
            top: c.dy * cell - cell / 2,
            width: cell,
            height: cell,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onTargetCell?.call(i),
              child: i == widget.portalFirst
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(cell * 0.2),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ));
        }

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                    painter: _BoardPainter(
                  highlight: widget.highlightCells,
                  theme: LudoBoardTheme.of(widget.skin),
                )),
              ),
              if (glowCells.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _HighlightPainter(glowCells, _pulse),
                    ),
                  ),
                ),
              ...hazards,
              ...tokens,
              ...cellTaps,
            ],
          ),
        );
      },
    );
  }
}

class _TokenWidget extends StatelessWidget {
  const _TokenWidget({
    required this.color,
    required this.movable,
    required this.pulse,
    required this.style,
    this.onTap,
  });

  final LudoColor color;
  final bool movable;
  final Animation<double> pulse;
  final LudoPawnStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final glow = movable ? (0.5 + 0.5 * pulse.value) : 0.0;
          return CustomPaint(
              painter: _PawnPainter(color: color, glow: glow, style: style));
        },
      ),
    );
  }
}

/// Warm gold ramp used for the premium piece toppers + accents.
const List<Color> _goldRamp = [
  Color(0xFFFFF6D6), Color(0xFFF0D488), Color(0xFFE3BD5E),
  Color(0xFFB8893A), Color(0xFF7A531A),
];

/// A standalone pawn preview (used by the cosmetics picker).
class LudoPawnPreview extends StatelessWidget {
  const LudoPawnPreview({
    super.key,
    required this.color,
    required this.style,
    this.size = 40,
  });
  final LudoColor color;
  final LudoPawnStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.5,
      child: CustomPaint(painter: _PawnPainter(color: color, glow: 0, style: style)),
    );
  }
}

/// A tall, glossy 3D chess-style piece (base + tapered body + spherical head)
/// crowned with a gold topper unique to each style. Premium "glory" look with
/// strong speculars, a gold collar, and a halo when it's movable.
class _PawnPainter extends CustomPainter {
  _PawnPainter({required this.color, required this.glow, required this.style});
  final LudoColor color;
  final double glow;
  final LudoPawnStyle style;

  Shader _gold(Rect r) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _goldRamp,
      ).createShader(r);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final headC = Offset(cx, h * 0.4);
    final headR = w * 0.38;

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.94), width: w * 0.66, height: w * 0.2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.38)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.045),
    );

    // Movable halo.
    if (glow > 0) {
      canvas.drawCircle(
        headC,
        headR * (1.3 + 0.2 * glow),
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.3 + 0.4 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.07),
      );
    }

    // ── Flared base ───────────────────────────────────────────────────────
    final baseRect = Rect.fromCenter(
        center: Offset(cx, h * 0.86), width: w * 0.74, height: w * 0.28);
    canvas.drawOval(
      baseRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.6),
          colors: [color.base, color.dark, color.deep],
          stops: const [0, 0.6, 1],
        ).createShader(baseRect),
    );

    // ── Neck (connects base to head) ──────────────────────────────────────
    final neck = Path()
      ..moveTo(cx - w * 0.26, h * 0.86)
      ..quadraticBezierTo(cx - w * 0.18, h * 0.62, cx - w * 0.2, h * 0.5)
      ..lineTo(cx + w * 0.2, h * 0.5)
      ..quadraticBezierTo(cx + w * 0.18, h * 0.62, cx + w * 0.26, h * 0.86)
      ..close();
    final neckRect = Rect.fromLTWH(cx - w * 0.26, h * 0.5, w * 0.52, h * 0.36);
    canvas.drawPath(
      neck,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.6),
          radius: 1.2,
          colors: [color.light, color.base, color.mid, color.dark],
          stops: const [0, 0.4, 0.7, 1],
        ).createShader(neckRect),
    );

    // ── Head (glossy sphere) ──────────────────────────────────────────────
    final headRect = Rect.fromCircle(center: headC, radius: headR);
    canvas.drawCircle(
      headC,
      headR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.34, -0.5),
          radius: 0.98,
          colors: [color.light, color.base, color.dark, color.deep],
          stops: const [0, 0.42, 0.86, 1],
        ).createShader(headRect),
    );
    // Rim light arc (top-left).
    canvas.drawArc(
      Rect.fromCircle(center: headC, radius: headR * 0.92),
      math.pi * 0.85,
      math.pi * 0.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round
        ..color = color.light.withValues(alpha: 0.7),
    );
    // Specular highlight.
    canvas.drawOval(
      Rect.fromCenter(
          center: headC + Offset(-headR * 0.34, -headR * 0.42),
          width: headR * 0.46,
          height: headR * 0.34),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // ── Style topper (classic stays a clean rounded pawn) ─────────────────
    final topY = headC.dy - headR;
    switch (style) {
      case LudoPawnStyle.classic:
        break; // clean rounded pawn
      case LudoPawnStyle.knight:
        _crest(canvas, cx, headC, headR, w);
      case LudoPawnStyle.sorcerer:
        _wizardCap(canvas, cx, topY, headR);
      case LudoPawnStyle.crown:
        _crown(canvas, cx, topY, headR);
    }
  }

  void _crest(Canvas canvas, double cx, Offset headC, double headR, double w) {
    // A heraldic cross/sword crest on the head.
    final rect = Rect.fromCenter(
        center: headC, width: headR * 1.1, height: headR * 1.3);
    final gp = Paint()
      ..shader = _gold(rect)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.09
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, headC.dy - headR * 0.7),
        Offset(cx, headC.dy + headR * 0.6), gp);
    canvas.drawLine(Offset(cx - headR * 0.42, headC.dy - headR * 0.1),
        Offset(cx + headR * 0.42, headC.dy - headR * 0.1), gp);
  }

  void _wizardCap(Canvas canvas, double cx, double topY, double headR) {
    final tip = Offset(cx, topY - headR * 1.5);
    final p = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(cx - headR * 0.7, topY + headR * 0.25)
      ..lineTo(cx + headR * 0.7, topY + headR * 0.25)
      ..close();
    final rect = Rect.fromLTRB(
        cx - headR * 0.7, tip.dy, cx + headR * 0.7, topY + headR * 0.25);
    canvas.drawPath(p, Paint()..shader = _gold(rect));
    // Star at the tip.
    canvas.drawCircle(tip + Offset(0, headR * 0.1), headR * 0.16,
        Paint()..color = const Color(0xFFFFF6D6));
  }

  void _crown(Canvas canvas, double cx, double topY, double headR) {
    final w = headR * 1.5;
    final top = topY - headR * 0.7;
    final bot = topY + headR * 0.25;
    final p = Path()
      ..moveTo(cx - w / 2, bot)
      ..lineTo(cx - w / 2, top + headR * 0.2)
      ..lineTo(cx - w * 0.26, topY - headR * 0.05)
      ..lineTo(cx, top)
      ..lineTo(cx + w * 0.26, topY - headR * 0.05)
      ..lineTo(cx + w / 2, top + headR * 0.2)
      ..lineTo(cx + w / 2, bot)
      ..close();
    final rect = Rect.fromLTRB(cx - w / 2, top, cx + w / 2, bot);
    canvas.drawPath(p, Paint()..shader = _gold(rect));
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = headR * 0.06
          ..color = const Color(0x886E4A12));
    // Centre gem.
    canvas.drawCircle(Offset(cx, bot - headR * 0.18), headR * 0.13,
        Paint()..color = color.light);
  }

  @override
  bool shouldRepaint(covariant _PawnPainter old) =>
      old.color != color || old.glow != glow || old.style != style;
}

/// Pulsing target overlay for magic-mode cell selection.
class _HighlightPainter extends CustomPainter {
  _HighlightPainter(this.cells, Listenable repaint)
      : pulse = repaint as Animation<double>,
        super(repaint: repaint);
  final Set<int> cells;
  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / LudoGeometry.grid;
    for (final i in cells) {
      if (i < 0 || i >= LudoGeometry.track.length) continue;
      final (col, row) = LudoGeometry.track[i];
      final rect = Rect.fromLTWH(col * cell, row * cell, cell, cell);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(cell * 0.2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = Colors.amberAccent
              .withValues(alpha: 0.55 + 0.4 * pulse.value),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter old) => true;
}

/// The luxurious static board background — painted once.
class _BoardPainter extends CustomPainter {
  _BoardPainter({this.highlight = const {}, required this.theme});
  final Set<int> highlight;
  final LudoBoardTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / LudoGeometry.grid;
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    Rect cellRect(num col, num row) =>
        Rect.fromLTWH(col * cell, row * cell, cell, cell);
    Offset ctr(num col, num row) => Offset((col + 0.5) * cell, (row + 0.5) * cell);

    // ── Wooden outer frame ────────────────────────────────────────────────
    final frameR = RRect.fromRectAndRadius(full, Radius.circular(cell * 0.55));
    canvas.drawRRect(
      frameR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.frameTop, theme.frameBottom],
        ).createShader(full),
    );
    // Frame bevel highlight.
    canvas.drawRRect(
      RRect.fromRectAndRadius(full.deflate(cell * 0.18), Radius.circular(cell * 0.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.12
        ..color = theme.frameBevel,
    );

    // ── Inner play surface ────────────────────────────────────────────────
    final play = full.deflate(cell * 0.5);
    final playR = RRect.fromRectAndRadius(play, Radius.circular(cell * 0.35));
    canvas.save();
    canvas.clipRRect(playR);
    canvas.drawRect(
      play,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.25),
          radius: 1.0,
          colors: [theme.surfaceCenter, theme.surfaceEdge],
        ).createShader(play),
    );

    // ── Home bases (glossy, 3D inner well) ────────────────────────────────
    for (final entry in LudoGeometry.baseRect.entries) {
      _drawHomeBase(canvas, entry.key, entry.value, cell);
    }

    // ── Track cells ───────────────────────────────────────────────────────
    for (var i = 0; i < LudoGeometry.track.length; i++) {
      final (col, row) = LudoGeometry.track[i];
      final rect = cellRect(col, row).deflate(cell * 0.06);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.16));
      final entryColor = LudoGeometry.entryColorAt(i);
      if (entryColor != null) {
        canvas.drawRRect(
          rr,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [entryColor.light, entryColor.base],
            ).createShader(rect),
        );
        _drawStar(canvas, ctr(col, row), cell * 0.3, Colors.white.withValues(alpha: 0.92));
      } else {
        if (theme.glow) {
          canvas.drawRRect(
            rr,
            Paint()
              ..color = theme.glowColor.withValues(alpha: 0.5)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
        canvas.drawRRect(
          rr,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.cellLight, theme.cellDark],
            ).createShader(rect),
        );
        if (LudoGeometry.isSafe(i)) {
          _drawStar(canvas, ctr(col, row), cell * 0.3, theme.star);
        }
      }
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * 0.03
          ..color = theme.line,
      );
    }

    // ── Home columns (gradient toward centre) ─────────────────────────────
    for (final entry in LudoGeometry.homeColumn.entries) {
      final color = entry.key;
      for (final (col, row) in entry.value) {
        final rect = cellRect(col, row).deflate(cell * 0.06);
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.16));
        canvas.drawRRect(
          rr,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.light, color.mid, color.dark],
            ).createShader(rect),
        );
        canvas.drawRRect(
          rr,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.03
            ..color = theme.line,
        );
      }
    }

    _drawCentre(canvas, cell, ctr);
    canvas.restore();

    // Inner border line over the whole play surface.
    canvas.drawRRect(
      playR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.05
        ..color = theme.line,
    );
  }

  void _drawHomeBase(Canvas canvas, LudoColor color, Rect cellsRect, double cell) {
    final rect = Rect.fromLTWH(cellsRect.left * cell, cellsRect.top * cell,
        cellsRect.width * cell, cellsRect.height * cell);
    final gold = theme.emblemRim;

    // Soft drop shadow under the raised home plate.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(Offset(0, cell * 0.12)), Radius.circular(cell * 0.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 0.18),
    );

    // ── Glossy coloured plate ─────────────────────────────────────────────
    final plate = RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.5));
    canvas.drawRRect(
      plate,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.light, color.base, color.mid, color.dark],
          stops: const [0.0, 0.38, 0.7, 1.0],
        ).createShader(rect),
    );
    // Top sheen.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.5),
          Radius.circular(cell * 0.45)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.32), Colors.white.withValues(alpha: 0.0)],
        ).createShader(rect),
    );
    // Gold rim (ties to the board skin's accent).
    canvas.drawRRect(
      plate,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.07
        ..color = gold,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(cell * 0.1), Radius.circular(cell * 0.42)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.02
        ..color = Colors.white.withValues(alpha: 0.35),
    );

    // ── Dark inset panel (same colour family, not white) ──────────────────
    final inner = rect.deflate(cell * 0.78);
    final innerRR = RRect.fromRectAndRadius(inner, Radius.circular(cell * 0.34));
    canvas.drawRRect(
      innerRR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 1.0,
          colors: [
            Color.lerp(color.deep, Colors.black, 0.35)!,
            Color.lerp(color.deep, Colors.black, 0.6)!,
          ],
        ).createShader(inner),
    );
    // Inset inner shadow (recessed look) + gold hairline.
    canvas.drawRRect(
      innerRR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.05
        ..color = Colors.black.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.deflate(cell * 0.04), Radius.circular(cell * 0.3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.015
        ..color = gold.withValues(alpha: 0.5),
    );

    // ── Parking wells (glossy seats for the 4 pieces) ─────────────────────
    for (final slot in LudoGeometry.baseSlots[color]!) {
      final sc = Offset(slot.dx * cell, slot.dy * cell);
      final r = cell * 0.46;
      canvas.drawCircle(
        sc,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [color.base.withValues(alpha: 0.5), color.deep.withValues(alpha: 0.2)],
          ).createShader(Rect.fromCircle(center: sc, radius: r)),
      );
      canvas.drawCircle(
        sc,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * 0.045
          ..color = color.light.withValues(alpha: 0.85),
      );
      // Tiny top glint.
      canvas.drawCircle(sc + Offset(-r * 0.32, -r * 0.34), r * 0.16,
          Paint()..color = Colors.white.withValues(alpha: 0.4));
    }
  }

  void _drawCentre(Canvas canvas, double cell, Offset Function(num, num) ctr) {
    final centre = ctr(7, 7);
    final tl = Offset(6 * cell, 6 * cell);
    final tr = Offset(9 * cell, 6 * cell);
    final br = Offset(9 * cell, 9 * cell);
    final bl = Offset(6 * cell, 9 * cell);

    void wedge(Offset a, Offset b, LudoColor color, bool lit) {
      final path = Path()
        ..moveTo(centre.dx, centre.dy)
        ..lineTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: lit ? [color.light, color.base] : [color.base, color.dark],
          ).createShader(Rect.fromPoints(a, b)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * 0.03
          ..color = Colors.white.withValues(alpha: 0.25),
      );
    }

    wedge(tl, bl, LudoColor.red, true); // left
    wedge(tl, tr, LudoColor.green, true); // top
    wedge(tr, br, LudoColor.yellow, false); // right
    wedge(bl, br, LudoColor.blue, false); // bottom

    // Raised centre emblem.
    canvas.drawCircle(centre, cell * 0.5,
        Paint()..color = Colors.black.withValues(alpha: 0.18)..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 0.1));
    canvas.drawCircle(
      centre,
      cell * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [theme.emblemInner, theme.emblemOuter],
        ).createShader(Rect.fromCircle(center: centre, radius: cell * 0.42)),
    );
    canvas.drawCircle(centre, cell * 0.42,
        Paint()..style = PaintingStyle.stroke..strokeWidth = cell * 0.04..color = theme.emblemRim);
    _drawStar(canvas, centre, cell * 0.28, theme.emblemRim);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? r : r * 0.44;
      final a = (math.pi / 5) * i - math.pi / 2;
      final p = Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) =>
      oldDelegate.highlight != highlight || oldDelegate.theme != theme;
}

import 'package:flutter/material.dart';

import '../../domain/xo_state.dart';

/// Premium-feel 3×3 board: square aspect, soft shadow + brand gradient
/// background, inset grid lines, neat X / O glyphs drawn as Paths (NOT
/// emoji — emoji look childish on iOS), and a glowing winning-line
/// stroke that pulses when the match ends.
class XoBoard extends StatefulWidget {
  const XoBoard({
    super.key,
    required this.snapshot,
    required this.onTapCell,
    required this.myAccent,
    required this.oppAccent,
  });

  final XoSnapshot snapshot;
  /// Callback invoked with (row, col) when the player taps an EMPTY cell
  /// during their own turn. Filled cells or other-player turns are no-ops.
  final void Function(int row, int col) onTapCell;
  /// Brand color used for the local player's mark (X or O).
  final Color myAccent;
  /// Brand color for the opponent's mark.
  final Color oppAccent;

  @override
  State<XoBoard> createState() => _XoBoardState();
}

class _XoBoardState extends State<XoBoard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, c) {
          final size = c.maxWidth;
          final cell = size / 3.0;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              if (!widget.snapshot.isPlaying || !widget.snapshot.myTurn) return;
              final x = details.localPosition.dx.clamp(0.0, size - 0.001);
              final y = details.localPosition.dy.clamp(0.0, size - 0.001);
              final col = (x / cell).floor().clamp(0, 2);
              final row = (y / cell).floor().clamp(0, 2);
              if (widget.snapshot.cellAt(row, col).isEmpty) {
                widget.onTapCell(row, col);
              }
            },
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => CustomPaint(
                painter: _BoardPainter(
                  snapshot: widget.snapshot,
                  myAccent: widget.myAccent,
                  oppAccent: widget.oppAccent,
                  pulse: _pulse.value,
                ),
                size: Size.square(size),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.snapshot,
    required this.myAccent,
    required this.oppAccent,
    required this.pulse,
  });

  final XoSnapshot snapshot;
  final Color myAccent;
  final Color oppAccent;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cell = w / 3.0;
    final radius = w * 0.06;

    // ── Background: warm panel + soft inner light ──────────────────
    final bgRect = Rect.fromLTWH(0, 0, w, w);
    final bgRrect = RRect.fromRectAndRadius(bgRect, Radius.circular(radius));
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFF1E1A16), Color(0xFF2A2421)],
      ).createShader(bgRect);
    canvas.drawRRect(bgRrect, bgPaint);

    // Subtle inner border.
    canvas.drawRRect(
      bgRrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004
        ..color = const Color(0x55D4A85F),
    );

    // ── Grid lines (inset from the rounded panel edge) ─────────────
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x66D4A85F);
    final inset = w * 0.06;
    // Two verticals.
    for (var i = 1; i <= 2; i++) {
      final x = cell * i;
      canvas.drawLine(Offset(x, inset), Offset(x, w - inset), gridPaint);
    }
    // Two horizontals.
    for (var i = 1; i <= 2; i++) {
      final y = cell * i;
      canvas.drawLine(Offset(inset, y), Offset(w - inset, y), gridPaint);
    }

    // ── Cell glyphs (X / O) ────────────────────────────────────────
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final mark = snapshot.cellAt(r, c);
        if (mark.isEmpty) {
          // Subtle dot hint for empty cells when it's my turn.
          if (snapshot.isPlaying && snapshot.myTurn) {
            canvas.drawCircle(
              Offset(cell * c + cell / 2, cell * r + cell / 2),
              w * 0.012,
              Paint()..color = const Color(0x33FFFFFF),
            );
          }
          continue;
        }
        final isMine = mark == snapshot.myMark;
        final color = isMine ? myAccent : oppAccent;
        final centre = Offset(cell * c + cell / 2, cell * r + cell / 2);
        if (mark == 'X') {
          _drawX(canvas, centre, cell, color);
        } else {
          _drawO(canvas, centre, cell, color);
        }
      }
    }

    // ── Winning line (pulses) ──────────────────────────────────────
    if (snapshot.winningLine.length == 3) {
      final start = snapshot.winningLine.first;
      final end = snapshot.winningLine.last;
      final a = Offset(cell * start[1] + cell / 2, cell * start[0] + cell / 2);
      final b = Offset(cell * end[1] + cell / 2, cell * end[0] + cell / 2);
      final winColor = (snapshot.isWinner ?? false) ? myAccent : oppAccent;
      final lineGlow = 0.45 + 0.45 * pulse;
      // Outer glow.
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = winColor.withValues(alpha: lineGlow)
          ..strokeWidth = w * 0.045
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Crisp inner line.
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = winColor
          ..strokeWidth = w * 0.018
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawX(Canvas canvas, Offset centre, double cell, Color color) {
    final pad = cell * 0.24;
    final stroke = Paint()
      ..color = color
      ..strokeWidth = cell * 0.085
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centre.dx - cell / 2 + pad, centre.dy - cell / 2 + pad),
      Offset(centre.dx + cell / 2 - pad, centre.dy + cell / 2 - pad),
      stroke,
    );
    canvas.drawLine(
      Offset(centre.dx + cell / 2 - pad, centre.dy - cell / 2 + pad),
      Offset(centre.dx - cell / 2 + pad, centre.dy + cell / 2 - pad),
      stroke,
    );
  }

  void _drawO(Canvas canvas, Offset centre, double cell, Color color) {
    final r = cell * 0.30;
    final stroke = Paint()
      ..color = color
      ..strokeWidth = cell * 0.085
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(centre, r, stroke);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) {
    return old.snapshot != snapshot ||
        old.myAccent != myAccent ||
        old.oppAccent != oppAccent ||
        old.pulse != pulse;
  }
}

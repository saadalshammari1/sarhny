import 'package:flutter/material.dart';

import '../../domain/xo_state.dart';

/// 3×3 XO board.
///
/// Layered design:
///   * BACKGROUND: CustomPainter draws the panel + grid + glyphs +
///     winning-line glow (visual only).
///   * OVERLAY: 9 explicit cell GestureDetectors in a Stack with
///     Positioned. Each cell knows its own (row, col) — no coordinate
///     math, no RTL ambiguity, no off-by-one. If a tap reaches an
///     occupied cell it fires `onCellRejected` so the parent can surface
///     a quick "already filled" toast instead of swallowing silently.
class XoBoard extends StatefulWidget {
  const XoBoard({
    super.key,
    required this.snapshot,
    required this.onTapCell,
    required this.myAccent,
    required this.oppAccent,
    this.onCellRejected,
  });

  final XoSnapshot snapshot;
  /// Called with (row, col) when the player taps an EMPTY cell during
  /// their turn. (0,0) is top-left.
  final void Function(int row, int col) onTapCell;
  /// Optional — fires with a short reason string when a tap was dropped:
  ///   "not_your_turn" | "cell_filled" | "not_playing".
  final void Function(String reason)? onCellRejected;
  final Color myAccent;
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
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _handleCellTap(int row, int col) {
    final s = widget.snapshot;
    if (!s.isPlaying) {
      widget.onCellRejected?.call('not_playing');
      return;
    }
    if (!s.myTurn) {
      widget.onCellRejected?.call('not_your_turn');
      return;
    }
    if (s.cellAt(row, col).isNotEmpty) {
      widget.onCellRejected?.call('cell_filled');
      return;
    }
    widget.onTapCell(row, col);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, c) {
          final size = c.maxWidth;
          final cell = size / 3.0;
          return Stack(
            children: [
              // ── Visual layer (paint only — pointer events pass through) ──
              Positioned.fill(
                child: IgnorePointer(
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
                ),
              ),
              // ── Tap layer — 9 explicit cells ─────────────────────────────
              for (var r = 0; r < 3; r++)
                for (var c0 = 0; c0 < 3; c0++)
                  Positioned(
                    left: cell * c0,
                    top: cell * r,
                    width: cell,
                    height: cell,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleCellTap(r, c0),
                        splashColor: widget.myAccent.withValues(alpha: 0.18),
                        highlightColor: widget.myAccent.withValues(alpha: 0.08),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Visual painter — same look as before; tap detection lives elsewhere.
// ─────────────────────────────────────────────────────────────────────

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

    final bgRect = Rect.fromLTWH(0, 0, w, w);
    final bgRrect = RRect.fromRectAndRadius(bgRect, Radius.circular(radius));
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFF1E1A16), Color(0xFF2A2421)],
      ).createShader(bgRect);
    canvas.drawRRect(bgRrect, bgPaint);

    canvas.drawRRect(
      bgRrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004
        ..color = const Color(0x55D4A85F),
    );

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x66D4A85F);
    final inset = w * 0.06;
    for (var i = 1; i <= 2; i++) {
      final x = cell * i;
      canvas.drawLine(Offset(x, inset), Offset(x, w - inset), gridPaint);
    }
    for (var i = 1; i <= 2; i++) {
      final y = cell * i;
      canvas.drawLine(Offset(inset, y), Offset(w - inset, y), gridPaint);
    }

    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final mark = snapshot.cellAt(r, c);
        if (mark.isEmpty) {
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

    if (snapshot.winningLine.length == 3) {
      final start = snapshot.winningLine.first;
      final end = snapshot.winningLine.last;
      final a = Offset(cell * start[1] + cell / 2, cell * start[0] + cell / 2);
      final b = Offset(cell * end[1] + cell / 2, cell * end[0] + cell / 2);
      final winColor = (snapshot.isWinner ?? false) ? myAccent : oppAccent;
      final lineGlow = 0.45 + 0.45 * pulse;
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = winColor.withValues(alpha: lineGlow)
          ..strokeWidth = w * 0.045
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// XO board v3 — radically simpler than v1/v2.
///
/// Architecture:
///   * 3 rows × 3 columns of cells, built with plain Column + Row +
///     Expanded. No CustomPainter, no LayoutBuilder, no coordinate
///     math, no GestureDetector with localPosition.
///   * Each cell is its OWN GestureDetector. Tap delivery is exact —
///     the Flutter framework decides which cell was tapped, not us.
///   * No RTL trickery: every cell knows its (row, col) at compile
///     time via the for-loop indices.
///   * The winning-line glow is a Stack overlay (CustomPaint) drawn
///     ABOVE the cells in the same render pass — does not intercept
///     taps because it sits inside an IgnorePointer.
///
/// Public API mirrors the previous widget so callers don't change.
class XoBoardV3 extends StatelessWidget {
  const XoBoardV3({
    super.key,
    required this.cells,
    required this.winningLine,
    required this.interactive,
    required this.onTap,
    required this.onRejectedTap,
    required this.xColor,
    required this.oColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.winColor,
    this.highlightHints = true,
  });

  /// Row-major 3×3 board. Each cell is "" | "X" | "O".
  final List<List<String>> cells;

  /// 0 or 3 [row, col] pairs marking the winning line. Empty during play.
  final List<List<int>> winningLine;

  /// When true, empty cells are tappable. When false, the board is
  /// inert (e.g. post-game reveal).
  final bool interactive;

  /// Fires with (row, col) for an empty cell tap during interactive play.
  final void Function(int row, int col) onTap;

  /// Optional — fires when the user tapped a cell that wasn't a valid
  /// move (already filled or board inert). Lets the parent show
  /// "الخانة مشغولة" feedback without us swallowing the gesture.
  final void Function(int row, int col, String reason) onRejectedTap;

  final Color xColor;
  final Color oColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color winColor;

  /// Show a subtle dot in empty cells when it's the player's turn — a
  /// visual hint that the cell is alive. Disable for the post-game
  /// read-only reveal.
  final bool highlightHints;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          // ── Cells (the only thing that handles taps) ─────────────
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                for (var r = 0; r < 3; r++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var c = 0; c < 3; c++)
                          Expanded(
                            child: _Cell(
                              row: r,
                              col: c,
                              mark: cells[r][c],
                              interactive: interactive,
                              isWinning: _isWinning(r, c),
                              xColor: xColor,
                              oColor: oColor,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              winColor: winColor,
                              highlightHint:
                                  highlightHints && cells[r][c].isEmpty,
                              onTap: () {
                                if (!interactive) {
                                  onRejectedTap(r, c, 'inert');
                                  return;
                                }
                                if (cells[r][c].isNotEmpty) {
                                  onRejectedTap(r, c, 'filled');
                                  return;
                                }
                                onTap(r, c);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Winning-line overlay (decorative, no taps) ───────────
          if (winningLine.length == 3)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _WinningLinePainter(
                    line: winningLine,
                    color: winColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isWinning(int r, int c) {
    if (winningLine.length != 3) return false;
    for (final p in winningLine) {
      if (p[0] == r && p[1] == c) return true;
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────
// Cell — one tappable square with X / O / empty.
// ─────────────────────────────────────────────────────────────────────

class _Cell extends StatelessWidget {
  const _Cell({
    required this.row,
    required this.col,
    required this.mark,
    required this.interactive,
    required this.isWinning,
    required this.xColor,
    required this.oColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.winColor,
    required this.highlightHint,
    required this.onTap,
  });

  final int row;
  final int col;
  final String mark;
  final bool interactive;
  final bool isWinning;
  final Color xColor;
  final Color oColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color winColor;
  final bool highlightHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fillColor = isWinning
        ? winColor.withValues(alpha: 0.20)
        : surfaceColor;
    final outline = isWinning
        ? winColor.withValues(alpha: 0.80)
        : borderColor.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // HitTestBehavior.opaque on Material > InkWell isn't needed
          // because Material fills the entire Padding child via its
          // type=Material default. The InkWell's onTap is wired even
          // when interactive=false so we can still surface rejection
          // toasts upstream.
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: (mark.isEmpty && interactive)
              ? winColor.withValues(alpha: 0.20)
              : Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: outline,
                width: isWinning ? 1.4 : 0.8,
              ),
              boxShadow: isWinning
                  ? [
                      BoxShadow(
                        color: winColor.withValues(alpha: 0.40),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: mark.isEmpty
                  ? (highlightHint
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.40),
                            shape: BoxShape.circle,
                          ),
                        )
                      : const SizedBox.shrink())
                  : _GlyphText(
                      mark: mark,
                      color: mark == 'X' ? xColor : oColor,
                      key: ValueKey('${row}_${col}_$mark'),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Animated glyph — entrance animation keyed by (row,col,mark) so the
// scale-in only fires when this cell newly gets a mark.
// ─────────────────────────────────────────────────────────────────────

class _GlyphText extends StatelessWidget {
  const _GlyphText({super.key, required this.mark, required this.color});
  final String mark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      mark,
      style: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1.0,
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
        )
        .fade(duration: const Duration(milliseconds: 200));
  }
}

// ─────────────────────────────────────────────────────────────────────
// Winning-line painter — diagonal/row/col stroke through cell centres.
// ─────────────────────────────────────────────────────────────────────

class _WinningLinePainter extends CustomPainter {
  _WinningLinePainter({required this.line, required this.color});
  final List<List<int>> line;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (line.length != 3) return;
    // Cell padding mirrors the layout above (6 outer + 5 per cell).
    // Compute the centre of each indexed cell in pixel space.
    final outer = 6.0;
    final innerPad = 5.0;
    final inner = size.width - outer * 2;
    final cell = inner / 3.0;
    Offset centre(int r, int c) {
      final cx = outer + (c + 0.5) * cell;
      final cy = outer + (r + 0.5) * cell;
      return Offset(cx, cy);
    }
    final start = centre(line[0][0], line[0][1]);
    final end = centre(line[2][0], line[2][1]);

    // Outer glow.
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Crisp inner stroke.
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = color
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Suppress unused-field lint while keeping the const available for
    // future inset tweaks.
    if (innerPad < 0) throw StateError('unreachable');
  }

  @override
  bool shouldRepaint(covariant _WinningLinePainter old) =>
      old.line != line || old.color != color;
}

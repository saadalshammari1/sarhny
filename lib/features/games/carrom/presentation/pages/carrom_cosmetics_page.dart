import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../application/carrom_controllers.dart';
import '../../data/carrom_api.dart';
import '../../domain/cosmetics.dart';

/// صفحة اختيار الـ skins — Tabs (الطاولة، القطع، المضرب).
///
/// مبدأ التصميم:
/// - كل tab Grid 2-column. كل بطاقة تعرض المعاينة الحقيقية بنفس الـ
///   render style المستخدم في المباراة، ليرى اللاعب بالضبط ما سيظهر.
/// - الاختيار auto-save (يرسل PUT) — مع animated check mark.
/// - الـ optimistic update يتم عبر `CosmeticsSelectionController`،
///   ولو رفض السيرفر (locked / not found) نُرجع الحالة.
class CarromCosmeticsPage extends ConsumerStatefulWidget {
  const CarromCosmeticsPage({super.key});
  @override
  ConsumerState<CarromCosmeticsPage> createState() =>
      _CarromCosmeticsPageState();
}

class _CarromCosmeticsPageState extends ConsumerState<CarromCosmeticsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final async = ref.watch(cosmeticsResponseProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('خصّص لعبتك'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: false,
          labelColor: colors.moment,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.moment,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'الطاولة'),
            Tab(icon: Icon(Icons.circle_outlined), text: 'القطع'),
            Tab(icon: Icon(Icons.adjust_outlined), text: 'المضرب'),
          ],
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: 36, color: colors.textSecondary),
                const SizedBox(height: 8),
                Text('تعذّر تحميل الكاتالوج',
                    style: TextStyle(color: colors.textSecondary)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(cosmeticsResponseProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (resp) {
          // Hydrate selection state on the first build only.
          if (!_hydrated) {
            _hydrated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(cosmeticsSelectionProvider.notifier)
                  .hydrate(resp.current);
            });
          }
          return TabBarView(
            controller: _tab,
            children: [
              _BoardsTab(boards: resp.catalog.boards),
              _PiecesTab(pieces: resp.catalog.pieces),
              _StrikersTab(strikers: resp.catalog.strikers),
            ],
          );
        },
      ),
    );
  }
}

// ── Boards tab ────────────────────────────────────────────────────────

class _BoardsTab extends ConsumerWidget {
  const _BoardsTab({required this.boards});
  final List<BoardSkin> boards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(cosmeticsSelectionProvider).boardSkin;
    final colors = context.sarhnyColors;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: boards.length,
      itemBuilder: (_, i) {
        final b = boards[i];
        return _PickerCard(
          isSelected: b.key == selected,
          locked: b.locked,
          title: b.nameAr,
          subtitle: b.nameEn,
          accent: b.accentColor,
          preview: _BoardPreview(skin: b),
          onTap: b.locked
              ? null
              : () async {
                  try {
                    await ref
                        .read(cosmeticsSelectionProvider.notifier)
                        .setBoard(b.key);
                    Fluttertoast.showToast(msg: 'تم اختيار ${b.nameAr}');
                  } on CarromApiException catch (e) {
                    Fluttertoast.showToast(msg: e.message);
                  } catch (_) {
                    Fluttertoast.showToast(msg: 'تعذّر الحفظ');
                  }
                },
          colors: colors,
        );
      },
    );
  }
}

// ── Pieces tab ────────────────────────────────────────────────────────

class _PiecesTab extends ConsumerWidget {
  const _PiecesTab({required this.pieces});
  final List<PieceSkinPair> pieces;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(cosmeticsSelectionProvider).pieceSkin;
    final colors = context.sarhnyColors;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: pieces.length,
      itemBuilder: (_, i) {
        final p = pieces[i];
        return _PickerCard(
          isSelected: p.key == selected,
          locked: p.locked,
          title: p.nameAr,
          subtitle: p.descriptionAr ?? p.nameEn,
          accent: p.colorA,
          preview: _PiecesPreview(skin: p),
          onTap: p.locked
              ? null
              : () async {
                  try {
                    await ref
                        .read(cosmeticsSelectionProvider.notifier)
                        .setPiece(p.key);
                    Fluttertoast.showToast(msg: 'تم اختيار ${p.nameAr}');
                  } on CarromApiException catch (e) {
                    Fluttertoast.showToast(msg: e.message);
                  } catch (_) {
                    Fluttertoast.showToast(msg: 'تعذّر الحفظ');
                  }
                },
          colors: colors,
        );
      },
    );
  }
}

// ── Strikers tab ──────────────────────────────────────────────────────

class _StrikersTab extends ConsumerWidget {
  const _StrikersTab({required this.strikers});
  final List<StrikerSkin> strikers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(cosmeticsSelectionProvider).strikerSkin;
    final colors = context.sarhnyColors;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: strikers.length,
      itemBuilder: (_, i) {
        final s = strikers[i];
        return _PickerCard(
          isSelected: s.key == selected,
          locked: s.locked,
          title: s.nameAr,
          subtitle: s.descriptionAr ?? s.nameEn,
          accent: s.color,
          preview: _StrikerPreview(skin: s),
          onTap: s.locked
              ? null
              : () async {
                  try {
                    await ref
                        .read(cosmeticsSelectionProvider.notifier)
                        .setStriker(s.key);
                    Fluttertoast.showToast(msg: 'تم اختيار ${s.nameAr}');
                  } on CarromApiException catch (e) {
                    Fluttertoast.showToast(msg: e.message);
                  } catch (_) {
                    Fluttertoast.showToast(msg: 'تعذّر الحفظ');
                  }
                },
          colors: colors,
        );
      },
    );
  }
}

// ── Card frame ────────────────────────────────────────────────────────

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.isSelected,
    required this.locked,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.preview,
    required this.onTap,
    required this.colors,
  });

  final bool isSelected;
  final bool locked;
  final String title;
  final String subtitle;
  final Color accent;
  final Widget preview;
  final VoidCallback? onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? colors.moment : colors.border;
    final bgColor = isSelected
        ? Color.lerp(colors.surface, accent, 0.05)!
        : colors.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 0.8,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.moment.withValues(alpha: 0.20),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: preview),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: colors.moment,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.moment.withValues(alpha: 0.45),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  if (locked)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1.6, sigmaY: 1.6),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.35),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '✦',
                      style: TextStyle(
                        color: colors.moment,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 10.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Board preview ─────────────────────────────────────────────────────
//
// كل preview = نسخة مصغّرة طبق الأصل من الـ BoardBackground.render()
// في carrom_board.dart. نفس الـ frame gradients، نفس الـ surface
// shaders، نفس الـ ornaments والـ rosette والـ baselines. الـ scale
// محسوب بحيث 600 وحدة (الـ board) → ~120 px (الـ preview).

class _BoardPreview extends StatelessWidget {
  const _BoardPreview({required this.skin});
  final BoardSkin skin;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BoardPreviewPainter(skin: skin),
      child: const SizedBox.expand(),
    );
  }
}

class _BoardPreviewPainter extends CustomPainter {
  _BoardPreviewPainter({required this.skin});
  final BoardSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Frame margin scaled: board uses 40/600 ≈ 0.066 — slightly larger
    // here so ornaments stay legible on a 120 px preview.
    final inset = math.min(size.width, size.height) * 0.10;
    final inner = rect.deflate(inset);

    // ── Outer ambient shadow ──────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(0, 1.5),
        const Radius.circular(11),
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // ── Frame (theme-specific gradient + ornaments) ───────────────
    _paintFrame(canvas, rect, inner);

    // ── Play surface ──────────────────────────────────────────────
    _paintSurface(canvas, inner);

    // ── Brass inlay ring inside the frame ─────────────────────────
    final accentAlt = skin.accentColorAlt ?? skin.accentColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.deflate(0.8), const Radius.circular(4)),
      Paint()
        ..color = accentAlt.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.deflate(2.4), const Radius.circular(3)),
      Paint()
        ..color = skin.accentColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // ── Striker baseline marks (scaled-down) ──────────────────────
    _paintStrikerBaselines(canvas, inner);

    // ── 4 pockets (beveled hole with depth) ───────────────────────
    final pocketR = math.min(inner.width, inner.height) * 0.10;
    final inset2 = pocketR;
    final pocketCenters = [
      Offset(inner.left + inset2, inner.top + inset2),
      Offset(inner.right - inset2, inner.top + inset2),
      Offset(inner.left + inset2, inner.bottom - inset2),
      Offset(inner.right - inset2, inner.bottom - inset2),
    ];
    final pocketRim = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final pocketInnerRim = Paint()
      ..color = Color.lerp(skin.accentColor, Colors.black, 0.5)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final c in pocketCenters) {
      // Soft shadow under each pocket.
      canvas.drawCircle(
        c.translate(0, 0.6),
        pocketR + 1.0,
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      // Outer themed rim ring.
      canvas.drawCircle(c, pocketR + 0.5, pocketRim);
      // Dark depth gradient.
      canvas.drawCircle(
        c,
        pocketR,
        Paint()
          ..shader = RadialGradient(
            colors: const [
              Color(0xFF000000),
              Color(0xFF050505),
              Color(0xFF1A1A1A),
            ],
            stops: [0.0, 0.7, 1.0],
            center: const Alignment(0.15, 0.15),
          ).createShader(Rect.fromCircle(center: c, radius: pocketR)),
      );
      canvas.drawCircle(c, pocketR - 0.4, pocketInnerRim);
    }

    // ── Center rosette (themed, multi-layer) ──────────────────────
    _paintCenterRosette(canvas, inner.center);

    // ── Crown emblems for royal_navy ──────────────────────────────
    if (skin.borderStyle == 'gold_crown') {
      final crownSize = math.min(inner.width, inner.height) * 0.18;
      final tp = TextPainter(
        text: TextSpan(
          text: '♛',
          style: TextStyle(
            color: accentAlt,
            fontSize: crownSize,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: skin.accentColor.withValues(alpha: 0.55),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(inner.center.dx - tp.width / 2, inner.top + 2),
      );
      tp.paint(
        canvas,
        Offset(
          inner.center.dx - tp.width / 2,
          inner.bottom - tp.height - 2,
        ),
      );
    }
  }

  // ── Frame painter — mirrors carrom_board.dart::_paintFrame ──────────
  void _paintFrame(Canvas canvas, Rect rect, Rect inner) {
    final framePaint = Paint();
    final accent = skin.accentColor;
    final accentAlt = skin.accentColorAlt ?? accent;

    switch (skin.borderStyle) {
      case 'wood':
        // Rosewood — deep walnut with grain hint.
        framePaint.shader = LinearGradient(
          colors: [
            const Color(0xFF7A4A22),
            accent,
            const Color(0xFF3A1F0C),
            accent,
            const Color(0xFF5A2F12),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        break;
      case 'thin_gold':
        framePaint.shader = LinearGradient(
          colors: [
            const Color(0xFFE8C16A),
            accent,
            const Color(0xFFC9A04F),
            accent,
            const Color(0xFFB8924A),
          ],
          stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        break;
      case 'gold_crown':
        framePaint.shader = LinearGradient(
          colors: [
            const Color(0xFFFFE3A0),
            accent,
            const Color(0xFFB3933A),
            accent,
            const Color(0xFF8B6E2C),
          ],
          stops: const [0.0, 0.25, 0.55, 0.78, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        break;
      case 'neon_glow':
        // Dual outer halo (cyan + magenta).
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(1.2), const Radius.circular(11)),
          Paint()
            ..color = accent.withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(0.6), const Radius.circular(10)),
          Paint()
            ..color = accentAlt.withValues(alpha: 0.40)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        framePaint.color = const Color(0xFF0A0A18);
        break;
      default:
        framePaint.color = accent;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      framePaint,
    );

    // Recessed-playfield darkening behind the inlay.
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner.inflate(0.6), const Radius.circular(4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );

    // ── Per-theme frame ornaments ────────────────────────────────
    switch (skin.borderStyle) {
      case 'wood':
        // Subtle grain stripes on the frame band (top + bottom).
        for (int i = 0; i < 4; i++) {
          final dy = rect.top + 1.5 + i * 1.2;
          final dyB = rect.bottom - 1.5 - i * 1.2;
          final pStripe = Paint()
            ..color = Colors.black.withValues(alpha: 0.10)
            ..strokeWidth = 0.3;
          canvas.drawLine(
            Offset(rect.left + 3, dy),
            Offset(rect.right - 3, dy),
            pStripe,
          );
          canvas.drawLine(
            Offset(rect.left + 3, dyB),
            Offset(rect.right - 3, dyB),
            pStripe,
          );
        }
        break;
      case 'gold_crown':
        // 4 filigree corner studs.
        const studPositions = [
          Offset(0.06, 0.06),
          Offset(0.94, 0.06),
          Offset(0.06, 0.94),
          Offset(0.94, 0.94),
        ];
        for (final p in studPositions) {
          final c = Offset(
            rect.left + rect.width * p.dx,
            rect.top + rect.height * p.dy,
          );
          canvas.drawCircle(c, 1.8, Paint()..color = accentAlt);
          canvas.drawCircle(
            c,
            1.8,
            Paint()
              ..color = Colors.black.withValues(alpha: 0.55)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.4,
          );
          canvas.drawCircle(
            c.translate(-0.5, -0.6),
            0.6,
            Paint()..color = Colors.white.withValues(alpha: 0.85),
          );
        }
        break;
      case 'neon_glow':
        // 4 hex-vertex diamonds (top/bottom/left/right mid).
        final diamondPositions = [
          Offset(rect.center.dx, rect.top + 2.5),
          Offset(rect.center.dx, rect.bottom - 2.5),
          Offset(rect.left + 2.5, rect.center.dy),
          Offset(rect.right - 2.5, rect.center.dy),
        ];
        for (final c in diamondPositions) {
          final path = Path()
            ..moveTo(c.dx, c.dy - 1.4)
            ..lineTo(c.dx + 1.4, c.dy)
            ..lineTo(c.dx, c.dy + 1.4)
            ..lineTo(c.dx - 1.4, c.dy)
            ..close();
          canvas.drawPath(
            path,
            Paint()
              ..color = accent
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
          );
        }
        break;
      case 'thin_gold':
        // Brass rivets (3 per side).
        for (int i = 0; i < 3; i++) {
          final f = (i + 1) / 4;
          final positions = [
            Offset(rect.left + rect.width * f, rect.top + 2.2),
            Offset(rect.left + rect.width * f, rect.bottom - 2.2),
            Offset(rect.left + 2.2, rect.top + rect.height * f),
            Offset(rect.right - 2.2, rect.top + rect.height * f),
          ];
          for (final c in positions) {
            canvas.drawCircle(c, 1.0, Paint()..color = accentAlt);
            canvas.drawCircle(
              c.translate(-0.25, -0.3),
              0.35,
              Paint()..color = Colors.white.withValues(alpha: 0.85),
            );
          }
        }
        break;
    }
  }

  // ── Surface painter — mirrors carrom_board.dart::_paintSurface ──────
  void _paintSurface(Canvas canvas, Rect inner) {
    final playPaint = Paint();
    final base = skin.baseColor;
    switch (skin.texture) {
      case 'wood':
        playPaint.shader = RadialGradient(
          colors: [
            Color.lerp(base, Colors.white, 0.18)!,
            base,
            Color.lerp(base, const Color(0xFF7A4A22), 0.30)!,
          ],
          stops: const [0.0, 0.55, 1.0],
          center: const Alignment(-0.20, -0.25),
          radius: 1.05,
        ).createShader(inner);
        break;
      case 'marble':
        playPaint.shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF),
            base,
            const Color(0xFFEDE6D8),
            const Color(0xFFD8CFB8),
          ],
          stops: const [0.0, 0.45, 0.85, 1.0],
          center: const Alignment(-0.2, -0.3),
          radius: 1.1,
        ).createShader(inner);
        break;
      case 'felt':
        playPaint.shader = RadialGradient(
          colors: [
            Color.lerp(base, Colors.white, 0.08)!,
            base,
            Color.lerp(base, Colors.black, 0.40)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(inner);
        break;
      case 'neon':
        playPaint.shader = RadialGradient(
          colors: [
            const Color(0xFF0F1430),
            base,
            const Color(0xFF000000),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(inner);
        break;
      default:
        playPaint.color = base;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(4)),
      playPaint,
    );

    // ── Texture overlays ──────────────────────────────────────────
    switch (skin.texture) {
      case 'wood':
        _paintWoodGrain(canvas, inner);
        break;
      case 'marble':
        _paintMarbleVeining(canvas, inner);
        break;
      case 'felt':
        _paintFeltPattern(canvas, inner);
        break;
      case 'neon':
        _paintHexGrid(canvas, inner);
        break;
    }
  }

  /// 6 thin wood-grain stripes + 3 deterministic knots — scaled down.
  void _paintWoodGrain(Canvas canvas, Rect inner) {
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.25;
    for (int i = 0; i < 6; i++) {
      final y = inner.top + (inner.height / 6) * i + 1.2;
      final path = Path()..moveTo(inner.left + 1.2, y);
      for (double x = inner.left + 1.2; x <= inner.right - 1.2; x += 2.0) {
        final yWave = y + math.sin((x + i * 31) * 0.20) * 0.6;
        path.lineTo(x, yWave);
      }
      grain.color = (i % 3 == 0
              ? const Color(0xFF5A3315)
              : const Color(0xFF8B5A2B))
          .withValues(alpha: i.isEven ? 0.10 : 0.05);
      canvas.drawPath(path, grain);
    }
    const knots = [
      Offset(0.20, 0.30),
      Offset(0.72, 0.22),
      Offset(0.55, 0.78),
    ];
    for (final k in knots) {
      final kp = Offset(
        inner.left + inner.width * k.dx,
        inner.top + inner.height * k.dy,
      );
      canvas.drawCircle(
        kp,
        0.9,
        Paint()..color = const Color(0xFF3A1F0C).withValues(alpha: 0.30),
      );
      canvas.drawCircle(
        kp,
        1.6,
        Paint()
          ..color = const Color(0xFF5A3315).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
      );
    }
  }

  /// Carrara veining — 2 Bezier veins + 5 specks.
  void _paintMarbleVeining(Canvas canvas, Rect inner) {
    // Gray vein.
    final v1 = Paint()
      ..color = const Color(0xFFAFAAA0).withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final p1 = Path()
      ..moveTo(inner.left + inner.width * 0.05, inner.top + 4)
      ..cubicTo(
        inner.center.dx - 14, inner.top + inner.height * 0.30,
        inner.center.dx + 8, inner.center.dy - 4,
        inner.right - 6, inner.bottom - inner.height * 0.20,
      );
    canvas.drawPath(p1, v1);

    // Gold vein.
    final v2 = Paint()
      ..color = const Color(0xFFC2A06A).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.35;
    final p2 = Path()
      ..moveTo(inner.right - 4, inner.top + 8)
      ..cubicTo(
        inner.center.dx + 10, inner.center.dy - 16,
        inner.center.dx - 12, inner.center.dy + 6,
        inner.left + 10, inner.bottom - 8,
      );
    canvas.drawPath(p2, v2);

    const speckles = [
      Offset(0.22, 0.28),
      Offset(0.78, 0.16),
      Offset(0.42, 0.55),
      Offset(0.66, 0.72),
      Offset(0.15, 0.78),
    ];
    final dot = Paint()
      ..color = const Color(0xFF8A8478).withValues(alpha: 0.35);
    for (final s in speckles) {
      canvas.drawCircle(
        Offset(
          inner.left + inner.width * s.dx,
          inner.top + inner.height * s.dy,
        ),
        0.4,
        dot,
      );
    }
  }

  /// Felt weave + vignette.
  void _paintFeltPattern(Canvas canvas, Rect inner) {
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.045);
    const cells = 14;
    for (int gy = 0; gy < cells; gy++) {
      for (int gx = 0; gx < cells; gx++) {
        final dx =
            inner.left + (inner.width / cells) * gx + (gy.isOdd ? 0.7 : 0);
        final dy = inner.top + (inner.height / cells) * gy + 0.7;
        if (dx > inner.right - 1 || dy > inner.bottom - 1) continue;
        canvas.drawCircle(Offset(dx, dy), 0.22, dot);
      }
    }
    canvas.drawRect(
      inner,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.60, 1.0],
        ).createShader(inner),
    );
  }

  /// Hex grid + scan-line.
  void _paintHexGrid(Canvas canvas, Rect inner) {
    final accent = skin.accentColor;
    final grid = Paint()
      ..color = accent.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    const cell = 8.5;
    for (double y = inner.top; y < inner.bottom; y += cell * 0.866) {
      final row = ((y - inner.top) / (cell * 0.866)).floor();
      for (double x = inner.left + (row.isOdd ? cell * 0.5 : 0);
          x < inner.right;
          x += cell) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = i * math.pi / 3 + math.pi / 6;
          final px = x + cell * 0.30 * math.cos(angle);
          final py = y + cell * 0.30 * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, grid);
      }
    }
    final accentAlt = skin.accentColorAlt ?? accent;
    canvas.drawLine(
      Offset(inner.left + 4, inner.center.dy),
      Offset(inner.right - 4, inner.center.dy),
      Paint()
        ..color = accentAlt.withValues(alpha: 0.10)
        ..strokeWidth = 0.25,
    );
  }

  /// Striker baseline arcs — mid dot + 2 flanking marks each side.
  void _paintStrikerBaselines(Canvas canvas, Rect inner) {
    final accentAlt = skin.accentColorAlt ?? skin.accentColor;
    final paint = Paint()
      ..color = accentAlt.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.45;
    final dxOff = inner.width * 0.26;
    final yOffset = inner.height * 0.18;
    void drawSideMark(double y) {
      final cx = inner.center.dx;
      canvas.drawCircle(Offset(cx, y), 0.7, Paint()..color = paint.color);
      for (final dx in [-dxOff, dxOff]) {
        canvas.drawLine(
          Offset(cx + dx, y - 1.3),
          Offset(cx + dx, y + 1.3),
          paint,
        );
      }
    }

    drawSideMark(inner.top + yOffset);
    drawSideMark(inner.bottom - yOffset);
  }

  /// Center rosette — outer ring, 8 dots, red mid ring, red center dot.
  void _paintCenterRosette(Canvas canvas, Offset center) {
    final accentAlt = skin.accentColorAlt ?? skin.accentColor;
    const centerRing = Color(0xFFC0392B);
    final ringR = 5.8;
    // 1) Outer ring.
    canvas.drawCircle(
      center,
      ringR + 1.6,
      Paint()
        ..color = accentAlt.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    // 2) Mid red ring.
    canvas.drawCircle(
      center,
      ringR,
      Paint()
        ..color = centerRing.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    // 3) 8 small dots around the ring.
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final p = Offset(
        center.dx + ringR * math.cos(angle),
        center.dy + ringR * math.sin(angle),
      );
      canvas.drawCircle(
        p,
        0.5,
        Paint()..color = accentAlt.withValues(alpha: 0.85),
      );
    }
    // 4) Inner red dot.
    canvas.drawCircle(
      center,
      2.2,
      Paint()..color = centerRing.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      center,
      1.0,
      Paint()..color = centerRing,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPreviewPainter old) =>
      old.skin.key != skin.key;
}

// ── Pieces preview ────────────────────────────────────────────────────

class _PiecesPreview extends StatelessWidget {
  const _PiecesPreview({required this.skin});
  final PieceSkinPair skin;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _PiecePreviewDot(color: skin.colorA, finish: skin.finish)),
            const SizedBox(width: 12),
            Expanded(child: _PiecePreviewDot(color: skin.colorB, finish: skin.finish)),
          ],
        ),
      ),
    );
  }
}

class _PiecePreviewDot extends StatelessWidget {
  const _PiecePreviewDot({required this.color, required this.finish});
  final Color color;
  final String finish;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _PieceDotPainter(color: color, finish: finish),
      ),
    );
  }
}

/// Piece preview dot — مرآة كاملة لـ PieceComponent.render() في
/// carrom_board.dart. نفس الـ gradient stops، الـ beveled ring،
/// الـ specular sweep، والـ embossed maker's-mark seal.
class _PieceDotPainter extends CustomPainter {
  _PieceDotPainter({required this.color, required this.finish});
  final Color color;
  final String finish;

  static bool _isLight(Color c) {
    final luma =
        0.299 * (c.r * 255) + 0.587 * (c.g * 255) + 0.114 * (c.b * 255);
    return luma > 140;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Leave breathing room for shadow/highlight overshoot.
    final r = math.min(size.width, size.height) / 2 - 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    final isLight = _isLight(color);

    // ── Multi-layer shadow ─────────────────────────────────────────
    canvas.drawCircle(
      Offset(center.dx + 0.3, center.dy + 1.8),
      r * 1.05,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );
    canvas.drawCircle(
      Offset(center.dx + 0.2, center.dy + 0.9),
      r * 0.98,
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
    );

    // ── Base body — 4-stop sculpted radial gradient per finish ────
    final paint = Paint();
    switch (finish) {
      case 'metallic':
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.55)!,
            Color.lerp(color, Colors.white, 0.20)!,
            color,
            Color.lerp(color, Colors.black, 0.45)!,
          ],
          stops: const [0.0, 0.25, 0.65, 1.0],
          center: const Alignment(-0.40, -0.45),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case 'jewel':
      case 'gem':
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.62)!,
            Color.lerp(color, Colors.white, 0.18)!,
            color,
            Color.lerp(color, Colors.black, 0.28)!,
          ],
          stops: const [0.0, 0.30, 0.70, 1.0],
          center: const Alignment(-0.45, -0.45),
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      default: // matte
        paint.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.30)!,
            Color.lerp(color, Colors.white, 0.05)!,
            color,
            Color.lerp(color, Colors.black, 0.22)!,
          ],
          stops: const [0.0, 0.40, 0.78, 1.0],
          center: const Alignment(-0.35, -0.40),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
    }
    canvas.drawCircle(center, r, paint);

    // ── Beveled inner ring ─────────────────────────────────────────
    canvas.drawCircle(
      center,
      r * 0.95,
      Paint()
        ..color = Color.lerp(color, Colors.black, isLight ? 0.18 : 0.50)!
            .withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // ── Outer rim ──────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      r - 0.2,
      Paint()
        ..color = Color.lerp(color, Colors.black, isLight ? 0.45 : 0.75)!
            .withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // ── Specular sweep (elongated) ─────────────────────────────────
    final softHighlight = Paint()
      ..color = Colors.white.withValues(alpha: isLight ? 0.55 : 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    canvas.save();
    canvas.translate(center.dx - r * 0.35, center.dy - r * 0.40);
    canvas.scale(1.0, 0.55);
    canvas.drawCircle(Offset.zero, r * 0.32, softHighlight);
    canvas.restore();

    // ── Sharp catchlight (top-left) ────────────────────────────────
    canvas.drawCircle(
      Offset(center.dx - r * 0.42, center.dy - r * 0.48),
      r * 0.10,
      Paint()..color = Colors.white.withValues(alpha: isLight ? 0.95 : 0.80),
    );

    // ── Embossed maker's-mark seal (3 rings) ───────────────────────
    canvas.drawCircle(
      center,
      r * 0.32,
      Paint()
        ..color = Color.lerp(color, Colors.black, isLight ? 0.18 : 0.55)!
            .withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    canvas.drawCircle(
      center,
      r * 0.18,
      Paint()
        ..color = Color.lerp(color, Colors.black, isLight ? 0.10 : 0.40)!
            .withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.35,
    );
    canvas.drawCircle(
      center,
      r * 0.06,
      Paint()
        ..color =
            Color.lerp(color, Colors.white, 0.40)!.withValues(alpha: 0.55),
    );

    // ── Back-scatter for jewel/gem ─────────────────────────────────
    if (finish == 'jewel' || finish == 'gem') {
      canvas.drawCircle(
        Offset(center.dx + r * 0.20, center.dy + r * 0.45),
        r * 0.20,
        Paint()
          ..color = Color.lerp(color, Colors.white, 0.40)!
              .withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PieceDotPainter old) =>
      old.color != color || old.finish != finish;
}

// ── Striker preview ───────────────────────────────────────────────────

class _StrikerPreview extends StatelessWidget {
  const _StrikerPreview({required this.skin});
  final StrikerSkin skin;

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(14),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: _StrikerPainter(skin: skin),
        ),
      ),
    );
  }
}

/// Striker preview — مرآة كاملة لـ StrikerComponent.render() في
/// carrom_board.dart. نفس الـ halos، 4-5 stop gradients، beveled rim،
/// rotated specular sweep، crystal sparkles، gold inscription ring،
/// و back-scatter.
class _StrikerPainter extends CustomPainter {
  _StrikerPainter({required this.skin});
  final StrikerSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    // Leave room for halos/shadow outside the disk.
    final r = math.min(size.width, size.height) / 2 - 4.5;
    final center = Offset(size.width / 2, size.height / 2);
    final special = skin.special;

    // ── Outer glow halo for premium skins ─────────────────────────
    if (special == 'shine_gradient') {
      canvas.drawCircle(
        center,
        r * 1.28,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    } else if (special == 'translucent_sparkle') {
      canvas.drawCircle(
        center,
        r * 1.30,
        Paint()
          ..color = const Color(0xFFB4E7FF).withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // ── Multi-layer shadow ─────────────────────────────────────────
    canvas.drawCircle(
      Offset(center.dx + 0.6, center.dy + 2.2),
      r * 1.08,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
    );
    canvas.drawCircle(
      Offset(center.dx + 0.3, center.dy + 1.1),
      r,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
    );

    // ── Base body — finish-specific shader ────────────────────────
    final paint = Paint();
    switch (special) {
      case 'shine_gradient':
        // Polished gold — 5-stop.
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFFFFF7C2),
            Color(0xFFFFE066),
            Color(0xFFFFD700),
            Color(0xFFA67800),
            Color(0xFF5C4200),
          ],
          stops: [0.0, 0.20, 0.45, 0.82, 1.0],
          center: const Alignment(-0.42, -0.50),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case 'matte_black':
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFF4E4E4E),
            Color(0xFF2A2A2A),
            Color(0xFF111111),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.40, 0.80, 1.0],
          center: const Alignment(-0.35, -0.45),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      case 'translucent_sparkle':
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFFFFFFFF),
            Color(0xFFEAF8FF),
            Color(0xFFA8E0FF),
            Color(0xFF6CB8E8),
            Color(0xFF3A7CB0),
          ],
          stops: [0.0, 0.25, 0.55, 0.85, 1.0],
          center: const Alignment(-0.35, -0.40),
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: r));
        break;
      default: // standard / silver
        paint.shader = RadialGradient(
          colors: const [
            Color(0xFFFFFFFF),
            Color(0xFFE0E8F0),
            Color(0xFFA8B5C2),
            Color(0xFF5A6878),
            Color(0xFF2C3A48),
          ],
          stops: [0.0, 0.22, 0.55, 0.85, 1.0],
          center: const Alignment(-0.40, -0.45),
          radius: 1.05,
        ).createShader(Rect.fromCircle(center: center, radius: r));
    }
    canvas.drawCircle(center, r, paint);

    // ── Beveled inner ring ─────────────────────────────────────────
    final baseColor = skin.color;
    canvas.drawCircle(
      center,
      r * 0.93,
      Paint()
        ..color = Color.lerp(baseColor, Colors.black, 0.50)!
            .withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85,
    );

    // ── Outer sharp rim ───────────────────────────────────────────
    canvas.drawCircle(
      center,
      r - 0.25,
      Paint()
        ..color = Color.lerp(baseColor, Colors.black, 0.70)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // ── Rotated specular sweep ────────────────────────────────────
    canvas.save();
    canvas.translate(center.dx - r * 0.30, center.dy - r * 0.45);
    canvas.rotate(-0.45);
    canvas.scale(1.0, 0.40);
    canvas.drawCircle(
      Offset.zero,
      r * 0.55,
      Paint()
        ..color = Colors.white.withValues(
          alpha: special == 'matte_black' ? 0.18 : 0.65,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.restore();

    // ── Sharp catchlight (top-left) ───────────────────────────────
    canvas.drawCircle(
      Offset(center.dx - r * 0.44, center.dy - r * 0.52),
      r * 0.12,
      Paint()
        ..color = Colors.white.withValues(
          alpha: special == 'matte_black' ? 0.45 : 0.95,
        ),
    );

    // ── Crystal: extra sparkle + ✦ micro-sparkle ──────────────────
    if (special == 'translucent_sparkle') {
      canvas.drawCircle(
        Offset(center.dx + r * 0.30, center.dy + r * 0.25),
        r * 0.08,
        Paint()..color = Colors.white.withValues(alpha: 0.70),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '✦',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.80),
            fontSize: r * 0.55,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Color(0x66FFFFFF), blurRadius: 2.5),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + r * 0.12 - tp.width / 2,
          center.dy - r * 0.20 - tp.height / 2,
        ),
      );
    }

    // ── Gold: inner inscription ring ──────────────────────────────
    if (special == 'shine_gradient') {
      canvas.drawCircle(
        center,
        r * 0.78,
        Paint()
          ..color = const Color(0xFFFFE066).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    // ── Bottom rim-light (back-scatter) for non-matte ─────────────
    if (special != 'matte_black') {
      canvas.drawCircle(
        Offset(center.dx + r * 0.15, center.dy + r * 0.50),
        r * 0.22,
        Paint()
          ..color = Color.lerp(baseColor, Colors.white, 0.50)!
              .withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StrikerPainter old) =>
      old.skin.key != skin.key;
}

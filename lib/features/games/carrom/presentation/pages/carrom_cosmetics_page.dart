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
    // Outer frame (accent)
    final framePaint = Paint();
    if (skin.borderStyle == 'neon_glow') {
      framePaint.shader = LinearGradient(
        colors: [
          skin.accentColor,
          skin.accentColorAlt ?? skin.accentColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    } else if (skin.borderStyle == 'wood') {
      framePaint.shader = LinearGradient(
        colors: [
          skin.accentColor,
          Color.lerp(skin.accentColor, Colors.white, 0.18)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    } else {
      framePaint.color = skin.accentColor;
    }
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(rrect, framePaint);

    // Inner play surface
    final inset = math.min(size.width, size.height) * 0.08;
    final innerRect = rect.deflate(inset);
    final innerRRect =
        RRect.fromRectAndRadius(innerRect, const Radius.circular(6));

    final basePaint = Paint();
    switch (skin.texture) {
      case 'neon':
        basePaint.shader = RadialGradient(
          colors: [
            Color.lerp(skin.baseColor, Colors.white, 0.04)!,
            skin.baseColor,
          ],
          center: Alignment.center,
        ).createShader(innerRect);
        break;
      case 'marble':
        basePaint.shader = LinearGradient(
          colors: [
            skin.baseColor,
            Color.lerp(skin.baseColor, Colors.grey.shade300, 0.18)!,
            skin.baseColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(innerRect);
        break;
      case 'felt':
        basePaint.shader = RadialGradient(
          colors: [
            Color.lerp(skin.baseColor, Colors.white, 0.05)!,
            skin.baseColor,
          ],
        ).createShader(innerRect);
        break;
      default:
        basePaint.shader = LinearGradient(
          colors: [
            skin.baseColor,
            Color.lerp(skin.baseColor, Colors.black, 0.06)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(innerRect);
    }
    canvas.drawRRect(innerRRect, basePaint);

    // 4 pockets (always black)
    final pocketR = math.min(size.width, size.height) * 0.08;
    final pocketPaint = Paint()..color = const Color(0xFF0A0A0A);
    final corners = [
      innerRect.topLeft + Offset(pocketR, pocketR),
      innerRect.topRight + Offset(-pocketR, pocketR),
      innerRect.bottomLeft + Offset(pocketR, -pocketR),
      innerRect.bottomRight + Offset(-pocketR, -pocketR),
    ];
    for (final c in corners) {
      canvas.drawCircle(c, pocketR, pocketPaint);
      canvas.drawCircle(
        c,
        pocketR - 1.5,
        Paint()
          ..color = skin.accentColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Center ring (red queen ring — same in every theme)
    final center = innerRect.center;
    final ringR = math.min(size.width, size.height) * 0.10;
    canvas.drawCircle(
      center,
      ringR,
      Paint()
        ..color = const Color(0xFFC0392B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      ringR * 0.35,
      Paint()..color = const Color(0xCCC0392B),
    );

    // Crown emblem for royal_navy
    if (skin.borderStyle == 'gold_crown') {
      final tp = TextPainter(
        text: TextSpan(
          text: '♛', // black queen unicode — stand-in crown glyph
          style: TextStyle(
            color: skin.accentColor,
            fontSize: ringR * 1.3,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        center - Offset(tp.width / 2, tp.height / 2 + ringR * 1.6),
      );
    }

    // Neon glow overlay for neon_dark
    if (skin.borderStyle == 'neon_glow') {
      final glowPaint = Paint()
        ..color = skin.accentColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(innerRRect.deflate(2), glowPaint);
      if (skin.accentColorAlt != null) {
        canvas.drawRRect(
          innerRRect.deflate(5),
          Paint()
            ..color = skin.accentColorAlt!.withValues(alpha: 0.30)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
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

class _PieceDotPainter extends CustomPainter {
  _PieceDotPainter({required this.color, required this.finish});
  final Color color;
  final String finish;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final c = Offset(size.width / 2, size.height / 2);
    // shadow
    canvas.drawCircle(
      c.translate(1, 2.4),
      r,
      Paint()..color = const Color(0x66000000),
    );
    // base
    Paint base = Paint();
    switch (finish) {
      case 'metallic':
        base.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.35)!,
            color,
            Color.lerp(color, Colors.black, 0.30)!,
          ],
          stops: const [0.0, 0.55, 1.0],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: c, radius: r));
        break;
      case 'jewel':
      case 'gem':
        base.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.45)!,
            color,
            Color.lerp(color, Colors.black, 0.18)!,
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.4, -0.4),
        ).createShader(Rect.fromCircle(center: c, radius: r));
        break;
      default:
        base.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.18)!,
            color,
          ],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: c, radius: r));
    }
    canvas.drawCircle(c, r, base);
    // rim
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Color.lerp(color, Colors.black, 0.40)!.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // highlight
    canvas.drawCircle(
      c.translate(-r * 0.35, -r * 0.35),
      r * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
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

class _StrikerPainter extends CustomPainter {
  _StrikerPainter({required this.skin});
  final StrikerSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final color = skin.color;
    // shadow
    canvas.drawCircle(
      c.translate(2, 3),
      r,
      Paint()..color = const Color(0x88000000),
    );
    // glow for crystal/gold
    if (skin.special == 'translucent_sparkle' ||
        skin.special == 'shine_gradient') {
      canvas.drawCircle(
        c,
        r * 1.15,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    // base
    Paint base = Paint();
    switch (skin.special) {
      case 'shine_gradient':
        base.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.6)!,
            color,
            Color.lerp(color, Colors.brown, 0.4)!,
          ],
          stops: const [0.0, 0.55, 1.0],
          center: const Alignment(-0.35, -0.4),
        ).createShader(Rect.fromCircle(center: c, radius: r));
        break;
      case 'matte_black':
        base.shader = RadialGradient(
          colors: [
            const Color(0xFF3A3A3A),
            const Color(0xFF1A1A1A),
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.7, 1.0],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: c, radius: r));
        break;
      case 'translucent_sparkle':
        base.shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.65),
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.3, -0.3),
        ).createShader(Rect.fromCircle(center: c, radius: r));
        break;
      default:
        base.shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.42)!,
            color,
            Color.lerp(color, Colors.black, 0.30)!,
          ],
          stops: const [0.0, 0.6, 1.0],
          center: const Alignment(-0.3, -0.4),
        ).createShader(Rect.fromCircle(center: c, radius: r));
    }
    canvas.drawCircle(c, r, base);
    // rim
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Color.lerp(color, Colors.black, 0.55)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // sparkle for crystal
    if (skin.special == 'translucent_sparkle') {
      final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(c.translate(-r * 0.3, -r * 0.3), r * 0.10, sparklePaint);
      canvas.drawCircle(c.translate(r * 0.25, r * 0.2), r * 0.06, sparklePaint);
    } else {
      canvas.drawCircle(
        c.translate(-r * 0.35, -r * 0.35),
        r * 0.22,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StrikerPainter old) =>
      old.skin.key != skin.key;
}

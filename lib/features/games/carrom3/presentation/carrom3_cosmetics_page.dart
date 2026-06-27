import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../data/carrom3_prefs.dart';
import '../domain/cosmetics.dart';

String _themeName(AppLocalizations l, String key) {
  switch (key) {
    case 'walnut':
      return l.carromBoardWalnut;
    case 'sapphire':
      return l.carromBoardSapphire;
    case 'emerald':
      return l.carromBoardEmerald;
    default:
      return key;
  }
}

String _coinName(AppLocalizations l, String key) {
  switch (key) {
    case 'classic':
      return l.carromCoinClassic;
    case 'royal':
      return l.carromCoinRoyal;
    case 'vivid':
      return l.carromCoinVivid;
    case 'candy':
      return l.carromCoinCandy;
    default:
      return key;
  }
}

/// Pick a table theme + coin set, and toggle sound. Saves immediately.
class Carrom3CosmeticsPage extends StatefulWidget {
  const Carrom3CosmeticsPage({super.key});

  @override
  State<Carrom3CosmeticsPage> createState() => _Carrom3CosmeticsPageState();
}

class _Carrom3CosmeticsPageState extends State<Carrom3CosmeticsPage> {
  Carrom3Prefs? _prefs;
  String _board = 'walnut';
  String _coin = 'classic';
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await Carrom3Prefs.instance();
    if (!mounted) return;
    setState(() {
      _prefs = p;
      _board = p.boardKey;
      _coin = p.coinKey;
      _muted = p.muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l.carromCosmeticsTitle2,
            style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _Label(l.carromCosmeticsBoard, colors),
            const Gap(10),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kTableThemes.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, i) {
                  final t = kTableThemes[i];
                  return _PickCard(
                    label: _themeName(l, t.key),
                    selected: t.key == _board,
                    accent: colors.moment,
                    colors: colors,
                    painter: _TablePreviewPainter(t),
                    onTap: () {
                      GameHaptics.tap();
                      setState(() => _board = t.key);
                      _prefs?.setBoard(t.key);
                    },
                  );
                },
              ),
            ),
            const Gap(24),
            _Label(l.carromCosmeticsPieces, colors),
            const Gap(10),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kCoinSets.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, i) {
                  final c = kCoinSets[i];
                  return _PickCard(
                    label: _coinName(l, c.key),
                    selected: c.key == _coin,
                    accent: colors.face,
                    colors: colors,
                    painter: _CoinPreviewPainter(c),
                    onTap: () {
                      GameHaptics.tap();
                      setState(() => _coin = c.key);
                      _prefs?.setCoin(c.key);
                    },
                  );
                },
              ),
            ),
            const Gap(24),
            _Label(l.carromCosmeticsSound, colors),
            const Gap(10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: colors.textSecondary.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: colors.textSecondary),
                  const Gap(10),
                  Expanded(
                    child: Text(l.carromCosmeticsMute,
                        style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                  Switch(
                    value: _muted,
                    onChanged: (v) {
                      GameHaptics.tap();
                      setState(() => _muted = v);
                      _prefs?.setMuted(v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.colors);
  final String text;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w800));
}

class _PickCard extends StatelessWidget {
  const _PickCard({
    required this.label,
    required this.selected,
    required this.accent,
    required this.colors,
    required this.painter,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color accent;
  final SarhnyColors colors;
  final CustomPainter painter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? accent
                : colors.textSecondary.withValues(alpha: 0.18),
            width: selected ? 2 : 0.8,
          ),
        ),
        child: Column(
          children: [
            const Gap(8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(painter: painter, size: const Size(96, 80)),
              ),
            ),
            const Gap(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Icon(Icons.check_circle_rounded, size: 14, color: accent),
                  const Gap(4),
                ],
                Text(label,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}

class _TablePreviewPainter extends CustomPainter {
  _TablePreviewPainter(this.theme);
  final TableTheme theme;
  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(colors: [theme.frameTop, theme.frameBottom])
            .createShader(r),
    );
    final play = r.deflate(10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(play, const Radius.circular(6)),
      Paint()
        ..shader = RadialGradient(
          colors: [theme.feltCenter, theme.feltMid, theme.feltEdge],
        ).createShader(play),
    );
    canvas.drawCircle(play.center, 9,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = theme.lineSoft);
    for (final c in [play.topLeft, play.topRight, play.bottomLeft, play.bottomRight]) {
      canvas.drawCircle(c, 7, Paint()..color = const Color(0xFF120B03));
      canvas.drawCircle(
          c, 7, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = theme.pocketRimA);
    }
  }

  @override
  bool shouldRepaint(covariant _TablePreviewPainter old) => old.theme != theme;
}

class _CoinPreviewPainter extends CustomPainter {
  _CoinPreviewPainter(this.set);
  final CoinSet set;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      Paint()..color = const Color(0xFF2A2421),
    );
    final r = 13.0;
    final cy = size.height / 2;
    final mats = [set.white, set.black, queenMaterial, set.striker];
    final n = mats.length;
    for (var i = 0; i < n; i++) {
      final cx = size.width * (i + 1) / (n + 1);
      _coin(canvas, Offset(cx, cy), r, mats[i]);
    }
  }

  void _coin(Canvas canvas, Offset ctr, double r, CoinMaterial m) {
    canvas.drawCircle(ctr + Offset(r * 0.16, r * 0.2), r,
        Paint()..color = const Color(0x44000000));
    final rect = Rect.fromCircle(center: ctr, radius: r);
    canvas.drawCircle(
      ctr,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [m.highlight, m.base, m.edge],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(ctr, r * 0.96,
        Paint()..style = PaintingStyle.stroke..strokeWidth = r * 0.08..color = m.rim);
    canvas.drawCircle(ctr + Offset(-r * 0.4, -r * 0.44), r * 0.12,
        Paint()..color = const Color(0xCCFFFFFF));
  }

  @override
  bool shouldRepaint(covariant _CoinPreviewPainter old) => old.set != set;
}

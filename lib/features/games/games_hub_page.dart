import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import 'carrom/application/carrom_controllers.dart';

/// "الساحة" — Games hub.
///
/// Designed to feel like an arcade lobby, not a settings list. Hero header
/// pulses a moment→face→mind gradient (Sarhny's tri-color identity), a
/// featured Carrom card sits at the top with a live carrom-board preview
/// painter, RPS sits below as a smaller-but-distinct card, and Ludo waits
/// as a teaser. A footer row gives one-tap shortcuts to cosmetics + how
/// the points economy works.
class GamesHubPage extends ConsumerStatefulWidget {
  const GamesHubPage({super.key});
  @override
  ConsumerState<GamesHubPage> createState() => _GamesHubPageState();
}

class _GamesHubPageState extends ConsumerState<GamesHubPage>
    with TickerProviderStateMixin {
  late final AnimationController _heroPulse;
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _heroPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _heroPulse.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final walletAsync = ref.watch(carromWalletProvider);
    final balance = walletAsync.maybeWhen(
      data: (w) => w.points,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.feed);
            }
          },
        ),
        title: Text(
          'الساحة',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── Hero block with wallet + tagline ───────────────────
            _HeroBlock(
              colors: colors,
              pulse: _heroPulse,
              balance: balance,
              onWalletTap: () {
                // Future: open wallet sheet. For now, no-op.
              },
            ),
            const SizedBox(height: 24),

            // ── Section heading ───────────────────────────────────
            _SectionHeading(
              title: 'الألعاب المتاحة',
              subtitle: 'تحدَّ. اربح. اكشف.',
              colors: colors,
            ),
            const SizedBox(height: 14),

            // ── Featured: Carrom 1v1 (premium card) ───────────────
            _CarromFeatureCard(
              colors: colors,
              shimmer: _shimmer,
              onTap: () => context.push(AppRoutes.carromLobby),
            ),
            const SizedBox(height: 14),

            // ── RPS-Question card ─────────────────────────────────
            _RpsCard(
              colors: colors,
              onTap: () => context.push(AppRoutes.gameLobby),
            ),
            const SizedBox(height: 14),

            // ── Ludo card (active) ────────────────────────────────
            _LudoFeatureCard(
              colors: colors,
              shimmer: _shimmer,
              onTap: () => context.push(AppRoutes.ludoLobby),
            ),
            const SizedBox(height: 28),

            // ── Footer shortcuts: cosmetics + how-to-earn ─────────
            _SectionHeading(
              title: 'تخصيص وأكثر',
              subtitle: null,
              colors: colors,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ShortcutTile(
                    icon: '🎨',
                    label: 'خصص ساحتك',
                    desc: 'الطاولة + القطع + المضرب',
                    colors: colors,
                    accent: colors.moment,
                    onTap: () => context.push(AppRoutes.carromCosmetics),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ShortcutTile(
                    icon: '✦',
                    label: 'كيف تربح نقاطاً',
                    desc: 'رسائل + إعلانات + مباريات',
                    colors: colors,
                    accent: colors.crystal,
                    onTap: () => _showEarnSheet(context, colors),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEarnSheet(BuildContext context, SarhnyColors colors) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Widget row(String emoji, String title, String delta) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    delta,
                    style: TextStyle(
                      color: colors.crystal,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            );
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'كيف تربح النقاط',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              row('🎁', 'هدية التسجيل', '+300'),
              row('🏆', 'فوز في مباراة', '+300'),
              row('💌', 'استلمت رسالة صراحة', '+2'),
              row('📺', 'مشاهدة إعلان (يومياً 10)', '+1'),
              const SizedBox(height: 8),
              Text(
                'النقاط = دخول الطاولات + الكشف بعد المباراة + الامتناع عن أسئلة.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Hero block — pulsing tri-gradient with wallet chip
// ─────────────────────────────────────────────────────────────────────

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({
    required this.colors,
    required this.pulse,
    required this.balance,
    required this.onWalletTap,
  });

  final SarhnyColors colors;
  final Animation<double> pulse;
  final int? balance;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final t = pulse.value;
        // Three overlapping radial glows that drift slowly — gives an
        // ambient "energy" without the cost of a particle system.
        return Container(
          height: 168,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.lerp(colors.moment, colors.face, t)!.withValues(alpha: 0.22),
                Color.lerp(colors.face, colors.mind, t)!.withValues(alpha: 0.20),
                Color.lerp(colors.mind, colors.moment, t)!.withValues(alpha: 0.18),
              ],
            ),
            border: Border.all(
              color: colors.moment.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.moment.withValues(alpha: 0.18 + 0.06 * math.sin(t * math.pi * 2)),
                blurRadius: 26,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Drifting orbs in the background.
              Positioned(
                top: -20 + 8 * math.sin(t * math.pi * 2),
                right: -10 + 6 * math.cos(t * math.pi * 2),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.moment.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -20 - 5 * math.sin(t * math.pi * 2),
                left: -10,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.mind.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22D3A0),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF22D3A0).withValues(alpha: 0.7),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'مباشر الآن',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onWalletTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: colors.crystal.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '✦',
                                style: TextStyle(
                                  color: colors.crystal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                balance == null ? '...' : '$balance',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ساحة صارحني',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Tajawal',
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'تحدّى منافساً، اربح نقاطه، ثم اكشف من كان',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Section heading
// ─────────────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.colors,
  });
  final String title;
  final String? subtitle;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.moment, colors.mind],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '· $subtitle',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Featured Carrom card — large, with board painter + reward badge
// ─────────────────────────────────────────────────────────────────────

class _CarromFeatureCard extends StatelessWidget {
  const _CarromFeatureCard({
    required this.colors,
    required this.shimmer,
    required this.onTap,
  });
  final SarhnyColors colors;
  final Animation<double> shimmer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF8B5A2B).withValues(alpha: 0.55),  // warm wood
              const Color(0xFF1E3A5F).withValues(alpha: 0.75),  // royal navy
              const Color(0xFF0A0E27).withValues(alpha: 0.85),  // deep night
            ],
          ),
          border: Border.all(color: colors.crystal.withValues(alpha: 0.45), width: 1.3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Painted mini carrom-board fading to the right.
              Positioned.fill(
                child: CustomPaint(
                  painter: _CarromMiniBoardPainter(),
                ),
              ),
              // Dark scrim on the left so text stays readable.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),

              // Shimmer sweep across the gold border.
              AnimatedBuilder(
                animation: shimmer,
                builder: (context, _) {
                  return Positioned(
                    top: 0,
                    bottom: 0,
                    left: -120 + 480 * shimmer.value,
                    width: 140,
                    child: Transform.rotate(
                      angle: -0.45,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.10),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _MiniBadge(
                                text: 'جديد',
                                bg: const Color(0xFFD4AF37),
                                fg: const Color(0xFF1A1A1A),
                              ),
                              const SizedBox(width: 8),
                              _MiniBadge(
                                text: '1v1',
                                bg: Colors.white.withValues(alpha: 0.18),
                                fg: Colors.white,
                                border: Colors.white.withValues(alpha: 0.30),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'كيرم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Tajawal',
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تحدَّ منافساً مجهولاً — اربح ٣٠٠ نقطة',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37)
                                          .withValues(alpha: 0.55),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ابدأ مباراة',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_back,
                                      color: Color(0xFF1A1A1A),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarromMiniBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Mini carrom board sits on the right side of the card.
    final boardSize = size.height * 0.85;
    final cx = size.width - boardSize / 2 - 12;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: boardSize, height: boardSize);

    // Frame
    final frame = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      frame,
    );

    // Inner board surface (warm cream)
    final surface = Paint()
      ..color = const Color(0xFFE8C49A).withValues(alpha: 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(6)),
      surface,
    );

    // 4 pockets
    final pocket = Paint()..color = const Color(0xFF0A0A0A).withValues(alpha: 0.85);
    final pr = boardSize * 0.06;
    final off = boardSize * 0.10;
    canvas.drawCircle(Offset(rect.left + off, rect.top + off), pr, pocket);
    canvas.drawCircle(Offset(rect.right - off, rect.top + off), pr, pocket);
    canvas.drawCircle(Offset(rect.left + off, rect.bottom - off), pr, pocket);
    canvas.drawCircle(Offset(rect.right - off, rect.bottom - off), pr, pocket);

    // Center ring (queen position)
    final ring = Paint()
      ..color = const Color(0xFFDC143C).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), boardSize * 0.08, ring);

    // 6 pieces around the center for richness
    final pieceR = boardSize * 0.035;
    final orbitR = boardSize * 0.14;
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi + math.pi / 6;
      final isWhite = i.isEven;
      final paint = Paint()
        ..color = isWhite
            ? Colors.white.withValues(alpha: 0.85)
            : const Color(0xFF1A1A1A).withValues(alpha: 0.85);
      canvas.drawCircle(
        Offset(cx + orbitR * math.cos(angle), cy + orbitR * math.sin(angle)),
        pieceR,
        paint,
      );
    }

    // Queen at center
    final queen = Paint()..color = const Color(0xFFDC143C);
    canvas.drawCircle(Offset(cx, cy), pieceR, queen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────
//  RPS-Question card — gradient with 3 floating glyphs
// ─────────────────────────────────────────────────────────────────────

class _RpsCard extends ConsumerWidget {
  const _RpsCard({required this.colors, required this.onTap});
  final SarhnyColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              colors.face.withValues(alpha: 0.30),
              colors.mind.withValues(alpha: 0.30),
              colors.surface,
            ],
          ),
          border: Border.all(color: colors.face.withValues(alpha: 0.40), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Floating glyphs in the background.
              Positioned(
                top: 14,
                right: 22,
                child: Transform.rotate(
                  angle: -0.30,
                  child: Text(
                    '✊',
                    style: TextStyle(
                      fontSize: 48,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 80,
                child: Transform.rotate(
                  angle: 0.10,
                  child: Text(
                    '✋',
                    style: TextStyle(
                      fontSize: 38,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 30,
                child: Transform.rotate(
                  angle: 0.30,
                  child: Text(
                    '✌️',
                    style: TextStyle(
                      fontSize: 38,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),

              // Text content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniBadge(
                      text: 'تحدّى صريح',
                      bg: colors.face.withValues(alpha: 0.30),
                      fg: colors.face,
                      border: colors.face.withValues(alpha: 0.55),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حجر · ورقة · مقص',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'الفائز يطرح سؤالاً صادقاً — والخاسر يجيب',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron at the bottom-left
              Positioned(
                left: 14,
                bottom: 14,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: colors.background,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Ludo feature card — active, mini-board + dice + CTA
// ─────────────────────────────────────────────────────────────────────

class _LudoFeatureCard extends StatelessWidget {
  const _LudoFeatureCard({
    required this.colors,
    required this.shimmer,
    required this.onTap,
  });
  final SarhnyColors colors;
  final Animation<double> shimmer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xCC3F1F6E), // royal violet
              Color(0xCC0F2C4F), // deep blue
              Color(0xE5050E27), // night
            ],
          ),
          border: Border.all(
            color: colors.crystal.withValues(alpha: 0.45),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Painted mini ludo board fading to the right.
              Positioned.fill(
                child: CustomPaint(painter: _LudoHubMiniBoardPainter()),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              // Shimmer sweep
              AnimatedBuilder(
                animation: shimmer,
                builder: (context, _) {
                  return Positioned(
                    top: 0,
                    bottom: 0,
                    left: -120 + 480 * shimmer.value,
                    width: 140,
                    child: Transform.rotate(
                      angle: -0.45,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _MiniBadge(
                                text: 'جديد',
                                bg: const Color(0xFFD4AF37),
                                fg: const Color(0xFF1A1A1A),
                              ),
                              const SizedBox(width: 8),
                              _MiniBadge(
                                text: '2-4',
                                bg: Colors.white.withValues(alpha: 0.18),
                                fg: Colors.white,
                                border: Colors.white.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'لودو',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Tajawal',
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الزهر يقرر — والفائز يأخذ كل النقاط',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37)
                                          .withValues(alpha: 0.55),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'العب الآن',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_back,
                                      color: Color(0xFF1A1A1A),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LudoHubMiniBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = size.height * 0.85;
    final cx = size.width - boardSize / 2 - 12;
    final cy = size.height / 2;
    final origin = Offset(cx - boardSize / 2, cy - boardSize / 2);
    final cs = boardSize / 15;

    // gold frame
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: boardSize,
      height: boardSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF0E1320),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 4 home corners
    const palette = [
      Color(0xFFE53935),
      Color(0xFF43A047),
      Color(0xFFFDD835),
      Color(0xFF1E88E5),
    ];
    final centers = [
      const Offset(3, 3),
      const Offset(11, 3),
      const Offset(11, 11),
      const Offset(3, 11),
    ];
    for (int i = 0; i < 4; i++) {
      final r = Rect.fromCenter(
        center: Offset(
          origin.dx + (centers[i].dx + 0.5) * cs,
          origin.dy + (centers[i].dy + 0.5) * cs,
        ),
        width: cs * 6,
        height: cs * 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        Paint()..color = palette[i].withValues(alpha: 0.35),
      );
    }

    // center triangle
    final left = origin.dx + 6 * cs;
    final top = origin.dy + 6 * cs;
    final sz = 3 * cs;
    final center = Offset(left + sz / 2, top + sz / 2);
    final corners = [
      Offset(left, top),
      Offset(left + sz, top),
      Offset(left + sz, top + sz),
      Offset(left, top + sz),
    ];
    final tris = [
      (palette[0], [corners[0], corners[3], center]),
      (palette[1], [corners[0], corners[1], center]),
      (palette[2], [corners[1], corners[2], center]),
      (palette[3], [corners[2], corners[3], center]),
    ];
    for (final t in tris) {
      final p = Path()
        ..moveTo(t.$2[0].dx, t.$2[0].dy)
        ..lineTo(t.$2[1].dx, t.$2[1].dy)
        ..lineTo(t.$2[2].dx, t.$2[2].dy)
        ..close();
      canvas.drawPath(p, Paint()..color = t.$1);
    }

    // crown
    canvas.drawCircle(
      center,
      cs * 0.55,
      Paint()..color = const Color(0xFFD4AF37),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────
//  Ludo teaser — dimmed "coming soon" card (retained but unused)
// ─────────────────────────────────────────────────────────────────────

// ignore: unused_element
class _LudoTeaserCard extends StatelessWidget {
  const _LudoTeaserCard({required this.colors});
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surface,
        border: Border.all(
          color: colors.border.withValues(alpha: 0.50),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 0.6),
            ),
            alignment: Alignment.center,
            child: const Text(
              '🎲',
              style: TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'لودو',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.elevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.border, width: 0.6),
                      ),
                      child: Text(
                        'قريباً',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '٢-٤ لاعبين · صواريخ وبلورات',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Shortcut tile (cosmetics + how-to-earn)
// ─────────────────────────────────────────────────────────────────────

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.desc,
    required this.colors,
    required this.accent,
    required this.onTap,
  });
  final String icon;
  final String label;
  final String desc;
  final SarhnyColors colors;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accent.withValues(alpha: 0.32),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 20,
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Mini badge widget — reused for ribbon-style labels
// ─────────────────────────────────────────────────────────────────────

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.text,
    required this.bg,
    required this.fg,
    this.border,
  });
  final String text;
  final Color bg;
  final Color fg;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: border != null ? Border.all(color: border!, width: 0.8) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}


import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../application/ludo_controllers.dart';
import '../../data/ludo_api.dart';
import '../../domain/ludo_state.dart';
import '../../domain/ludo_token.dart';
import '../widgets/ludo_board_geometry.dart';

/// Lobby للودو — 2p/4p toggle + بحث + دعوة صديق + استلام دعوة.
class LudoLobbyPage extends ConsumerStatefulWidget {
  const LudoLobbyPage({super.key});
  @override
  ConsumerState<LudoLobbyPage> createState() => _LudoLobbyPageState();
}

class _LudoLobbyPageState extends ConsumerState<LudoLobbyPage>
    with TickerProviderStateMixin {
  LudoMode _mode = LudoMode.fourPlayer;
  bool _busy = false;
  final _inviteCtrl = TextEditingController();
  late final AnimationController _bgPulse;

  @override
  void initState() {
    super.initState();
    _bgPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _bgPulse.dispose();
    _inviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _startRandom() async {
    setState(() => _busy = true);
    try {
      if (!mounted) return;
      context.push('${AppRoutes.ludoMatchmaking}?mode=${_mode.wire}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createInvite() async {
    setState(() => _busy = true);
    try {
      final inv = await ref.read(ludoApiProvider).createInvite(_mode);
      if (!mounted) return;
      _showInviteSheet(inv.inviteCode, inv.roomId);
    } on LudoApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر إنشاء الدعوة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _redeemInvite() async {
    final code = _inviteCtrl.text.trim();
    if (code.isEmpty) {
      Fluttertoast.showToast(msg: 'الصق رمز الدعوة أولاً');
      return;
    }
    setState(() => _busy = true);
    try {
      final res = await ref.read(ludoApiProvider).redeemInvite(code);
      if (!mounted) return;
      context.push(AppRoutes.ludoMatch(res.roomId));
    } on LudoApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر الانضمام للدعوة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showInviteSheet(String code, String roomId) {
    final colors = context.sarhnyColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'رمز دعوتك',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SelectableText(
                code,
                style: TextStyle(
                  color: colors.crystal,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'صلاحية الرمز 5 دقائق. شارك الرمز لينضموا للمباراة.',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        Fluttertoast.showToast(msg: 'نُسخ الرمز');
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('نسخ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.push(AppRoutes.ludoMatch(roomId));
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('ادخل الغرفة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final walletAsync = ref.watch(ludoWalletProvider);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('لودو'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.feed);
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: walletAsync.when(
              data: (w) => _WalletPill(points: w.points, colors: colors),
              loading: () => _WalletPill(points: null, colors: colors),
              error: (_, __) => _WalletPill(points: null, colors: colors),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero board preview ──
              AnimatedBuilder(
                animation: _bgPulse,
                builder: (context, _) {
                  final t = _bgPulse.value;
                  return Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          const Color(0xFF8B5A2B)
                              .withValues(alpha: 0.55 + 0.10 * math.sin(t * math.pi * 2)),
                          const Color(0xFF1E3A5F).withValues(alpha: 0.75),
                          const Color(0xFF0A0E27).withValues(alpha: 0.85),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.55),
                        width: 1.3,
                      ),
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
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MiniLudoBoardPainter(progress: t),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topLeft,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4AF37),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Text(
                                        'جديد',
                                        style: TextStyle(
                                          color: Color(0xFF1A1A1A),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.30),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Text(
                                        '2-4 لاعبين',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'لودو الذهبي',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Tajawal',
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'الزهر يقرر، والشجاعة تربح',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
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
                  );
                },
              ),
              const SizedBox(height: 18),

              // ── Mode toggle ──
              _SectionTitle('اختر نمط اللعب', colors),
              const SizedBox(height: 10),
              _ModeToggle(
                current: _mode,
                onChanged: (m) => setState(() => _mode = m),
                colors: colors,
              ),
              const SizedBox(height: 22),

              // ── CTAs ──
              FilledButton.icon(
                onPressed: _busy ? null : _startRandom,
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: Text(
                  _busy ? 'لحظة…' : 'ابدأ مباراة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: colors.crystal,
                  foregroundColor: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _busy ? null : _createInvite,
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('العب مع أصدقاء'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 18),

              // ── Join by code ──
              _SectionTitle('انضم بدعوة', colors),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inviteCtrl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'الصق الرمز',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _busy ? null : _redeemInvite,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(96, 50),
                    ),
                    child: const Text('انضم'),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Wallet summary ──
              walletAsync.maybeWhen(
                data: (w) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border, width: 0.6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.savings_rounded,
                          color: colors.crystal, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دخول ${w.entryFee} — الفائز يأخذ ${w.pot}',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'رصيدك الحالي ${w.points} نقطة',
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
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.colors);
  final String text;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.moment, colors.crystal],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.current,
    required this.onChanged,
    required this.colors,
  });
  final LudoMode current;
  final ValueChanged<LudoMode> onChanged;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeTab(
              label: '٢ لاعبين',
              icon: Icons.people_alt_outlined,
              active: current == LudoMode.twoPlayer,
              onTap: () => onChanged(LudoMode.twoPlayer),
              colors: colors,
            ),
          ),
          Expanded(
            child: _ModeTab(
              label: '٤ لاعبين',
              icon: Icons.groups_rounded,
              active: current == LudoMode.fourPlayer,
              onTap: () => onChanged(LudoMode.fourPlayer),
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final SarhnyColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? colors.crystal.withValues(alpha: 0.18) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? colors.crystal : Colors.transparent,
            width: 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: colors.crystal.withValues(alpha: 0.35),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? colors.crystal : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? colors.textPrimary : colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.points, required this.colors});
  final int? points;
  final SarhnyColors colors;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.crystal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.crystal.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✦',
            style: TextStyle(
              color: colors.crystal,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            points == null ? '…' : '$points',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini board painter — for the lobby hero card.
class _MiniLudoBoardPainter extends CustomPainter {
  _MiniLudoBoardPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Right-side mini board, decorative only.
    final boardSize = size.height * 0.85;
    final cx = size.width - boardSize / 2 - 14;
    final cy = size.height / 2;
    final origin = Offset(cx - boardSize / 2, cy - boardSize / 2);
    final cs = boardSize / 15;

    // gold frame
    final frameRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: boardSize,
      height: boardSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1A1F2E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 4 home base tiles
    final colors = LudoColor.values;
    for (int seat = 0; seat < 4; seat++) {
      final c = LudoBoardGeometry.homeBaseCenter(colors[seat]);
      final r = Rect.fromCenter(
        center: Offset(origin.dx + (c.$1 + 0.5) * cs,
            origin.dy + (c.$2 + 0.5) * cs),
        width: cs * 6,
        height: cs * 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()..color = colors[seat].primary.withValues(alpha: 0.28),
      );
    }

    // tracks (just outline as cross)
    final trackPaint = Paint()..color = const Color(0xFFEDE6D2).withValues(alpha: 0.85);
    for (final c in LudoBoardGeometry.trackCells) {
      final r = Rect.fromLTWH(
        origin.dx + c.$1 * cs,
        origin.dy + c.$2 * cs,
        cs,
        cs,
      );
      canvas.drawRect(r.deflate(0.3), trackPaint);
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
    final mapping = [
      (colors[0], [corners[0], corners[3], center]),
      (colors[1], [corners[0], corners[1], center]),
      (colors[2], [corners[1], corners[2], center]),
      (colors[3], [corners[2], corners[3], center]),
    ];
    for (final m in mapping) {
      final p = Path()
        ..moveTo(m.$2[0].dx, m.$2[0].dy)
        ..lineTo(m.$2[1].dx, m.$2[1].dy)
        ..lineTo(m.$2[2].dx, m.$2[2].dy)
        ..close();
      canvas.drawPath(p, Paint()..color = m.$1.primary);
    }

    // floating dice in upper-left
    final diceR = boardSize * 0.16;
    final dx = origin.dx - diceR * 0.6 + 6 * math.sin(progress * math.pi * 2);
    final dy = origin.dy - diceR * 0.4 - 4 * math.cos(progress * math.pi * 2);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(dx, dy, diceR, diceR),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xFFFFFAEB),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    // 5 pips
    final pipColor = Paint()..color = const Color(0xFF1A1A1A);
    final pipR = diceR * 0.07;
    final corners2 = [
      Offset(dx + diceR * 0.25, dy + diceR * 0.25),
      Offset(dx + diceR * 0.75, dy + diceR * 0.25),
      Offset(dx + diceR * 0.25, dy + diceR * 0.75),
      Offset(dx + diceR * 0.75, dy + diceR * 0.75),
      Offset(dx + diceR * 0.5, dy + diceR * 0.5),
    ];
    for (final p in corners2) {
      canvas.drawCircle(p, pipR, pipColor);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniLudoBoardPainter old) =>
      old.progress != progress;
}

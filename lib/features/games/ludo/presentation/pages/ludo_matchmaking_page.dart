import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../application/ludo_match_state.dart';
import '../../domain/ludo_state.dart';
import '../../domain/ludo_token.dart';
import '../widgets/ludo_board_geometry.dart';

/// شاشة الانتظار — 4 ألوان تدور حول دائرة + cancel.
class LudoMatchmakingPage extends ConsumerStatefulWidget {
  const LudoMatchmakingPage({super.key, required this.mode});
  final LudoMode mode;

  @override
  ConsumerState<LudoMatchmakingPage> createState() =>
      _LudoMatchmakingPageState();
}

class _LudoMatchmakingPageState extends ConsumerState<LudoMatchmakingPage>
    with TickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(ludoMatchmakingControllerProvider.notifier)
          .start(widget.mode);
    });
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final snap = ref.watch(ludoMatchmakingControllerProvider);

    ref.listen<LudoMatchmakingSnapshot>(
      ludoMatchmakingControllerProvider,
      (prev, next) {
        final id = next.roomId;
        if (id != null && (prev?.roomId == null)) {
          context.pushReplacement(AppRoutes.ludoMatch(id));
        }
      },
    );

    final elapsed = snap.elapsedSeconds;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () async {
                    await ref
                        .read(ludoMatchmakingControllerProvider.notifier)
                        .cancel();
                    if (context.mounted) context.pop();
                  },
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _orbit,
                builder: (ctx, _) {
                  return SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // outer pulse rings
                        for (var i = 0; i < 3; i++)
                          Opacity(
                            opacity: 1 - ((_orbit.value + i / 3) % 1),
                            child: Container(
                              width: 100 + ((_orbit.value + i / 3) % 1) * 160,
                              height: 100 + ((_orbit.value + i / 3) % 1) * 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.crystal.withValues(alpha: 0.55),
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                        // central dice icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.crystal.withValues(alpha: 0.15),
                            border: Border.all(
                              color: colors.crystal,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '🎲',
                            style: TextStyle(fontSize: 52),
                          ),
                        ),
                        // 4 orbiting tokens (red, green, yellow, blue)
                        for (int i = 0; i < 4; i++)
                          Transform.translate(
                            offset: Offset(
                              math.cos(_orbit.value * 2 * math.pi +
                                      i * math.pi / 2) *
                                  110,
                              math.sin(_orbit.value * 2 * math.pi +
                                      i * math.pi / 2) *
                                  110,
                            ),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: const Alignment(-0.3, -0.4),
                                  colors: [
                                    Color.lerp(
                                        LudoColor.values[i].primary,
                                        Colors.white,
                                        0.5)!,
                                    LudoColor.values[i].primary,
                                    LudoColor.values[i].dark,
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                snap.error != null
                    ? 'تعذّر البحث عن منافسين'
                    : (widget.mode == LudoMode.fourPlayer
                        ? 'البحث عن ٣ منافسين...'
                        : 'البحث عن منافس...'),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                snap.queuePosition != null
                    ? 'ترتيبك في الطابور: ${snap.queuePosition}'
                    : (snap.error ?? 'متوسط الانتظار أقل من 45 ثانية'),
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: colors.crystal,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(ludoMatchmakingControllerProvider.notifier)
                        .cancel();
                    if (context.mounted) context.pop();
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('إلغاء البحث'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

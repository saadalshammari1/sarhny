import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../application/carrom_v2_controller.dart';

/// Lobby that polls /carrom-v2/match/start every 3s until matched.
/// On match, navigates to the online match page with room_id + seat.
class CarromV2MatchmakingPage extends ConsumerStatefulWidget {
  const CarromV2MatchmakingPage({super.key});
  @override
  ConsumerState<CarromV2MatchmakingPage> createState() =>
      _CarromV2MatchmakingPageState();
}

class _CarromV2MatchmakingPageState
    extends ConsumerState<CarromV2MatchmakingPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  Timer? _poller;
  int _elapsed = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMatchmaking());
    _poller = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += 1);
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _startMatchmaking() async {
    try {
      final api = ref.read(carromV2ApiProvider);
      // First call.
      var resp = await api.startMatch();
      while (mounted && !resp.isMatched) {
        await Future<void>.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        resp = await api.startMatch();
      }
      if (!mounted) return;
      GameHaptics.uiPop();
      context.pushReplacement(
        '${AppRoutes.carromV2Match}?room=${resp.roomId}&seat=${resp.mySeat}',
      );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
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
                  onPressed: () {
                    GameHaptics.tap();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Opacity(
                        opacity: (1 - ((_pulse.value + i / 3) % 1)),
                        child: Container(
                          width: 120 + ((_pulse.value + i / 3) % 1) * 140,
                          height: 120 + ((_pulse.value + i / 3) % 1) * 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.moment.withValues(alpha: 0.55),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.moment.withValues(alpha: 0.15),
                        border: Border.all(color: colors.moment, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🎯', style: TextStyle(fontSize: 52)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _error != null
                    ? 'تعذّر البحث'
                    : 'البحث عن منافس...',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error ?? 'متوسط الانتظار أقل من ٣٠ ثانية',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Text(
                '${(_elapsed ~/ 60).toString().padLeft(2, '0')}:${(_elapsed % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: colors.crystal,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    GameHaptics.tap();
                    Navigator.of(context).pop();
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

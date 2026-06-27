import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/haptics/game_haptics.dart';
import '../data/carrom3_api.dart';

/// Carrom v3 online lobby — polls `/carrom3/match/start` until paired, then
/// hands off to the online match page with the assigned room + seat.
class Carrom3MatchmakingPage extends ConsumerStatefulWidget {
  const Carrom3MatchmakingPage({super.key});
  @override
  ConsumerState<Carrom3MatchmakingPage> createState() =>
      _Carrom3MatchmakingPageState();
}

class _Carrom3MatchmakingPageState extends ConsumerState<Carrom3MatchmakingPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  Timer? _ticker;
  int _elapsed = 0;
  bool _stopped = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += 1);
    });
  }

  @override
  void dispose() {
    _stopped = true;
    _ticker?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final l = AppLocalizations.of(context);
    final api = ref.read(carrom3ApiProvider);
    try {
      var resp = await api.startMatch();
      while (mounted && !_stopped && !resp.isMatched) {
        await Future<void>.delayed(const Duration(seconds: 3));
        if (!mounted || _stopped) return;
        resp = await api.startMatch();
      }
      if (!mounted || _stopped) return;
      GameHaptics.uiPop();
      context.pushReplacement(
        '${AppRoutes.carrom3OnlineMatch}?room=${resp.roomId}&seat=${resp.mySeat}',
      );
    } catch (e) {
      if (mounted) setState(() => _error = l.errorServerUnreachable);
    }
  }

  Future<void> _cancel() async {
    _stopped = true;
    GameHaptics.tap();
    await ref.read(carrom3ApiProvider).cancel();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sarhnyColors;
    final l = AppLocalizations.of(context);
    // Inherit the app's direction (set from the active locale) — don't force
    // RTL, or non-Arabic users get a mirrored matchmaking screen.
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
                    onPressed: _cancel,
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
                  _error != null ? l.carromMmSearchFailed : l.carromMmSearching,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _error ?? l.carromMmRaceHint,
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
                if (_error != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _stopped = false;
                        });
                        _search();
                      },
                      child: Text(l.commonRetry),
                    ),
                  ),
                if (_error != null) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(l.carromMmCancel),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

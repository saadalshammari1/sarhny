import 'dart:async';

import 'package:flutter/material.dart';

/// Quick-chat bubble يطفو فوق اللوحة لـ Ludo.
///
/// - scale-in elasticOut عند الظهور.
/// - fade-out بعد [showFor].
/// - يحترم MediaQuery.disableAnimations.
class LudoChatBubble extends StatefulWidget {
  const LudoChatBubble({
    super.key,
    required this.emoji,
    required this.text,
    required this.fromSeat,
    required this.accentColor,
    this.showFor = const Duration(seconds: 3),
    this.onDismissed,
  });

  final String emoji;
  final String text;
  final int fromSeat; // 0..3
  final Color accentColor;
  final Duration showFor;
  final VoidCallback? onDismissed;

  @override
  State<LudoChatBubble> createState() => _LudoChatBubbleState();
}

class _LudoChatBubbleState extends State<LudoChatBubble>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _dismissTimer;
  bool _dismissed = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.5, end: 1.0));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce != _reduceMotion || !_scaleCtrl.isAnimating) {
      _reduceMotion = reduce;
      _scaleCtrl.duration = reduce
          ? Duration.zero
          : const Duration(milliseconds: 280);
      _fadeCtrl.duration = reduce
          ? Duration.zero
          : const Duration(milliseconds: 220);
    }
    if (_scaleCtrl.status == AnimationStatus.dismissed && !_dismissed) {
      _scaleCtrl.forward();
      _dismissTimer?.cancel();
      _dismissTimer = Timer(widget.showFor, _startDismiss);
    }
  }

  void _startDismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    _fadeCtrl.reverse().whenComplete(() {
      if (!mounted) return;
      widget.onDismissed?.call();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.bottomLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

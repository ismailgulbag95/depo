import 'dart:math';
import 'package:flutter/material.dart';

/// Oyun ekran sarsıntısı denetleyicisi (Screen Shake & Juice)
class GameScreenShake extends StatefulWidget {
  final Widget child;
  final GameScreenShakeController? controller;

  const GameScreenShake({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<GameScreenShake> createState() => _GameScreenShakeState();
}

class _GameScreenShakeState extends State<GameScreenShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Random _rnd = Random();
  double _intensity = 6.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant GameScreenShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void triggerShake({double intensity = 6.0, Duration? duration}) {
    if (!mounted) return;
    _intensity = intensity;
    if (duration != null) {
      _animController.duration = duration;
    }
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        if (!_animController.isAnimating) {
          return child!;
        }

        final progress = 1.0 - _animController.value;
        final dx = (_rnd.nextDouble() * 2 - 1) * _intensity * progress;
        final dy = (_rnd.nextDouble() * 2 - 1) * _intensity * progress;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Ekran sarsıntısını dışarıdan tetiklemek için Controller
class GameScreenShakeController {
  _GameScreenShakeState? _state;

  void _attach(_GameScreenShakeState state) {
    _state = state;
  }

  void shake({double intensity = 6.0, Duration? duration}) {
    _state?.triggerShake(intensity: intensity, duration: duration);
  }
}

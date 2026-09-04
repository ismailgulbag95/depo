import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';

/// Amerikan Müzayede & Tasfiye Resmi Kaşe Damgası ("SATILDI", "KÂRLI", "ZARAR")
class AuctionStamp extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;
  final double angle;
  final bool animateOnMount;

  const AuctionStamp({
    super.key,
    required this.text,
    this.color = GameColors.lossRed,
    this.fontSize = 24,
    this.angle = -0.15, // Yaklaşık -8.5 derece
    this.animateOnMount = true,
  });

  @override
  State<AuctionStamp> createState() => _AuctionStampState();
}

class _AuctionStampState extends State<AuctionStamp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = Tween<double>(begin: 2.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (widget.animateOnMount) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.angle,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.85),
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.color.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: GameTypography.display(
              fontSize: widget.fontSize,
              color: widget.color,
              letterSpacing: 3.0,
            ),
          ),
        ),
      ),
    );
  }
}

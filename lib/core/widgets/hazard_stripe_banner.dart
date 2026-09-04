import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';

/// Endüstriyel $45^\circ$ Açılı Sarı-Siyah Tehlike / İkaz Şeridi (Hazard Stripe)
class HazardStripeBanner extends StatelessWidget {
  final double height;
  final double? width;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color primaryColor;
  final Color stripeColor;
  final double stripeWidth;
  final BorderRadius? borderRadius;

  const HazardStripeBanner({
    super.key,
    this.height = 14,
    this.width,
    this.child,
    this.padding = EdgeInsets.zero,
    this.primaryColor = GameColors.hazardYellow,
    this.stripeColor = GameColors.hazardBlack,
    this.stripeWidth = 10,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      child: CustomPaint(
        painter: _HazardStripePainter(
          primaryColor: primaryColor,
          stripeColor: stripeColor,
          stripeWidth: stripeWidth,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _HazardStripePainter extends CustomPainter {
  final Color primaryColor;
  final Color stripeColor;
  final double stripeWidth;

  _HazardStripePainter({
    required this.primaryColor,
    required this.stripeColor,
    required this.stripeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = primaryColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final stripePaint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;

    final totalWidth = size.width + size.height;
    final step = stripeWidth * 2;

    for (double x = -size.height; x < totalWidth; x += step) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();

      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HazardStripePainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.stripeColor != stripeColor ||
        oldDelegate.stripeWidth != stripeWidth;
  }
}

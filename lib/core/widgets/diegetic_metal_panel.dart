import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';

/// Endüstriyel Perçinli Sac & Eğimli (Beveled) Diegetik Metal Panel
class DiegeticMetalPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool showRivets;
  final Color? glowColor;
  final List<BoxShadow>? extraShadows;

  const DiegeticMetalPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.width,
    this.height,
    this.backgroundColor = GameColors.panelDark,
    this.borderColor = GameColors.panelBorder,
    this.borderWidth = 1.5,
    this.borderRadius = 12,
    this.showRivets = false,
    this.glowColor,
    this.extraShadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          // 3D Metalik Eğim Gölgesi (Derinlik)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ...?extraShadows,
        ],
      ),
      child: Stack(
        children: [
          // Üst Bevel Işık Yansıması (Subtle Metal Highlight)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.5,
            child: Container(
              decoration: BoxDecoration(
                color: GameColors.panelBevelHighlight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
              ),
            ),
          ),

          // Alt Bevel Karanlık Gölgesi
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 2.0,
            child: Container(
              decoration: BoxDecoration(
                color: GameColors.panelBevelShadow,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
              ),
            ),
          ),

          // İçerik
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),

          // Köşe Perçinleri (Rivets)
          if (showRivets) ...[
            _buildRivet(top: 6, left: 6),
            _buildRivet(top: 6, right: 6),
            _buildRivet(bottom: 6, left: 6),
            _buildRivet(bottom: 6, right: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildRivet({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4A4E5C),
          border: Border.all(color: const Color(0xFF202229), width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 1),
          ],
        ),
      ),
    );
  }
}

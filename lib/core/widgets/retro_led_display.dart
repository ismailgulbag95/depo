import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';

/// 7-Segment / Retro LED Dijital Sayaç & Para Skorbordu (Diegetik Ekran)
class RetroLedDisplay extends StatelessWidget {
  final String value;
  final String? label;
  final IconData? icon;
  final Color ledColor;
  final double fontSize;
  final bool isBlinking;
  final EdgeInsetsGeometry padding;

  const RetroLedDisplay({
    super.key,
    required this.value,
    this.label,
    this.icon,
    this.ledColor = GameColors.gold,
    this.fontSize = 15,
    this.isBlinking = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0B0E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ledColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          // Dışa taşan neon bloom/glow efekti
          BoxShadow(
            color: ledColor.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.black,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: ledColor),
            const SizedBox(width: 6),
          ],
          if (label != null) ...[
            Text(
              label!.toUpperCase(),
              style: GameTypography.body(
                fontSize: fontSize * 0.75,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: GameTypography.led(fontSize: fontSize, color: ledColor),
          ),
        ],
      ),
    );
  }
}

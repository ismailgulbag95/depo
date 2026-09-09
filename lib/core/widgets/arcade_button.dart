import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';

/// 3D Basılma Derinliği ve Metalik Çerçeveli Dinamik Arcade Oyun Butonu
class ArcadeButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final Color shadowColor;
  final Color textColor;
  final double height;
  final double? width;
  final double fontSize;

  const ArcadeButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    Color? color,
    Color? primaryColor,
    this.shadowColor = const Color(0xFF00893E),
    this.textColor = Colors.black,
    this.height = 48,
    this.width,
    this.fontSize = 14,
  }) : primaryColor = color ?? primaryColor ?? GameColors.profitGreen;

  @override
  State<ArcadeButton> createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<ArcadeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double depth = widget.onPressed == null ? 0 : 5.0;
    final double topMargin = _isPressed ? depth : 0;
    final double bottomShadow = _isPressed ? 0 : depth;

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
            },
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: topMargin),
        decoration: BoxDecoration(
          color: widget.primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (bottomShadow > 0)
              BoxShadow(
                color: widget.shadowColor,
                offset: Offset(0, bottomShadow),
                blurRadius: 0,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.textColor,
                  size: widget.fontSize + 4,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text.toUpperCase(),
                style: GameTypography.display(
                  fontSize: widget.fontSize,
                  color: widget.textColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';

/// 🎯 FTUE Kılavuz Oku & Vurgulama Bileşeni (Spotlight Arrow)
class GuideArrowSpotlight extends StatefulWidget {
  final String text;
  final Widget? actionButton;
  final VoidCallback? onDismiss;
  final Alignment arrowAlignment; // Oku nereye yerleştirelim (topCenter, bottomCenter vb.)
  final double arrowOffset;

  const GuideArrowSpotlight({
    super.key,
    required this.text,
    this.actionButton,
    this.onDismiss,
    this.arrowAlignment = Alignment.topCenter,
    this.arrowOffset = 10.0,
  });

  @override
  State<GuideArrowSpotlight> createState() => _GuideArrowSpotlightState();
}

class _GuideArrowSpotlightState extends State<GuideArrowSpotlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        final offset = _bounceAnimation.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Konuşma / Kılavuz Kartı
            DiegeticMetalPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderColor: GameColors.gold,
              borderWidth: 1.5,
              glowColor: GameColors.gold,
              borderRadius: 12,
              backgroundColor: const Color(0xFF161824).withValues(alpha: 0.95),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tips_and_updates, color: GameColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.text,
                          style: GameTypography.body(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (widget.actionButton != null) ...[
                    const SizedBox(height: 8),
                    widget.actionButton!,
                  ],
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, offset),
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: GameColors.gold,
                size: 36,
                shadows: [
                  Shadow(color: GameColors.gold, blurRadius: 16),
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

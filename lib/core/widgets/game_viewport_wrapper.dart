import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';

/// 🖥️ Masaüstü / Web Duyarlı Görünüm Çerçevesi (GameViewportWrapper)
/// Geniş ekranlı monitörlerde oyunun aşırı gerilmesini önler; 16:9 - 21:9 oranları arasında
/// optimum diegetic endüstriyel çerçeveleme ve merkezleme sağlar.
class GameViewportWrapper extends StatelessWidget {
  final Widget child;

  const GameViewportWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Mobil veya küçük ekranlarda doğrudan tam ekran
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Masaüstü Web ortamında aşırı geniş ekran kontrolü
        final aspectRatio = screenWidth / (screenHeight > 0 ? screenHeight : 1);
        final isUltraWide = aspectRatio > 2.2;
        final isDesktopLarge = kIsWeb && screenWidth > 1400;

        if (isUltraWide || isDesktopLarge) {
          // İdeal 16:9 veya 18:9 oyun genişliği sınırı
          final idealWidth = screenHeight * (16.0 / 9.0);
          final clampedWidth = idealWidth.clamp(900.0, 1500.0);

          return Container(
            color: const Color(0xFF07080C),
            alignment: Alignment.center,
            child: Container(
              width: clampedWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                color: GameColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: GameColors.panelBorder.withValues(alpha: 0.3),
                    blurRadius: 1,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRect(child: child),
            ),
          );
        }

        return child;
      },
    );
  }
}

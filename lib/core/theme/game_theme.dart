import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Depo Avcıları — Endüstriyel & Yüksek Bahisli Arcade Tasarım Sistemi (Game Design System)
class GameColors {
  // Zemin ve Panel Katmanları
  static const Color background = Color(0xFF0D0E11);
  static const Color surface = Color(0xFF15161C);
  static const Color panelDark = Color(0xFF1B1D24);
  static const Color panelBorder = Color(0xFF2E313D);
  static const Color panelBevelHighlight = Color(0x24FFFFFF);
  static const Color panelBevelShadow = Color(0xB3000000);

  // Endüstriyel & Vurgu Renkleri
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color hazardYellow = Color(0xFFFFC107);
  static const Color hazardBlack = Color(0xFF121214);

  // Durum ve Aksiyon Renkleri
  static const Color profitGreen = Color(0xFF00E676);
  static const Color lossRed = Color(0xFFFF3D00);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color alertOrange = Color(0xFFFF6D00);

  // Nadirlik Renkleri
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityRare = Color(0xFF2979FF);
  static const Color rarityEpic = Color(0xFFAA00FF);
  static const Color rarityLegendary = Color(0xFFFFD700);
}

/// Endüstriyel Tipografi Sistemi (Anti-AI Font Hierarchy)
class GameTypography {
  /// Başlıklar, Butonlar ve "SATILDI" damgaları için endüstriyel damga fontu
  static TextStyle display({
    double fontSize = 18,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w900,
    double letterSpacing = 1.0,
  }) {
    return GoogleFonts.russoOne(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  /// 7-Segment / Retro LED Dijital Sayaç ve Para Fontu
  static TextStyle led({
    double fontSize = 16,
    Color color = GameColors.gold,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.2,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Gövde metinleri, eşya açıklamaları ve anonslar için okunabilir teknik font
  static TextStyle body({
    double fontSize = 14,
    Color color = Colors.white70,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.5,
  }) {
    return GoogleFonts.rajdhani(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
}

/// Tema Yapılandırması
class GameTheme {
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GameColors.background,
      primaryColor: GameColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: GameColors.gold,
        secondary: GameColors.neonCyan,
        surface: GameColors.surface,
        error: GameColors.lossRed,
      ),
      textTheme: TextTheme(
        displayLarge: GameTypography.display(fontSize: 24),
        displayMedium: GameTypography.display(fontSize: 20),
        titleLarge: GameTypography.display(fontSize: 16),
        bodyLarge: GameTypography.body(fontSize: 15),
        bodyMedium: GameTypography.body(fontSize: 13),
        labelLarge: GameTypography.led(fontSize: 14),
      ),
      useMaterial3: true,
    );
  }
}


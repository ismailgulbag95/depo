import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Depo Avcıları — Modern Minimalist / Elit Pazar Yeri Tasarım Sistemi (ADR-031)
class GameColors {
  // Modern Minimalist Zemin ve Panel Katmanları (Clean Dark Mode)
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF161922);
  static const Color panelDark = Color(0xFF1E222D);
  static const Color panelBorder = Color(0xFF2A2E39);
  static const Color panelBorderSubtle = Color(0xFF212631);
  static const Color panelBevelHighlight = Color(0x18FFFFFF);
  static const Color panelBevelShadow = Color(0x66000000);

  // Elit Pazar Yeri & Vurgu Renkleri
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color hazardYellow = Color(0xFFF59E0B);
  static const Color hazardBlack = Color(0xFF111827);

  // Modern Durum ve Aksiyon Renkleri (Fintech / Pazar Yeri)
  static const Color profitGreen = Color(0xFF10B981);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color lossRed = Color(0xFFEF4444);
  static const Color crimsonRed = Color(0xFFEF4444);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color alertOrange = Color(0xFFF97316);
  static const Color titaniumWhite = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF94A3B8);

  // Nadirlik Renkleri
  static const Color rarityCommon = Color(0xFF94A3B8);
  static const Color rarityRare = Color(0xFF3B82F6);
  static const Color rarityEpic = Color(0xFFA855F7);
  static const Color rarityLegendary = Color(0xFFF59E0B);
}

/// Modern Minimalist Tipografi Sistemi
class GameTypography {
  /// Evrensel font glifleri ve çoklu dil (TR, RU, ES) desteği için fallback listesi
  static const List<String> fontFallback = [
    'Noto Color Emoji',
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Inter',
    'Noto Sans',
    'Roboto',
    'Segoe UI',
    'Arial',
    'sans-serif',
  ];

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
    ).copyWith(
      fontFamilyFallback: fontFallback,
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
    ).copyWith(
      fontFamilyFallback: fontFallback,
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
    ).copyWith(
      fontFamilyFallback: fontFallback,
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


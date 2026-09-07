import 'package:flutter/material.dart';

/// 🗺️ Harita Bölgesi Veri Modeli (City Map Zone Data)
class ZoneData {
  /// Benzersiz bölge kimliği (örn: 'wholesaler', 'home', 'pawn')
  final String id;

  /// Bölge adı (örn: 'Toptancı & Hurda')
  final String name;

  /// Bölge alt başlığı / kısa açıklama
  final String subtitle;

  /// İkon (IconData veya özel görsel ikon)
  final IconData icon;

  /// Özel görsel ikon dosya yolu (varsa)
  final String? iconPath;

  /// Normalize edilmiş oransal koordinat (-1.0 ile 1.0 arası)
  final Alignment alignment;

  /// Dinamik rozet metni (Örn: "Mezat Açık", "Seferde", "Kiralık")
  final String? badgeText;

  /// Vurgu / Tema Rengi
  final Color accentColor;

  /// Önemli veya aktif etkinlik bölgesi mi?
  final bool isImportant;

  /// FTUE veya görev vurgusu aktif mi?
  final bool isHighlighted;

  /// Dokunulduğunda çalışacak geri çağırım
  final VoidCallback onTap;

  const ZoneData({
    required this.id,
    required this.name,
    this.subtitle = '',
    required this.icon,
    this.iconPath,
    required this.alignment,
    this.badgeText,
    this.accentColor = const Color(0xFF00E5FF),
    this.isImportant = false,
    this.isHighlighted = false,
    required this.onTap,
  });

  ZoneData copyWith({
    String? id,
    String? name,
    String? subtitle,
    IconData? icon,
    String? iconPath,
    Alignment? alignment,
    String? badgeText,
    Color? accentColor,
    bool? isImportant,
    bool? isHighlighted,
    VoidCallback? onTap,
  }) {
    return ZoneData(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      iconPath: iconPath ?? this.iconPath,
      alignment: alignment ?? this.alignment,
      badgeText: badgeText ?? this.badgeText,
      accentColor: accentColor ?? this.accentColor,
      isImportant: isImportant ?? this.isImportant,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      onTap: onTap ?? this.onTap,
    );
  }
}

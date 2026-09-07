import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 💡 Günlük Piyasa Fısıltısı & Masa Lambası Modeli
class MarketWhisper {
  final String title;
  final String message;
  final String targetCategory;
  final double priceBonus; // örn: 0.20 (+%20)
  final bool isLampOn;

  const MarketWhisper({
    required this.title,
    required this.message,
    required this.targetCategory,
    required this.priceBonus,
    this.isLampOn = false,
  });

  MarketWhisper copyWith({
    String? title,
    String? message,
    String? targetCategory,
    double? priceBonus,
    bool? isLampOn,
  }) {
    return MarketWhisper(
      title: title ?? this.title,
      message: message ?? this.message,
      targetCategory: targetCategory ?? this.targetCategory,
      priceBonus: priceBonus ?? this.priceBonus,
      isLampOn: isLampOn ?? this.isLampOn,
    );
  }
}

class MarketWhisperNotifier extends StateNotifier<MarketWhisper> {
  static final List<MarketWhisper> _dailyPool = [
    const MarketWhisper(
      title: '🌟 Antika & Sanat Fısıltısı',
      message: 'Bugün şehirdeki açık artırmalara zengin koleksiyoncular akın etti! Sanat ve Antika satışlarında +%20 Ekstra Fiyat Bonusu aktif!',
      targetCategory: 'sanat_antikalar',
      priceBonus: 0.20,
    ),
    const MarketWhisper(
      title: '⚡ Elektronik & Alet Trendi',
      message: 'Sanayi bölgesindeki atölyeler acil parça ve elektronik arıyor! Elektronik satışlarında +%25 Hızlı Satış Bonusu!',
      targetCategory: 'elektronik_aletler',
      priceBonus: 0.25,
    ),
    const MarketWhisper(
      title: '⚔️ Kadim Savaş Ekipmanları Talebi',
      message: 'Zindan seferleri için paralı asker loncaları silah stokluyor! Savaş ekipmanı satışlarında +%20 Fiyat Primi!',
      targetCategory: 'buyulu_silahlar',
      priceBonus: 0.20,
    ),
    const MarketWhisper(
      title: '💎 Değerli Taş & Maden Patlaması',
      message: 'Kuyumcular çarşısında nadir taş ve mücevher kıtlığı var! Maden ve taş satışlarında +%30 Değer Artışı!',
      targetCategory: 'maden_ve_taslar',
      priceBonus: 0.30,
    ),
  ];

  MarketWhisperNotifier()
      : super(
          _dailyPool[Random().nextInt(_dailyPool.length)],
        );

  /// Masa lambasını aç/kapa ve piyasa fısıltısını aydınlat
  void toggleLamp() {
    state = state.copyWith(isLampOn: !state.isLampOn);
  }
}

final marketWhisperProvider = StateNotifierProvider<MarketWhisperNotifier, MarketWhisper>((ref) {
  return MarketWhisperNotifier();
});

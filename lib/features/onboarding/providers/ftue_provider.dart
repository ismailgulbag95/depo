import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 🎮 İlk Kullanıcı Deneyimi (FTUE - First Time User Experience) Adımları
enum FTUEStep {
  storyIntro,             // 1. Hikaye Girişi (Story Prologue)
  scriptedAuction,        // 2. $500 Bütçeli Senaryolaştırılmış Müzayede (150 -> 450)
  tetrisTutorial,         // 3. Tetris İstif Kılavuzu & Butonlar + Garantili Ekipman
  interactiveMapIntro,    // 4. Stilize Şehir Haritası Keşfi & Eve Yönlendirme
  homeInventoryTransfer,  // 5. Eve Giriş & Bagajı Tek Tuşla Depoya Boşaltma
  marketplaceFirstSale,   // 6. Çalışma Odası İnternet Pazarı Fiyatlandırma & İlk Satış (Büyülü Eşya Korumalı)
  gearAndNpcIntro,        // 7. Büyülü Savaş Eşyası Farkındalığı & Dinlenme Odası Tanıtımı
  tavernHiring,           // 8. Han (Tavern) Ziyareti, Karakter Replikleri & NPC Kiralama (Kazanılan Parayla!)
  restRoomEquip,          // 9. Dinlenme Odasında Askere Büyülü Ekipman Giydirme
  completed,              // 10. Rehber Tamamlandı - Serbest Oyun
}

class FTUENotifier extends StateNotifier<FTUEStep> {
  static const String _prefKey = 'ftue_current_step_index';

  FTUENotifier() : super(FTUEStep.storyIntro) {
    _loadSavedStep();
  }

  void _loadSavedStep() {
    try {
      if (Hive.isBoxOpen('settingsBox')) {
        final box = Hive.box('settingsBox');
        final index = box.get(_prefKey) as int?;
        if (index != null && index >= 0 && index < FTUEStep.values.length) {
          state = FTUEStep.values[index];
        }
      }
    } catch (_) {}
  }

  Future<void> setStep(FTUEStep step) async {
    state = step;
    try {
      if (Hive.isBoxOpen('settingsBox')) {
        final box = Hive.box('settingsBox');
        await box.put(_prefKey, step.index);
      }
    } catch (_) {}
  }

  Future<void> nextStep() async {
    if (state.index < FTUEStep.values.length - 1) {
      final next = FTUEStep.values[state.index + 1];
      await setStep(next);
    }
  }

  /// Rehberi sıfırlamak için (Debug / Test)
  Future<void> resetFTUE() async {
    await setStep(FTUEStep.storyIntro);
  }

  /// Rehber tamamlandı mı?
  bool get isCompleted => state == FTUEStep.completed;
}

final ftueProvider = StateNotifierProvider<FTUENotifier, FTUEStep>((ref) {
  return FTUENotifier();
});

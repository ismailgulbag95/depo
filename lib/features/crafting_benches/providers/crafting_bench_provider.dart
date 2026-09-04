import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// Atölye Tezgâh Türü
enum BenchType {
  ultrasonicWash, // Ultrasonik Temizleme & Pas Kazıma (Hurda -> Kötü -> İyi)
  precisionRepair, // Hassas Onarım & Örs Çekiçleme (İyi -> Mükemmel)
}

/// Atölye Durumu
class CraftingBenchState {
  final int masteryXp; // Restorasyon ustalığı (0 - 1000)
  final int masteryLevel; // Ustalık seviyesi (Her 100 XP = 1 Seviye)
  final ItemModel? activeItem; // Tezgâhtaki aktif eşya
  final double cleaningProgress; // Mini-simülasyon temizleme ilerlemesi (0.0 - 1.0)
  final bool isRestored; // Temizleme/onarım tamamlandı mı?

  const CraftingBenchState({
    required this.masteryXp,
    required this.masteryLevel,
    this.activeItem,
    this.cleaningProgress = 0.0,
    this.isRestored = false,
  });

  /// Seviye 3 ve üzerinde 'Otomatik Seri Restorasyon' kilidi açılır
  bool get hasAutoPolishUnlocked => masteryLevel >= 3;

  CraftingBenchState copyWith({
    int? masteryXp,
    int? masteryLevel,
    ItemModel? activeItem,
    bool clearActiveItem = false,
    double? cleaningProgress,
    bool? isRestored,
  }) {
    return CraftingBenchState(
      masteryXp: masteryXp ?? this.masteryXp,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      activeItem: clearActiveItem ? null : (activeItem ?? this.activeItem),
      cleaningProgress: cleaningProgress ?? this.cleaningProgress,
      isRestored: isRestored ?? this.isRestored,
    );
  }
}

/// Atölye ve Restorasyon Yöneticisi
class CraftingBenchNotifier extends StateNotifier<CraftingBenchState> {
  final Ref ref;

  CraftingBenchNotifier(this.ref)
      : super(const CraftingBenchState(masteryXp: 0, masteryLevel: 1));

  /// Tezgâha yeni eşya koy
  void setBenchItem(ItemModel item) {
    state = state.copyWith(
      activeItem: item,
      cleaningProgress: 0.0,
      isRestored: false,
    );
  }

  /// Mini-simülasyon: Oyuncu parmağıyla ovaladıkça ilerleme artar
  void addRubProgress(double amount) {
    if (state.activeItem == null || state.isRestored) return;

    final newProgress = (state.cleaningProgress + amount).clamp(0.0, 1.0);
    final completed = newProgress >= 1.0;

    state = state.copyWith(
      cleaningProgress: newProgress,
      isRestored: completed,
    );

    if (completed) {
      _applyRestorationReward();
    }
  }

  /// Seviye 3+ Ustalık: Tek tıkla anında otomatik restorasyon
  void performAutoRestore() {
    if (state.activeItem == null || state.isRestored || !state.hasAutoPolishUnlocked) return;

    state = state.copyWith(
      cleaningProgress: 1.0,
      isRestored: true,
    );

    _applyRestorationReward();
  }

  /// Restorasyon bittiğinde XP ve oyuncu profili ödülleri uygula
  void _applyRestorationReward() {
    final newXp = state.masteryXp + 35;
    final newLevel = 1 + (newXp ~/ 100);

    state = state.copyWith(
      masteryXp: newXp,
      masteryLevel: newLevel,
    );

    // Oyuncunun genel itibar puanına da katkı sağla
    ref.read(playerProfileProvider.notifier).addReputation(50);
  }

  /// Eşyayı teslim alıp tezgâhı boşalt
  ItemModel? claimRestoredItem() {
    if (!state.isRestored || state.activeItem == null) return null;

    final item = state.activeItem!;
    state = state.copyWith(
      clearActiveItem: true,
      cleaningProgress: 0.0,
      isRestored: false,
    );
    return item;
  }
}

/// Global Crafting Bench Provider'ı
final craftingBenchProvider =
    StateNotifierProvider<CraftingBenchNotifier, CraftingBenchState>((ref) {
  return CraftingBenchNotifier(ref);
});

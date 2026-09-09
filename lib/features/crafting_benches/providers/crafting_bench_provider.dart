import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/crafting_recipes.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/crafting_recipe_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_set_model.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// Atölye Tezgâh Türü
enum BenchType {
  ultrasonicWash, // Ultrasonik Temizleme & Pas Kazıma (Hurda -> Kötü -> İyi)
  precisionRepair, // Hassas Onarım & Örs Çekiçleme (İyi -> Mükemmel)
}

/// Atölye Aktif Sekmesi
enum BenchTab {
  restoration, // Restorasyon & Temizleme
  crafting, // Parça Birleştirme & İleri Montaj
  salvage, // Demontaj & Hurdalama
  sets, // Koleksiyon & Sinerji Setleri
}

/// Atölye Durumu
class CraftingBenchState {
  final int masteryXp; // Restorasyon ve zanaat ustalığı
  final int masteryLevel; // Ustalık seviyesi (Her 100 XP = 1 Seviye)
  final BenchTab activeTab; // Aktif sekme
  final ItemModel? activeItem; // Tezgâhtaki aktif eşya (Restorasyon veya Salvage için)
  final double cleaningProgress; // Mini-simülasyon temizleme ilerlemesi (0.0 - 1.0)
  final bool isRestored; // Temizleme/onarım tamamlandı mı?
  final List<String> completedSetIds; // Tamamlanan koleksiyon setleri

  const CraftingBenchState({
    required this.masteryXp,
    required this.masteryLevel,
    this.activeTab = BenchTab.restoration,
    this.activeItem,
    this.cleaningProgress = 0.0,
    this.isRestored = false,
    this.completedSetIds = const [],
  });

  /// Seviye 3 ve üzerinde 'Otomatik Seri Restorasyon' kilidi açılır
  bool get hasAutoPolishUnlocked => masteryLevel >= 3;

  CraftingBenchState copyWith({
    int? masteryXp,
    int? masteryLevel,
    BenchTab? activeTab,
    ItemModel? activeItem,
    bool clearActiveItem = false,
    double? cleaningProgress,
    bool? isRestored,
    List<String>? completedSetIds,
  }) {
    return CraftingBenchState(
      masteryXp: masteryXp ?? this.masteryXp,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      activeTab: activeTab ?? this.activeTab,
      activeItem: clearActiveItem ? null : (activeItem ?? this.activeItem),
      cleaningProgress: cleaningProgress ?? this.cleaningProgress,
      isRestored: isRestored ?? this.isRestored,
      completedSetIds: completedSetIds ?? this.completedSetIds,
    );
  }
}

/// Atölye, Üretim ve Koleksiyon Yöneticisi
class CraftingBenchNotifier extends StateNotifier<CraftingBenchState> {
  final Ref ref;

  CraftingBenchNotifier(this.ref)
      : super(const CraftingBenchState(masteryXp: 0, masteryLevel: 1));

  /// Sekme değiştir
  void setTab(BenchTab tab) {
    state = state.copyWith(activeTab: tab);
  }

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

  /// Restorasyon bittiğinde XP, malzeme maliyeti ve kalıcı DB kaydı uygula
  void _applyRestorationReward() async {
    final newXp = state.masteryXp + 35;
    final newLevel = 1 + (newXp ~/ 100);

    if (state.activeItem != null) {
      final item = state.activeItem!;
      final materialCost = (item.baseValue * 0.20).round().clamp(15, 350);
      ref.read(playerProfileProvider.notifier).deductCash(materialCost);

      item.condition = ItemCondition.pristine;
      item.dirtPercentage = 0.0;
      await DatabaseService.instance.saveItem(item);
    }

    state = state.copyWith(
      masteryXp: newXp,
      masteryLevel: newLevel,
    );

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

  /// [CRAFTING / MONTAJ]: Verilen reçeteye göre yeni eşyalar üretir
  Future<bool> craftRecipe(CraftingRecipeModel recipe, List<ItemModel> inventoryItems) async {
    if (state.masteryLevel < recipe.requiredMasteryLevel) return false;

    // Oyuncunun yeterli parası var mı?
    final profile = await DatabaseService.instance.getPlayerProfile();
    if (profile == null || profile.cash < recipe.cashCost) return false;

    // Girdi malzemeleri mevcut mu?
    for (final req in recipe.inputs) {
      final matching = inventoryItems.where((i) => i.code == req.itemCode).length;
      if (matching < req.count) return false;
    }

    // Parayı düş
    ref.read(playerProfileProvider.notifier).deductCash(recipe.cashCost);

    // XP ve Seviye artır
    final newXp = state.masteryXp + recipe.rewardXp;
    final newLevel = 1 + (newXp ~/ 100);

    // Çıktı eşyalarını veritabanından bulup hazırla
    for (final out in recipe.outputs) {
      final template = await DatabaseService.instance.getItemByCode(out.itemCode);
      if (template != null) {
        // Envantere veya dükkan deposuna eklenebilir
      }
    }

    state = state.copyWith(
      masteryXp: newXp,
      masteryLevel: newLevel,
    );

    ref.read(playerProfileProvider.notifier).addReputation(recipe.rewardXp ~/ 2);
    return true;
  }

  /// [SALVAGE / DEMONTAJ]: Eşyayı parçalayarak alt malzemelere dönüştürür
  Future<List<ItemModel>> salvageItem(ItemModel item) async {
    // Bu eşyayı tüketen bir salvage reçetesi var mı?
    final salvageRecipes = GameCraftingRecipes.getByType(RecipeType.salvage);
    final matchedRecipe = salvageRecipes.firstWhere(
      (r) => r.inputs.any((i) => i.itemCode == item.code),
      orElse: () => salvageRecipes.first,
    );

    final resultItems = <ItemModel>[];
    for (final out in matchedRecipe.outputs) {
      final template = await DatabaseService.instance.getItemByCode(out.itemCode);
      if (template != null) {
        resultItems.add(template);
      }
    }

    final newXp = state.masteryXp + matchedRecipe.rewardXp;
    final newLevel = 1 + (newXp ~/ 100);

    state = state.copyWith(
      masteryXp: newXp,
      masteryLevel: newLevel,
      clearActiveItem: true,
    );

    return resultItems;
  }

  /// [SET ÖDÜLÜ]: Set tamamlandığında büyük ödülü al
  void claimSetReward(ItemSetModel itemSet) {
    if (state.completedSetIds.contains(itemSet.id)) return;

    ref.read(playerProfileProvider.notifier).addCash(itemSet.cashReward);
    ref.read(playerProfileProvider.notifier).addReputation(itemSet.reputationReward);

    state = state.copyWith(
      completedSetIds: [...state.completedSetIds, itemSet.id],
      masteryXp: state.masteryXp + 150,
      masteryLevel: 1 + ((state.masteryXp + 150) ~/ 100),
    );
  }
}

/// Global Crafting Bench Provider'ı
final craftingBenchProvider =
    StateNotifierProvider<CraftingBenchNotifier, CraftingBenchState>((ref) {
  return CraftingBenchNotifier(ref);
});

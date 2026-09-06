import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/player_profile_model.dart';

/// Oyuncu Profil Durumu
class PlayerProfileState {
  final int id;
  final int cash;
  final int reputation;
  final int activeVehicleId;
  final int maxStorageSlots;
  final List<int> shopStorageItemIds;
  final List<int> homeStorageItemIds;
  final List<int> shopShowcaseItemIds;
  final int ownedHomeTier;
  final List<int> ownedVehicleIds;
  final List<String> unlockedDistricts;

  const PlayerProfileState({
    required this.id,
    required this.cash,
    required this.reputation,
    required this.activeVehicleId,
    required this.maxStorageSlots,
    required this.shopStorageItemIds,
    this.homeStorageItemIds = const [],
    this.shopShowcaseItemIds = const [],
    this.ownedHomeTier = 1,
    this.ownedVehicleIds = const [1],
    this.unlockedDistricts = const ['mechanic'],
  });

  /// Ev seviyesine göre maksimum NPC kapasitesi
  int get maxMercenaryCapacity {
    switch (ownedHomeTier) {
      case 1:
        return 2; // Garajlı Daire
      case 2:
        return 4; // Müstakil Ev
      case 3:
        return 6; // Çiftlik Evi
      case 4:
        return 10; // Malikane
      default:
        return 2;
    }
  }

  /// Ev seviyesi unvanı
  String get homeTierTitle {
    switch (ownedHomeTier) {
      case 1:
        return 'Garajlı Şehir Dairesi (Tier 1)';
      case 2:
        return 'Müstakil Banliyö Evi (Tier 2)';
      case 3:
        return 'Geniş Çiftlik Evi & Atölye (Tier 3)';
      case 4:
        return 'Lüks Malikane & Karargah (Tier 4)';
      default:
        return 'Garajlı Daire';
    }
  }

  PlayerProfileState copyWith({
    int? cash,
    int? reputation,
    int? activeVehicleId,
    int? maxStorageSlots,
    List<int>? shopStorageItemIds,
    List<int>? homeStorageItemIds,
    List<int>? shopShowcaseItemIds,
    int? ownedHomeTier,
    List<int>? ownedVehicleIds,
    List<String>? unlockedDistricts,
  }) {
    return PlayerProfileState(
      id: id,
      cash: cash ?? this.cash,
      reputation: reputation ?? this.reputation,
      activeVehicleId: activeVehicleId ?? this.activeVehicleId,
      maxStorageSlots: maxStorageSlots ?? this.maxStorageSlots,
      shopStorageItemIds: shopStorageItemIds ?? this.shopStorageItemIds,
      homeStorageItemIds: homeStorageItemIds ?? this.homeStorageItemIds,
      shopShowcaseItemIds: shopShowcaseItemIds ?? this.shopShowcaseItemIds,
      ownedHomeTier: ownedHomeTier ?? this.ownedHomeTier,
      ownedVehicleIds: ownedVehicleIds ?? this.ownedVehicleIds,
      unlockedDistricts: unlockedDistricts ?? this.unlockedDistricts,
    );
  }

  factory PlayerProfileState.initial() {
    return PlayerProfileState(
      id: 1,
      cash: GameConstants.initialPlayerCash,
      reputation: 0,
      activeVehicleId: 1,
      maxStorageSlots: GameConstants.initialShopStorageSlots,
      shopStorageItemIds: const [],
      homeStorageItemIds: const [],
      shopShowcaseItemIds: const [],
      ownedHomeTier: 1,
      ownedVehicleIds: const [1],
      unlockedDistricts: const ['mechanic'],
    );
  }
}

/// Oyuncu Profil ve Cüzdan Durumu Yöneticisi
class PlayerProfileNotifier extends StateNotifier<PlayerProfileState> {
  PlayerProfileNotifier() : super(PlayerProfileState.initial()) {
    loadProfile();
  }

  /// Kayıtlı profili yükler
  Future<void> loadProfile() async {
    try {
      final profile = await DatabaseService.instance.getPlayerProfile();
      if (profile != null) {
        state = PlayerProfileState(
          id: profile.id,
          cash: profile.cash,
          reputation: profile.reputation,
          activeVehicleId: profile.activeVehicleId,
          maxStorageSlots: profile.maxStorageSlots,
          shopStorageItemIds: List<int>.from(profile.shopStorageItemIds),
          homeStorageItemIds: List<int>.from(profile.homeStorageItemIds),
          shopShowcaseItemIds: List<int>.from(profile.shopShowcaseItemIds),
          ownedHomeTier: profile.ownedHomeTier,
          ownedVehicleIds: List<int>.from(profile.ownedVehicleIds),
          unlockedDistricts: List<String>.from(profile.unlockedDistricts),
        );
      }
    } catch (_) {}
  }

  /// Nakit para ekler ve kaydeder
  Future<void> addCash(int amount) async {
    final newCash = state.cash + amount;
    state = state.copyWith(cash: newCash);
    await _persist();
  }

  /// Nakit para düşer (Bakiye yetersizse false döner)
  Future<bool> deductCash(int amount) async {
    if (state.cash < amount) return false;
    final newCash = state.cash - amount;
    state = state.copyWith(cash: newCash);
    await _persist();
    return true;
  }

  /// İtibar / Deneyim puanı ekler
  Future<void> addReputation(int points) async {
    final newRep = state.reputation + points;
    state = state.copyWith(reputation: newRep);
    await _persist();
  }

  /// Sınırsız Ev Deposu'na eşya ekler
  Future<void> addToHomeStorage(int itemId) async {
    final updatedList = List<int>.from(state.homeStorageItemIds)..add(itemId);
    state = state.copyWith(homeStorageItemIds: updatedList);
    await _persist();
  }

  /// Sınırsız Ev Deposu'ndan eşya çıkarır
  Future<bool> removeFromHomeStorage(int itemId) async {
    if (!state.homeStorageItemIds.contains(itemId)) return false;
    final updatedList = List<int>.from(state.homeStorageItemIds)..remove(itemId);
    state = state.copyWith(homeStorageItemIds: updatedList);
    await _persist();
    return true;
  }

  /// Toplu olarak araçtan Ev Deposu'na aktarma
  Future<void> transferAllToHomeStorage(List<int> itemIds) async {
    final updatedList = List<int>.from(state.homeStorageItemIds)..addAll(itemIds);
    state = state.copyWith(homeStorageItemIds: updatedList);
    await _persist();
  }

  /// Dükkan deposuna eşya ekler
  Future<bool> addItemToShopStorage(int itemId) async {
    if (state.shopStorageItemIds.length >= state.maxStorageSlots) {
      return false; // Depo dolu
    }
    final updatedList = List<int>.from(state.shopStorageItemIds)..add(itemId);
    state = state.copyWith(shopStorageItemIds: updatedList);
    await _persist();
    return true;
  }

  /// Dükkan deposundan eşya çıkarır
  Future<bool> removeItemFromShopStorage(int itemId) async {
    if (!state.shopStorageItemIds.contains(itemId)) return false;
    final updatedList = List<int>.from(state.shopStorageItemIds)..remove(itemId);
    state = state.copyWith(shopStorageItemIds: updatedList);
    await _persist();
    return true;
  }

  /// Toplu olarak araçtan Dükkan Deposu'na aktarma
  Future<int> transferAllToShopStorage(List<int> itemIds) async {
    int addedCount = 0;
    final currentList = List<int>.from(state.shopStorageItemIds);
    for (final id in itemIds) {
      if (currentList.length < state.maxStorageSlots) {
        currentList.add(id);
        addedCount++;
      }
    }
    state = state.copyWith(shopStorageItemIds: currentList);
    await _persist();
    return addedCount;
  }

  /// Dükkan vitrinine eşya koyma
  Future<bool> addToShowcase(int itemId) async {
    final currentShowcase = List<int>.from(state.shopShowcaseItemIds);
    if (currentShowcase.length >= 10) return false;
    currentShowcase.add(itemId);
    state = state.copyWith(shopShowcaseItemIds: currentShowcase);
    await _persist();
    return true;
  }

  /// Dükkan vitrininden eşya çıkarma
  Future<void> removeFromShowcase(int itemId) async {
    final currentShowcase = List<int>.from(state.shopShowcaseItemIds)..remove(itemId);
    state = state.copyWith(shopShowcaseItemIds: currentShowcase);
    await _persist();
  }

  /// Yeni araç satın alma
  Future<bool> buyVehicle(int vehicleId, int cost) async {
    if (state.ownedVehicleIds.contains(vehicleId)) return true;
    if (state.cash < cost) return false;

    final newCash = state.cash - cost;
    final newOwned = List<int>.from(state.ownedVehicleIds)..add(vehicleId);
    state = state.copyWith(
      cash: newCash,
      ownedVehicleIds: newOwned,
      activeVehicleId: vehicleId,
    );
    await _persist();
    return true;
  }

  /// Aktif aracı değiştirme
  Future<void> switchActiveVehicle(int vehicleId) async {
    if (state.ownedVehicleIds.contains(vehicleId)) {
      state = state.copyWith(activeVehicleId: vehicleId);
      await _persist();
    }
  }

  /// Ev seviyesini yükseltme (Tier Upgrade)
  Future<bool> upgradeHomeTier(int targetTier, int cost) async {
    if (state.ownedHomeTier >= targetTier) return true;
    if (state.cash < cost) return false;

    final newCash = state.cash - cost;
    state = state.copyWith(
      cash: newCash,
      ownedHomeTier: targetTier,
    );
    await _persist();
    return true;
  }

  /// Yeni bir depo bölgesi / ihale lisansı açar
  Future<void> unlockDistrict(String districtCode) async {
    if (!state.unlockedDistricts.contains(districtCode)) {
      final updated = List<String>.from(state.unlockedDistricts)..add(districtCode);
      state = state.copyWith(unlockedDistricts: updated);
      await _persist();
    }
  }

  /// Değişiklikleri kalıcı olarak yazar
  Future<void> _persist() async {
    try {
      final profile = PlayerProfileModel(
        id: state.id,
        cash: state.cash,
        reputation: state.reputation,
        activeVehicleId: state.activeVehicleId,
        maxStorageSlots: state.maxStorageSlots,
        shopStorageItemIds: state.shopStorageItemIds,
        homeStorageItemIds: state.homeStorageItemIds,
        shopShowcaseItemIds: state.shopShowcaseItemIds,
        ownedHomeTier: state.ownedHomeTier,
        ownedVehicleIds: state.ownedVehicleIds,
        unlockedDistricts: state.unlockedDistricts,
      );
      await DatabaseService.instance.savePlayerProfile(profile);
    } catch (_) {}
  }
}

/// Global PlayerProfile Provider'ı
final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfileState>((ref) {
  return PlayerProfileNotifier();
});

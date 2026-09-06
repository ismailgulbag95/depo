import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';

/// Oyuncu Profil Modeli (Pure Dart & Hive)
class PlayerProfileModel {
  int id;
  int cash;
  int reputation;
  int activeVehicleId;
  int maxStorageSlots;
  List<int> shopStorageItemIds;
  List<int> homeStorageItemIds; // Sınırsız Ev Deposu
  List<int> shopShowcaseItemIds; // Dükkan Vitrinindeki Eşyalar
  int ownedHomeTier; // 1: Garajlı Daire (Max 2 NPC), 2: Müstakil (Max 4), 3: Çiftlik (Max 6), 4: Malikane (Max 10)
  List<int> ownedVehicleIds; // 1: Pikap, 2: Van, 3: Kamyonet, 4: Tır
  List<String> unlockedDistricts; // Açık depo bölgeleri: 'mechanic', 'home', 'art', 'military', 'luxury'

  PlayerProfileModel({
    required this.id,
    this.cash = GameConstants.initialPlayerCash,
    this.reputation = 0,
    this.activeVehicleId = 1,
    this.maxStorageSlots = GameConstants.initialShopStorageSlots,
    this.shopStorageItemIds = const [],
    this.homeStorageItemIds = const [],
    this.shopShowcaseItemIds = const [],
    this.ownedHomeTier = 1,
    this.ownedVehicleIds = const [1],
    this.unlockedDistricts = const ['mechanic'],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cash': cash,
      'reputation': reputation,
      'activeVehicleId': activeVehicleId,
      'maxStorageSlots': maxStorageSlots,
      'shopStorageItemIds': shopStorageItemIds,
      'homeStorageItemIds': homeStorageItemIds,
      'shopShowcaseItemIds': shopShowcaseItemIds,
      'ownedHomeTier': ownedHomeTier,
      'ownedVehicleIds': ownedVehicleIds,
      'unlockedDistricts': unlockedDistricts,
    };
  }

  factory PlayerProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return PlayerProfileModel(
      id: map['id'] as int? ?? 1,
      cash: (map['cash'] as num?)?.toInt() ?? GameConstants.initialPlayerCash,
      reputation: (map['reputation'] as num?)?.toInt() ?? 0,
      activeVehicleId: (map['activeVehicleId'] as num?)?.toInt() ?? 1,
      maxStorageSlots: (map['maxStorageSlots'] as num?)?.toInt() ?? GameConstants.initialShopStorageSlots,
      shopStorageItemIds: (map['shopStorageItemIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      homeStorageItemIds: (map['homeStorageItemIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      shopShowcaseItemIds: (map['shopShowcaseItemIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      ownedHomeTier: (map['ownedHomeTier'] as num?)?.toInt() ?? 1,
      ownedVehicleIds: (map['ownedVehicleIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1],
      unlockedDistricts: (map['unlockedDistricts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['mechanic'],
    );
  }
}

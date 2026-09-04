import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';

/// Oyuncu Profil Modeli (Pure Dart & Hive)
class PlayerProfileModel {
  int id;
  int cash;
  int reputation;
  int activeVehicleId;
  int maxStorageSlots;
  List<int> shopStorageItemIds;

  PlayerProfileModel({
    required this.id,
    this.cash = GameConstants.initialPlayerCash,
    this.reputation = 0,
    this.activeVehicleId = 1,
    this.maxStorageSlots = GameConstants.initialShopStorageSlots,
    this.shopStorageItemIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cash': cash,
      'reputation': reputation,
      'activeVehicleId': activeVehicleId,
      'maxStorageSlots': maxStorageSlots,
      'shopStorageItemIds': shopStorageItemIds,
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
    );
  }
}

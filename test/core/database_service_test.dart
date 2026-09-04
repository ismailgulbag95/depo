import 'package:flutter_test/flutter_test.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/player_profile_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/storage_unit_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/vehicle_model.dart';

void main() {
  group('Evrensel Veri Modelleri (Pure Dart & Hive) Testleri', () {
    test('ItemModel Map serileştirme ve 4 dilli ad doğrulaması', () {
      final item = ItemModel(
        id: 1,
        code: 'retro_buzdolabi',
        nameTr: 'Retro Buzdolabı',
        nameEn: 'Retro Refrigerator',
        nameRu: 'Ретро холодильник',
        nameEs: 'Refrigerador retro',
        category: 'furniture',
        baseValue: 450,
        width: 2,
        height: 4,
        bitmask: [3, 3, 3, 3],
        weight: 65.0,
        spritePath: 'assets/items/beyaz_esya/02_retro_buzdolabi.webp',
        condition: ItemCondition.poor,
        dirtPercentage: 45.0,
      );

      // Dil testleri
      expect(item.localizedName('tr'), equals('Retro Buzdolabı'));
      expect(item.localizedName('en'), equals('Retro Refrigerator'));
      expect(item.localizedName('ru'), equals('Ретро холодильник'));
      expect(item.localizedName('es'), equals('Refrigerador retro'));

      // Kondisyon hesaplama: poor (0.5 çarpan) -> 450 * 0.5 = 225
      expect(item.currentValue, equals(225));

      // Map serileştirme / deserializasyon
      final map = item.toMap();
      final fromMapItem = ItemModel.fromMap(map);

      expect(fromMapItem.id, equals(item.id));
      expect(fromMapItem.code, equals(item.code));
      expect(fromMapItem.nameTr, equals(item.nameTr));
      expect(fromMapItem.baseValue, equals(item.baseValue));
      expect(fromMapItem.bitmask, equals(item.bitmask));
      expect(fromMapItem.condition, equals(ItemCondition.poor));
    });

    test('VehicleModel ve PlacerRecord yerleşim kaydı doğrulaması', () {
      final vehicle = VehicleModel(
        id: 1,
        name: 'Pikap',
        gridWidth: 8,
        gridHeight: 12,
        maxWeightKg: 500.0,
        placedItems: [
          PlacerRecord(itemId: 10, itemCode: 'matkap', gridX: 2, gridY: 3, rotation: 90),
        ],
      );

      final map = vehicle.toMap();
      final fromMapVehicle = VehicleModel.fromMap(map);

      expect(fromMapVehicle.id, equals(1));
      expect(fromMapVehicle.placedItems.length, equals(1));
      expect(fromMapVehicle.placedItems.first.itemCode, equals('matkap'));
      expect(fromMapVehicle.placedItems.first.gridX, equals(2));
      expect(fromMapVehicle.placedItems.first.rotation, equals(90));
    });

    test('PlayerProfileModel cüzdan ve depo slotları doğrulaması', () {
      final profile = PlayerProfileModel(
        id: 1,
        cash: 1250,
        reputation: 40,
        activeVehicleId: 1,
        maxStorageSlots: 20,
        shopStorageItemIds: [1, 2, 3],
      );

      final map = profile.toMap();
      final fromMapProfile = PlayerProfileModel.fromMap(map);

      expect(fromMapProfile.cash, equals(1250));
      expect(fromMapProfile.shopStorageItemIds, equals([1, 2, 3]));
    });

    test('StorageUnitModel katmanlı eşya ve ihale türü doğrulaması', () {
      final unit = StorageUnitModel(
        id: 101,
        title: 'Birim #204 - Terk Edilmiş Garaj',
        archetype: 'mechanic',
        auctionType: StorageAuctionType.onlineAuction,
        unitDimensions: '3x4 metre',
        estimatedBoxCount: 8,
        startingBid: 300,
        items: [
          RaidItemRecord(itemCode: 'v8_motor_blogu', layer: 1, posX: 0.5, posY: 0.7),
          RaidItemRecord(itemCode: 'kulce_altin', layer: 3, posX: 0.2, posY: 0.3),
        ],
      );

      final map = unit.toMap();
      final fromMapUnit = StorageUnitModel.fromMap(map);

      expect(fromMapUnit.id, equals(101));
      expect(fromMapUnit.auctionType, equals(StorageAuctionType.onlineAuction));
      expect(fromMapUnit.items.length, equals(2));
      expect(fromMapUnit.items.last.layer, equals(3));
    });
  });
}

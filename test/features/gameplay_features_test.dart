import 'package:flutter_test/flutter_test.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/utils/bitboard_engine.dart';
import 'package:yeni_oyun_sablon/features/crafting_benches/providers/crafting_bench_provider.dart';
import 'package:yeni_oyun_sablon/features/dungeon/models/mercenary_model.dart';
import 'package:yeni_oyun_sablon/features/marketplace/providers/marketplace_provider.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

void main() {
  group('Faz 3: Bagaj Tetrisi, 90° Döndürme ve Usta İstifçi Testleri', () {
    test('BitboardEngine.rotate90 ile şekil doğru transpoze edilmeli', () {
      // 2x3 L parçası:
      // 1 0
      // 1 0
      // 1 1  => bitmask: [1, 1, 3] (W: 2, H: 3)
      final originalShape = [1, 1, 3];
      final rotated = BitboardEngine.rotate90(
        shape: originalShape,
        originalW: 2,
        originalH: 3,
      );

      // Yeni boyutlar: W: 3, H: 2
      expect(rotated.length, equals(2));
      // İlk satır: [1, 1, 1] -> 7
      // İkinci satır: [1, 0, 0] -> 1
      expect(rotated[0], equals(7));
      expect(rotated[1], equals(1));
    });

    test('TrunkInventoryState doluluk oranı ve Usta İstifçi tespiti', () {
      final state = TrunkInventoryState(
        vehicleId: 1,
        vehicleName: 'Pikap',
        gridWidth: 4,
        gridHeight: 4, // Toplam 16 hücre
        maxWeightKg: 500,
        currentWeightKg: 100,
        gridRows: [
          15, // 1111 (4 hücre)
          15, // 1111 (4 hücre)
          15, // 1111 (4 hücre)
          7,  // 0111 (3 hücre) -> Toplam 15/16 hücre = %93.75
        ],
        placedItems: const [],
      );

      expect(state.totalCells, equals(16));
      expect(state.occupiedCells, equals(15));
      expect(state.fillRatio, closeTo(0.9375, 0.001));
      expect(state.isMasterPacker, isTrue); // %80 üzeri
    });
  });

  group('Faz 4: Atölye Restorasyon Ustalığı ve Pazar Yeri Fiyatlandırma Testleri', () {
    test('CraftingBenchState seviye ve otomatik parlatma kilidi', () {
      const stateLvl1 = CraftingBenchState(masteryXp: 50, masteryLevel: 1);
      expect(stateLvl1.hasAutoPolishUnlocked, isFalse);

      const stateLvl3 = CraftingBenchState(masteryXp: 320, masteryLevel: 3);
      expect(stateLvl3.hasAutoPolishUnlocked, isTrue);
    });

    test('MarketplaceState dinamik fiyat ve çarpan hesabı', () {
      final item = ItemModel(
        id: 1,
        code: 'kamera',
        nameTr: 'Vintage Kamera',
        nameEn: 'Vintage Camera',
        nameRu: 'Винтажная камера',
        nameEs: 'Cámara vintage',
        category: 'electronics',
        baseValue: 400,
        width: 1,
        height: 1,
        bitmask: [1],
        weight: 1.5,
        spritePath: 'assets/items/elektronik/01.webp',
      );

      final state = MarketplaceState(activeItem: item, priceMultiplier: 1.5);
      expect(state.listingPrice, equals(600)); // 400 * 1.5 = 600 ₺
    });
  });

  group('Faz 5: Zindan Savaşçı Gücü ve Kışla Dinlenme Odası Konfor Testleri', () {
    test('MercenaryModel kuşanılan eşyalara göre güç hesabı', () {
      final sword = ItemModel(
        id: 1,
        code: 'antik_kilic',
        nameTr: 'Antik Kılıç',
        nameEn: 'Antique Sword',
        nameRu: 'Меч',
        nameEs: 'Espada',
        category: 'weapons',
        baseValue: 300,
        width: 1,
        height: 3,
        bitmask: [1, 1, 1],
        weight: 4.0,
        spritePath: 'assets/items/weapons/01.webp',
      );

      final merc = MercenaryModel(
        id: 1,
        name: 'Barın',
        role: 'Avcı',
        avatar: '🏹',
        equippedItems: [sword],
      );

      // Taban güç 50 + (300 * 0.5 = 150) = 200
      expect(merc.totalCombatPower, equals(200));
    });

    test('RestingLoungeModel mobilya konfor skoru ve dinlenme indirimi', () {
      final sofa = ItemModel(
        id: 2,
        code: 'deri_koltuk',
        nameTr: 'Deri Koltuk',
        nameEn: 'Leather Sofa',
        nameRu: 'Диван',
        nameEs: 'Sofá',
        category: 'furniture',
        baseValue: 800,
        width: 2,
        height: 2,
        bitmask: [3, 3],
        weight: 35.0,
        spritePath: 'assets/items/furniture/01.webp',
      );

      final lounge = RestingLoungeModel(placedDecorations: [sofa]);

      // Konfor skoru: 800 * 0.1 = 80
      expect(lounge.totalComfortScore, equals(80));

      // Dinlenme süresi indirimi: 1.0 - (80 / 1000) = 0.92x
      expect(lounge.restSpeedMultiplier, closeTo(0.92, 0.001));
    });
  });
}

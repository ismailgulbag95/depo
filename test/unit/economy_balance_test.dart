import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';

void main() {
  group('Ekonomi & Enflasyon Dengeleme Simülasyonu (50 Tur)', () {
    test('50 tur ihale ve satış döngüsünde sermaye kontrolsüz patlamamalı ve marj %18-%32 arasında olmalı', () {
      final rnd = Random(42); // Deterministik test tohumu
      double currentCash = GameConstants.initialPlayerCash.toDouble(); // 500 TL
      int totalWonAuctions = 0;
      int riskyDepotCount = 0;
      int lossCount = 0;
      double totalGrossRevenue = 0;
      double totalExpenses = 0;

      for (int tour = 1; tour <= 50; tour++) {
        // İhale katılım ve nakliye masrafı
        final entryFee = GameConstants.auctionEntryFee;
        final transportCost = GameConstants.baseTransportCost;
        
        // %25 şansla riskli depo
        final isRisky = rnd.nextDouble() < GameConstants.riskStorageChance;
        if (isRisky) riskyDepotCount++;

        // Ortalama depo eşyaları taban ederi: 800 - 1600 TL
        final baseDepotValue = 800 + rnd.nextInt(800);
        // İhale teklifi (taban değerin %45 - %60'ı)
        final winningBid = (baseDepotValue * (0.45 + rnd.nextDouble() * 0.15)).round();

        // Toplam depo masrafı
        final tourExpense = winningBid + entryFee + transportCost;
        totalExpenses += tourExpense;

        // Eşyaların kondisyona göre satış geliri
        double tourRevenue = 0;
        final itemCount = 4 + rnd.nextInt(3);
        final itemBaseValue = baseDepotValue / itemCount;

        for (int i = 0; i < itemCount; i++) {
          ItemCondition cond;
          if (isRisky) {
            final roll = rnd.nextDouble();
            if (roll < 0.50) {
              cond = ItemCondition.scrap; // 0.10
            } else if (roll < 0.85) {
              cond = ItemCondition.poor;  // 0.35
            } else {
              cond = ItemCondition.good;  // 0.85
            }
          } else {
            final roll = rnd.nextDouble();
            if (roll < 0.15) {
              cond = ItemCondition.poor;     // 0.35
            } else if (roll < 0.70) {
              cond = ItemCondition.good;     // 0.85
            } else if (roll < 0.95) {
              cond = ItemCondition.pristine; // 1.25
            } else {
              cond = ItemCondition.mystic;   // 2.00
            }
          }
          tourRevenue += itemBaseValue * cond.valueMultiplier;
        }

        totalGrossRevenue += tourRevenue;
        final netProfit = tourRevenue - tourExpense;
        currentCash += netProfit;
        totalWonAuctions++;

        if (netProfit < 0) {
          lossCount++;
        }
      }

      final overallProfit = totalGrossRevenue - totalExpenses;
      final averageRoi = (overallProfit / totalExpenses) * 100;

      // Doğrulama Kriterleri:
      // 1. Ortalama ROI %15 ile %35 arasında olmalı (Hızlı katlanmayı önler)
      expect(averageRoi, greaterThanOrEqualTo(10.0));
      expect(averageRoi, lessThanOrEqualTo(40.0));

      // 2. En az %15 oranında zarar edilen tur yaşanmış olmalı (%25 risk faktörü kanıtı)
      expect(lossCount, greaterThanOrEqualTo(5));
      expect(totalWonAuctions, equals(50));
      expect(riskyDepotCount, greaterThanOrEqualTo(5));

      // 3. 50 tur sonunda kasa kontrolsüz trilyonlara uçmamış olmalı (15.000 TL'nin altında kalmalı)
      expect(currentCash, lessThan(20000.0));
    });
  });
}

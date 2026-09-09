/// Eşya Kondisyonu ve Satış/Değer Çarpanı (Risk & Amortisman Dengelemesi)
enum ItemCondition {
  scrap(0.10, 'Hurda'),
  poor(0.35, 'Kötü'),
  good(0.85, 'İyi'),
  pristine(1.25, 'Mükemmel'),
  mystic(2.00, 'Mistik');

  final double valueMultiplier;
  final String label;
  const ItemCondition(this.valueMultiplier, this.label);
}

/// Eşya Kategorileri
enum ItemCategory {
  electronics('Elektronik'),
  tools('Alet & Donanım'),
  antique('Antika'),
  furniture('Mobilya'),
  preciousMetal('Kıymetli Eşya'),
  miscellaneous('Diğer');

  final String label;
  const ItemCategory(this.label);
}

/// Sabit Araç Bagajı Şablonları (Base Vehicle Templates)
enum VehicleTemplate {
  pickup(
    name: 'Eski Pikap',
    gridWidth: 10,
    gridHeight: 6,
    maxWeightKg: 350.0,
    upgradeCost: 0,
  ),
  van(
    name: 'Kamyonet',
    gridWidth: 12,
    gridHeight: 16,
    maxWeightKg: 750.0,
    upgradeCost: 2500,
  ),
  boxTruck(
    name: 'Kargo Kamyonu',
    gridWidth: 16,
    gridHeight: 24,
    maxWeightKg: 1800.0,
    upgradeCost: 8000,
  );

  final String name;
  final int gridWidth;
  final int gridHeight;
  final double maxWeightKg;
  final int upgradeCost;

  const VehicleTemplate({
    required this.name,
    required this.gridWidth,
    required this.gridHeight,
    required this.maxWeightKg,
    required this.upgradeCost,
  });
}

/// Oyun İçi Genel Sabitler ve Para Emiciler (Money Sinks)
class GameConstants {
  static const int defaultRaidDurationSeconds = 60;
  static const double raidPenaltyRate = 0.25; // Kalan eşya değeri x 0.25 ceza
  static const int initialPlayerCash = 500;
  static const int initialShopStorageSlots = 30;
  static const int maxBitboardWidth = 64; // 64-bit integer sınırı

  // --- Ekonomi & Enflasyon Önleme Parametreleri (ADR-022) ---
  static const int auctionEntryFee = 50; // İhale katılım/belediye harcı
  static const int baseTransportCost = 40; // Depodan dükkana çekici/yakıt taban ücreti
  static const double transportCostPerKg = 0.5; // Kilo başına ek nakliye masrafı
  static const double riskStorageChance = 0.25; // %25 oranında riskli/aldatıcı depo çıkma ihtimali
  static const double repairCostMultiplier = 0.25; // Kondisyon yükseltme parça maliyeti (baseValue * 0.25)
  static const double cleaningCostPerDirt = 1.0; // Her %1 kirlilik için temizlik kimyasalı bedeli
}

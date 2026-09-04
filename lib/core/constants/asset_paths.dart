/// Oyun İçi Görsel Varlık Yolları ve Modüler Varlık Kaydı (ADR-002, ADR-017, ADR-021)
/// Tüm görseller bu merkezi dosyadan yönetilir; herhangi bir görsel revize edildiğinde
/// sadece bu dosyadaki yol veya assets/ altındaki dosya güncellenir.
class GameAssetPaths {
  // --- KARAKTERLER (Characters) ---
  static const String auctioneerDan = 'assets/characters/auctioneer_dan.jpg';
  static const String rivalDave = 'assets/characters/rival_dave.jpg';
  static const String rivalLaura = 'assets/characters/rival_laura.jpg';
  static const String rivalGus = 'assets/characters/rival_gus.jpg';

  // --- MÜŞTERİLER (Customers) ---
  static const String customerBob = 'assets/characters/customer_bob.jpg';
  static const String customerVictoria = 'assets/characters/customer_victoria.jpg';

  // --- ARAÇLAR & BAGAJ KASALARI (Vehicles & Trunks) ---
  static const String trunkPickup = 'assets/vehicles/trunk_pickup.jpg';
  static const String trunkVan = 'assets/vehicles/trunk_van.jpg';
  static const String trunkTruck = 'assets/vehicles/trunk_truck.jpg';
  static const String vehicleEmergencyTow = 'assets/vehicles/vehicle_emergency_tow.jpg';

  // --- MEKAN ARKA PLANLARI (Backgrounds) ---
  static const String bgAuctionYard = 'assets/backgrounds/bg_auction_yard.jpg';
  static const String bgWorkshopGarage = 'assets/backgrounds/bg_workshop_garage.jpg';
  static const String bgMarketplaceStore = 'assets/backgrounds/bg_marketplace_store.jpg';

  /// Rakip ismine göre uygun karakter portresini döner
  static String getRivalAvatar(String rivalName) {
    final lower = rivalName.toLowerCase();
    if (lower.contains('dave')) return rivalDave;
    if (lower.contains('laura')) return rivalLaura;
    if (lower.contains('gus')) return rivalGus;
    return auctioneerDan;
  }

  /// Araç türüne göre uygun bagaj kasası görselini döner
  static String getTrunkBackground(String vehicleType) {
    final lower = vehicleType.toLowerCase();
    if (lower.contains('van') || lower.contains('kamyonet')) return trunkVan;
    if (lower.contains('truck') || lower.contains('tır') || lower.contains('kargo')) return trunkTruck;
    return trunkPickup;
  }
}

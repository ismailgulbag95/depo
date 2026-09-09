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
  static const String bgHomeOffice = 'assets/backgrounds/bg_home_office.jpg';
  static const String bgAuctionYard = 'assets/backgrounds/bg_auction_yard.jpg';
  static const String bgWorkshopGarage = 'assets/backgrounds/bg_workshop_garage.jpg';
  static const String bgMarketplaceStore = 'assets/backgrounds/bg_marketplace_store.jpg';
  static const String bgHomeWorkshop = 'assets/backgrounds/bg_home_workshop.jpg';
  static const String bgTavernPanoramic = 'assets/backgrounds/bg_tavern_panoramic.jpg';
  static const String bgCityMapTactical = 'assets/backgrounds/bg_city_map_tactical.jpg';
  static const String bgBarracksEmpty = 'assets/backgrounds/bg_barracks_empty.jpg';
  static const String bgBarracksWarrior = 'assets/backgrounds/bg_barracks_warrior.jpg';
  static const String bgBarracksAssassin = 'assets/backgrounds/bg_barracks_assassin.jpg';
  static const String bgBarracksArcher = 'assets/backgrounds/bg_barracks_archer.jpg';
  static const String bgBarracksMage = 'assets/backgrounds/bg_barracks_mage.jpg';
  static const String bgBarracksKnight = 'assets/backgrounds/bg_barracks_knight.jpg';

  // --- HARİTA NAVİGASYON İKONLARI (Map Waypoint Icons) ---
  static const String iconMapHome = 'assets/ui/icon_map_home.png';
  static const String iconMapWholesaler = 'assets/ui/icon_map_wholesaler.png';
  static const String iconMapDealership = 'assets/ui/icon_map_dealership.png';
  static const String iconMapPawn = 'assets/ui/icon_map_pawn.png';
  static const String iconMapAuction = 'assets/ui/icon_map_auction.png';
  static const String iconMapRealEstate = 'assets/ui/icon_map_real_estate.png';
  static const String iconMapTavern = 'assets/ui/icon_map_tavern.png';
  static const String iconMapDungeon = 'assets/ui/icon_map_dungeon.png';

  // --- SES EFEKTLERİ (Audio Sound Effects) ---
  static const String sfxGavel = 'audio/gavel.wav';
  static const String sfxCoin = 'audio/coin.wav';
  static const String sfxClick = 'audio/click.wav';
  static const String sfxCrush = 'audio/crush.wav';
  static const String sfxHit = 'audio/hit.wav';
  static const String sfxVictory = 'audio/victory.wav';
  static const String sfxWarning = 'audio/warning.wav';
  static const String sfxPack = 'audio/pack.wav';

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


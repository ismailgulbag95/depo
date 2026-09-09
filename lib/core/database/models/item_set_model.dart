/// Koleksiyon Seti Ödül Türü
enum SetBonusType {
  saleMultiplier, // Müzayede ve dükkanda yüksek fiyatla satma (+%35 - +%75)
  workshopSpeed, // Atölye restorasyon ve üretim hız bonusu (+%30 - +%100)
  reputationMultiplier, // İtibar puanı katlayıcı (x1.5 - x3.0)
  specialAccess, // Özel depo, kilitli kasa veya gizli alanlara doğrudan erişim yetkisi
  raidLuckBonus, // Depo baskınlarında nadir ve gizli hazine bulma şansı bonusu
  bargainMastery, // Müzayedede rakipleri sindirme ve çekilmeye zorlama gücü
}

/// Set Nadirlik Derecesi
enum SetRarity {
  common, // Yaygın (Bronz Çerçeve)
  rare, // Nadir (Mavi Çerçeve)
  epic, // Epik (Mor Çerçeve)
  legendary, // Efsanevi (Altın Çerçeve)
  mythic, // Mitolojik / Melez (Kızıl-Plazma Çerçeve)
}

/// Kademeli Set Bonusu Tanımı (2 parça, 4 parça veya Tam Set)
class SetTierPerk {
  final int requiredCount; // Gereken parça sayısı
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final double bonusMultiplier; // Çarpan

  const SetTierPerk({
    required this.requiredCount,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.bonusMultiplier,
  });
}

/// Gelişmiş Koleksiyon ve Sinerji Seti Veri Modeli
class ItemSetModel {
  final String id;
  final String nameTr;
  final String nameEn;
  final String descriptionTr;
  final String descriptionEn;
  final String loreTr; // Setin arka plan hikayesi
  final String loreEn;
  final String category;
  final SetRarity rarity;
  final List<String> requiredItemCodes; // Sette gereken eşya kodları
  final SetBonusType bonusType;
  final double bonusMultiplier; // Tam set çarpanı (Örn: 1.50 = +%50 kâr)
  final int cashReward; // Tamamlanınca anlık nakit ödülü
  final int reputationReward; // Tamamlanınca itibar ödülü
  final String badgeIcon; // İkon
  final String passivePerkCode; // Özel sistem pasifi (Örn: 'bypass_vault_locks', 'radiation_immunity')
  final List<SetTierPerk> tierPerks; // Kademeli bonuslar (2 ve 4 parça avantajları)

  const ItemSetModel({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    this.loreTr = '',
    this.loreEn = '',
    required this.category,
    this.rarity = SetRarity.rare,
    required this.requiredItemCodes,
    required this.bonusType,
    this.bonusMultiplier = 1.35,
    this.cashReward = 1000,
    this.reputationReward = 250,
    this.badgeIcon = 'trophy',
    this.passivePerkCode = '',
    this.tierPerks = const [],
  });

  String localizedName(String langCode) {
    return langCode.toLowerCase() == 'tr' ? nameTr : nameEn;
  }

  String localizedDescription(String langCode) {
    return langCode.toLowerCase() == 'tr' ? descriptionTr : descriptionEn;
  }

  String localizedLore(String langCode) {
    return langCode.toLowerCase() == 'tr' ? loreTr : loreEn;
  }

  /// Verilen eşya kodları listesine göre sette kaç parçanın toplandığını hesaplar
  int getCollectedCount(List<String> userItemCodes) {
    int count = 0;
    for (final req in requiredItemCodes) {
      if (userItemCodes.contains(req)) {
        count++;
      }
    }
    return count;
  }

  /// Set tamamlandı mı?
  bool isCompleted(List<String> userItemCodes) {
    return getCollectedCount(userItemCodes) == requiredItemCodes.length;
  }

  /// Tamamlanma yüzdesi (0.0 - 1.0)
  double getProgress(List<String> userItemCodes) {
    if (requiredItemCodes.isEmpty) return 0.0;
    return getCollectedCount(userItemCodes) / requiredItemCodes.length;
  }

  /// Kullanıcının şu an aktif olan en yüksek kademe perk'i
  SetTierPerk? getActiveTierPerk(List<String> userItemCodes) {
    final collected = getCollectedCount(userItemCodes);
    SetTierPerk? best;
    for (final perk in tierPerks) {
      if (collected >= perk.requiredCount) {
        if (best == null || perk.requiredCount > best.requiredCount) {
          best = perk;
        }
      }
    }
    return best;
  }
}


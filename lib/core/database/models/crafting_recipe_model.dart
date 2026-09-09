/// Zanaat Reçete Türü
enum RecipeType {
  assembly, // Montaj / Birleştirme (3 parça -> 1 Üst Eşya)
  salvage, // Demontaj / Parçalama (1 Eşya -> Parçalar ve Hurda)
  refurbish, // İleri Düzey Restorasyon / Kimyasal Arındırma
  upgrade, // Modifikasyon / Güçlendirme
}

/// Girdi veya Çıktı Eşya Gereksinimi
class RecipeItemRequirement {
  final String itemCode;
  final int count;

  const RecipeItemRequirement({
    required this.itemCode,
    this.count = 1,
  });

  Map<String, dynamic> toMap() => {
        'itemCode': itemCode,
        'count': count,
      };

  factory RecipeItemRequirement.fromMap(Map<String, dynamic> map) {
    return RecipeItemRequirement(
      itemCode: map['itemCode'] as String? ?? '',
      count: (map['count'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Zanaat & Tezgâh Reçete Modeli
class CraftingRecipeModel {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final RecipeType type;
  final int requiredMasteryLevel; // Gereken atölye ustalık seviyesi (1-10)
  final String? requiredToolCategory; // Örn: 'manuel_el_aletleri', 'tezgah_donanimlari'
  final String? requiredToolCode; // Spesifik bir alet gerekiyorsa (Örn: 'lehim_istasyonu')
  final List<RecipeItemRequirement> inputs; // Tüketilecek malzemeler
  final List<RecipeItemRequirement> outputs; // Elde edilecek eşyalar
  final int cashCost; // İşçilik / sarf malzeme ücreti (TL)
  final int rewardXp; // Kazanılan ustalık tecrübe puanı
  final int durationSeconds; // İşlem süresi (0 = anında)

  const CraftingRecipeModel({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.type,
    this.requiredMasteryLevel = 1,
    this.requiredToolCategory,
    this.requiredToolCode,
    required this.inputs,
    required this.outputs,
    this.cashCost = 0,
    this.rewardXp = 25,
    this.durationSeconds = 0,
  });

  String localizedTitle(String langCode) {
    return langCode.toLowerCase() == 'tr' ? titleTr : titleEn;
  }

  String localizedDescription(String langCode) {
    return langCode.toLowerCase() == 'tr' ? descriptionTr : descriptionEn;
  }
}

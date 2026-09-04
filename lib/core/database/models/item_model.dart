import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';

/// Eşya Veri Modeli (Hive & Pure Dart Uyumlu)
class ItemModel {
  int id;
  String code;
  String nameTr;
  String nameEn;
  String nameRu;
  String nameEs;
  String category;
  int baseValue;
  int width;
  int height;
  List<int> bitmask;
  double weight;
  String spritePath;
  ItemCondition condition;
  double dirtPercentage;

  ItemModel({
    required this.id,
    required this.code,
    required this.nameTr,
    required this.nameEn,
    required this.nameRu,
    required this.nameEs,
    required this.category,
    required this.baseValue,
    required this.width,
    required this.height,
    required this.bitmask,
    required this.weight,
    required this.spritePath,
    this.condition = ItemCondition.good,
    this.dirtPercentage = 0.0,
  });

  /// Varsayılan isim (nameTr)
  String get name => nameTr;

  /// Seçili dil koduna göre eşyanın yerelleştirilmiş adını döndürür
  String localizedName(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'tr': return nameTr;
      case 'ru': return nameRu;
      case 'es': return nameEs;
      case 'en':
      default: return nameEn.isNotEmpty ? nameEn : nameTr;
    }
  }

  /// Kondisyona göre hesaplanan anlık piyasa değeri
  int get currentValue => (baseValue * condition.valueMultiplier).round();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'nameTr': nameTr,
      'nameEn': nameEn,
      'nameRu': nameRu,
      'nameEs': nameEs,
      'category': category,
      'baseValue': baseValue,
      'width': width,
      'height': height,
      'bitmask': bitmask,
      'weight': weight,
      'spritePath': spritePath,
      'condition': condition.name,
      'dirtPercentage': dirtPercentage,
    };
  }

  factory ItemModel.fromMap(Map<dynamic, dynamic> map) {
    return ItemModel(
      id: map['id'] as int? ?? 0,
      code: map['code'] as String? ?? '',
      nameTr: map['nameTr'] as String? ?? map['name_tr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? map['name_en'] as String? ?? '',
      nameRu: map['nameRu'] as String? ?? map['name_ru'] as String? ?? '',
      nameEs: map['nameEs'] as String? ?? map['name_es'] as String? ?? '',
      category: map['category'] as String? ?? 'tools',
      baseValue: (map['baseValue'] as num?)?.toInt() ?? 100,
      width: (map['width'] as num?)?.toInt() ?? 1,
      height: (map['height'] as num?)?.toInt() ?? 1,
      bitmask: (map['bitmask'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [1],
      weight: (map['weight'] as num?)?.toDouble() ?? 1.0,
      spritePath: map['spritePath'] as String? ?? '',
      condition: ItemCondition.values.firstWhere(
        (c) => c.name == map['condition'],
        orElse: () => ItemCondition.good,
      ),
      dirtPercentage: (map['dirtPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

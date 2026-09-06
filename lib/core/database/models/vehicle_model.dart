/// Bagajdaki Eşya Yerleşim Kaydı (Pure Dart)
class PlacerRecord {
  int? itemId;
  String? itemCode;
  int? gridX;
  int? gridY;
  int? rotation;

  PlacerRecord({
    this.itemId,
    this.itemCode,
    this.gridX,
    this.gridY,
    this.rotation = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemCode': itemCode,
      'gridX': gridX,
      'gridY': gridY,
      'rotation': rotation,
    };
  }

  factory PlacerRecord.fromMap(Map<dynamic, dynamic> map) {
    return PlacerRecord(
      itemId: map['itemId'] as int?,
      itemCode: map['itemCode'] as String?,
      gridX: map['gridX'] as int?,
      gridY: map['gridY'] as int?,
      rotation: map['rotation'] as int? ?? 0,
    );
  }
}

/// Araç Modeli (Pure Dart)
class VehicleModel {
  int id;
  String name;
  int gridWidth;
  int gridHeight;
  double maxWeightKg;
  List<String> installedAddons;
  List<PlacerRecord> placedItems;

  VehicleModel({
    required this.id,
    required this.name,
    required this.gridWidth,
    required this.gridHeight,
    required this.maxWeightKg,
    this.installedAddons = const [],
    this.placedItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gridWidth': gridWidth,
      'gridHeight': gridHeight,
      'maxWeightKg': maxWeightKg,
      'installedAddons': installedAddons,
      'placedItems': placedItems.map((p) => p.toMap()).toList(),
    };
  }

  factory VehicleModel.fromMap(Map<dynamic, dynamic> map) {
    return VehicleModel(
      id: map['id'] as int? ?? 1,
      name: map['name'] as String? ?? 'Pikap',
      gridWidth: map['gridWidth'] as int? ?? 10,
      gridHeight: map['gridHeight'] as int? ?? 6,
      maxWeightKg: (map['maxWeightKg'] as num?)?.toDouble() ?? 500.0,
      installedAddons: (map['installedAddons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      placedItems: (map['placedItems'] as List<dynamic>?)
              ?.map((e) => PlacerRecord.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          [],
    );
  }
}

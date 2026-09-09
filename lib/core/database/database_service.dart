import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/player_profile_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/storage_unit_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/vehicle_model.dart';

/// Evrensel NoSQL Veritabanı Yöneticisi (Pure Dart & Hive)
/// Web (Chrome), Windows, Android ve iOS ortamlarında %100 sıfır konfigürasyonla çalışır.
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  DatabaseService._();

  late Box _itemsBox;
  late Box _vehiclesBox;
  late Box _profilesBox;
  late Box _storageUnitsBox;

  /// Veritabanını başlatır ve gerekirse seed verilerini yükler
  Future<void> init() async {
    await Hive.initFlutter();

    _itemsBox = await Hive.openBox('items_box');
    _vehiclesBox = await Hive.openBox('vehicles_box');
    _profilesBox = await Hive.openBox('profiles_box');
    _storageUnitsBox = await Hive.openBox('storage_units_box');

    await _seedDefaultData();
  }

  /// Veritabanı boşsa varsayılan eşyaları ve oyuncu profilini oluşturur
  Future<void> _seedDefaultData() async {
    // 1. Eşya Kataloğunu Tohumlama (default_items.json)
    try {
      final jsonString = await rootBundle.loadString('assets/data/default_items.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Şema güncellemesi veya eşya sayısı değişikliği kontrolü
      final firstItemData = _itemsBox.isNotEmpty ? _itemsBox.get(1) : null;
      final needsReseed = _itemsBox.length != jsonList.length ||
          (firstItemData is Map && !firstItemData.containsKey('roomHeightRatio'));

      if (needsReseed) {
        await _itemsBox.clear();
      }

      if (_itemsBox.isEmpty) {
        int autoId = 1;
        for (final itemJson in jsonList) {
          final item = ItemModel(
            id: autoId,
            code: (itemJson['code'] ?? '') as String,
            nameTr: (itemJson['name_tr'] ?? itemJson['name'] ?? '') as String,
            nameEn: (itemJson['name_en'] ?? itemJson['name_tr'] ?? '') as String,
            nameRu: (itemJson['name_ru'] ?? itemJson['name_tr'] ?? '') as String,
            nameEs: (itemJson['name_es'] ?? itemJson['name_tr'] ?? '') as String,
            category: (itemJson['category'] ?? 'tools') as String,
            baseValue: (itemJson['baseValue'] as num?)?.toInt() ?? 100,
            width: (itemJson['width'] as num?)?.toInt() ?? 1,
            height: (itemJson['height'] as num?)?.toInt() ?? 1,
            bitmask: (itemJson['bitmask'] as List<dynamic>?)
                    ?.map((e) => (e as num).toInt())
                    .toList() ??
                [1],
            weight: (itemJson['weight'] as num?)?.toDouble() ?? 1.0,
            roomHeightRatio: (itemJson['roomHeightRatio'] as num?)?.toDouble(),
            spritePath: (itemJson['spritePath'] ?? '') as String,
            condition: ItemCondition.values.firstWhere(
              (c) => c.name == itemJson['condition'],
              orElse: () => ItemCondition.good,
            ),
            dirtPercentage: (itemJson['dirtPercentage'] as num?)?.toDouble() ?? 0.0,
          );
          await _itemsBox.put(autoId, item.toMap());
          autoId++;
        }
      }
    } catch (e) {
      debugPrint('Eşya tohumlama hatası: $e');
    }

    // 2. Başlangıç Oyuncu Profili ve Varsayılan Araç
    if (_profilesBox.isEmpty) {
      // Varsayılan Pikap (8x12, 500kg)
      final defaultVehicle = VehicleModel(
        id: 1,
        name: VehicleTemplate.pickup.name,
        gridWidth: VehicleTemplate.pickup.gridWidth,
        gridHeight: VehicleTemplate.pickup.gridHeight,
        maxWeightKg: VehicleTemplate.pickup.maxWeightKg,
        installedAddons: [],
        placedItems: [],
      );
      await _vehiclesBox.put(1, defaultVehicle.toMap());

      // Başlangıç Oyuncu Profili (500 TL nakit, Pikap aracı)
      final defaultProfile = PlayerProfileModel(
        id: 1,
        cash: GameConstants.initialPlayerCash,
        reputation: 0,
        activeVehicleId: 1,
        maxStorageSlots: GameConstants.initialShopStorageSlots,
        shopStorageItemIds: [],
      );
      await _profilesBox.put(1, defaultProfile.toMap());
    }
  }

  /// Tüm eşyaları getirir (Garantili Fallback ile)
  Future<List<ItemModel>> getAllItems() async {
    final list = <ItemModel>[];
    for (final key in _itemsBox.keys) {
      final data = _itemsBox.get(key);
      if (data is Map) {
        list.add(ItemModel.fromMap(data));
      }
    }

    // Eğer kutu henüz tohumlanmadıysa doğrudan JSON dosyasından oku ve tohumla
    if (list.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString('assets/data/default_items.json');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        int autoId = 1;
        for (final itemJson in jsonList) {
          final item = ItemModel(
            id: autoId,
            code: (itemJson['code'] ?? '') as String,
            nameTr: (itemJson['name_tr'] ?? itemJson['name'] ?? '') as String,
            nameEn: (itemJson['name_en'] ?? itemJson['name_tr'] ?? '') as String,
            nameRu: (itemJson['name_ru'] ?? itemJson['name_tr'] ?? '') as String,
            nameEs: (itemJson['name_es'] ?? itemJson['name_tr'] ?? '') as String,
            category: (itemJson['category'] ?? 'tools') as String,
            baseValue: (itemJson['baseValue'] as num?)?.toInt() ?? 100,
            width: (itemJson['width'] as num?)?.toInt() ?? 1,
            height: (itemJson['height'] as num?)?.toInt() ?? 1,
            bitmask: (itemJson['bitmask'] as List<dynamic>?)
                    ?.map((e) => (e as num).toInt())
                    .toList() ??
                [1],
            weight: (itemJson['weight'] as num?)?.toDouble() ?? 1.0,
            roomHeightRatio: (itemJson['roomHeightRatio'] as num?)?.toDouble(),
            spritePath: (itemJson['spritePath'] ?? '') as String,
            condition: ItemCondition.values.firstWhere(
              (c) => c.name == itemJson['condition'],
              orElse: () => ItemCondition.good,
            ),
            dirtPercentage: (itemJson['dirtPercentage'] as num?)?.toDouble() ?? 0.0,
          );
          await _itemsBox.put(autoId, item.toMap());
          list.add(item);
          autoId++;
        }
      } catch (e) {
        debugPrint('Tohumlama fallback hatası: $e');
      }
    }

    return list;
  }

  /// ID'ye göre tekil eşya getirir
  Future<ItemModel?> getItemById(int id) async {
    final data = _itemsBox.get(id);
    if (data is Map) {
      return ItemModel.fromMap(data);
    }
    return null;
  }

  /// Koda göre tekil eşya getirir
  Future<ItemModel?> getItemByCode(String code) async {
    for (final key in _itemsBox.keys) {
      final data = _itemsBox.get(key);
      if (data is Map && data['code'] == code) {
        return ItemModel.fromMap(data);
      }
    }
    return null;
  }

  /// Aktif oyuncu profilini getirir
  Future<PlayerProfileModel?> getPlayerProfile() async {
    final data = _profilesBox.get(1);
    if (data is Map) {
      return PlayerProfileModel.fromMap(data);
    }
    return null;
  }

  /// Oyuncu profilini kaydeder
  Future<void> savePlayerProfile(PlayerProfileModel profile) async {
    await _profilesBox.put(profile.id, profile.toMap());
  }

  /// Aktif aracı getirir
  Future<VehicleModel?> getActiveVehicle() async {
    final profile = await getPlayerProfile();
    final vehicleId = profile?.activeVehicleId ?? 1;
    final data = _vehiclesBox.get(vehicleId);
    if (data is Map) {
      return VehicleModel.fromMap(data);
    }
    return null;
  }

  /// Eşyayı günceller ve veritabanına kaydeder
  Future<void> saveItem(ItemModel item) async {
    await _itemsBox.put(item.id, item.toMap());
  }

  /// Aracı kaydeder
  Future<void> saveVehicle(VehicleModel vehicle) async {
    await _vehiclesBox.put(vehicle.id, vehicle.toMap());
  }

  /// Depo birimlerini kaydeder
  Future<void> saveStorageUnit(StorageUnitModel unit) async {
    await _storageUnitsBox.put(unit.id, unit.toMap());
  }

  /// Tüm depo birimlerini getirir
  Future<List<StorageUnitModel>> getAllStorageUnits() async {
    final list = <StorageUnitModel>[];
    for (final key in _storageUnitsBox.keys) {
      final data = _storageUnitsBox.get(key);
      if (data is Map) {
        list.add(StorageUnitModel.fromMap(data));
      }
    }
    return list;
  }
}

/// Geriye dönük %100 uyumluluk için alias
typedef IsarService = DatabaseService;

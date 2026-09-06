import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/vehicle_model.dart';
import 'package:yeni_oyun_sablon/core/utils/bitboard_engine.dart';

/// Araç Bagajı Grid Durumu
class TrunkInventoryState {
  final int vehicleId;
  final String vehicleName;
  final int gridWidth;
  final int gridHeight;
  final double maxWeightKg;
  final double currentWeightKg;
  final List<int> gridRows;
  final List<PlacerRecord> placedItems;

  const TrunkInventoryState({
    required this.vehicleId,
    required this.vehicleName,
    required this.gridWidth,
    required this.gridHeight,
    required this.maxWeightKg,
    required this.currentWeightKg,
    required this.gridRows,
    required this.placedItems,
  });

  factory TrunkInventoryState.initial() {
    final defaultTpl = VehicleTemplate.pickup;
    return TrunkInventoryState(
      vehicleId: 1,
      vehicleName: defaultTpl.name,
      gridWidth: defaultTpl.gridWidth,
      gridHeight: defaultTpl.gridHeight,
      maxWeightKg: defaultTpl.maxWeightKg,
      currentWeightKg: 0.0,
      gridRows: BitboardEngine.createEmptyGrid(defaultTpl.gridHeight),
      placedItems: const [],
    );
  }

  int get totalCells => gridWidth * gridHeight;

  /// Izgarada dolu olan toplam hücre sayısı
  int get occupiedCells {
    int count = 0;
    for (final row in gridRows) {
      var r = row;
      while (r > 0) {
        count += (r & 1);
        r >>= 1;
      }
    }
    return count;
  }

  /// Doluluk oranı (0.0 - 1.0)
  double get fillRatio => totalCells > 0 ? (occupiedCells / totalCells) : 0.0;

  /// %80 ve üzeri dolulukta Usta İstifçi sayılır
  bool get isMasterPacker => fillRatio >= 0.80;

  TrunkInventoryState copyWith({
    int? vehicleId,
    String? vehicleName,
    int? gridWidth,
    int? gridHeight,
    double? maxWeightKg,
    double? currentWeightKg,
    List<int>? gridRows,
    List<PlacerRecord>? placedItems,
  }) {
    return TrunkInventoryState(
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      maxWeightKg: maxWeightKg ?? this.maxWeightKg,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      gridRows: gridRows ?? this.gridRows,
      placedItems: placedItems ?? this.placedItems,
    );
  }
}

/// Araç Bagajı Polyomino Grid ve Envanter Yöneticisi (Pure Dart & Hive)
class TrunkInventoryNotifier extends StateNotifier<TrunkInventoryState> {
  TrunkInventoryNotifier() : super(TrunkInventoryState.initial()) {
    loadActiveVehicle();
  }

  /// Aktif aracın bagaj verilerini veritabanından yükler
  Future<void> loadActiveVehicle() async {
    try {
      final vehicle = await DatabaseService.instance.getActiveVehicle();
      if (vehicle != null) {
        int gWidth = vehicle.gridWidth;
        int gHeight = vehicle.gridHeight;
        if (vehicle.name == VehicleTemplate.pickup.name && (gWidth != 10 || gHeight != 6)) {
          gWidth = 10;
          gHeight = 6;
          vehicle.gridWidth = 10;
          vehicle.gridHeight = 6;
          DatabaseService.instance.saveVehicle(vehicle);
        }
        var grid = BitboardEngine.createEmptyGrid(gHeight);
        double totalWeight = 0.0;

        for (final placer in vehicle.placedItems) {
          if (placer.itemId != null) {
            final item = await DatabaseService.instance.getItemById(placer.itemId!);
            if (item != null && placer.gridX != null && placer.gridY != null) {
              totalWeight += item.weight;
              final mask = _getRotatedMask(item.bitmask, item.width, item.height, placer.rotation ?? 0);
              grid = BitboardEngine.placeItem(
                gridRows: grid,
                itemMask: mask,
                startX: placer.gridX!,
                startY: placer.gridY!,
              );
            }
          }
        }

        state = TrunkInventoryState(
          vehicleId: vehicle.id,
          vehicleName: vehicle.name,
          gridWidth: gWidth,
          gridHeight: gHeight,
          maxWeightKg: vehicle.maxWeightKg,
          currentWeightKg: totalWeight,
          gridRows: grid,
          placedItems: List<PlacerRecord>.from(vehicle.placedItems),
        );
      }
    } catch (_) {}
  }

  /// Eşyanın verilen rotasyondaki bitmaskesini döndürür
  List<int> _getRotatedMask(List<int> originalMask, int w, int h, int rotation) {
    var shape = List<int>.from(originalMask);
    var curW = w;
    var curH = h;
    final turns = (rotation % 360) ~/ 90;

    for (int i = 0; i < turns; i++) {
      shape = BitboardEngine.rotate90(shape: shape, originalW: curW, originalH: curH);
      final temp = curW;
      curW = curH;
      curH = temp;
    }
    return shape;
  }

  /// Eşyanın belirtilen koordinata sığıp sığmadığını O(1) kontrol eder
  bool canPlaceItem({
    required ItemModel item,
    required int startX,
    required int startY,
    int rotation = 0,
  }) {
    // 1. Ağırlık kontrolü (Hoşgörülü sınır)
    if (state.currentWeightKg + item.weight > state.maxWeightKg) {
      return false;
    }

    // 2. Bitboard çakışma ve sınır kontrolü
    final mask = _getRotatedMask(item.bitmask, item.width, item.height, rotation);
    return BitboardEngine.canPlace(
      gridRows: state.gridRows,
      itemMask: mask,
      startX: startX,
      startY: startY,
      gridWidth: state.gridWidth,
      gridHeight: state.gridHeight,
    );
  }

  /// Eşyayı bagaj ızgarasına yerleştirir
  Future<bool> placeItem({
    required ItemModel item,
    required int startX,
    required int startY,
    int rotation = 0,
  }) async {
    if (!canPlaceItem(item: item, startX: startX, startY: startY, rotation: rotation)) {
      return false;
    }

    final mask = _getRotatedMask(item.bitmask, item.width, item.height, rotation);
    final updatedGrid = BitboardEngine.placeItem(
      gridRows: state.gridRows,
      itemMask: mask,
      startX: startX,
      startY: startY,
    );

    final newPlacer = PlacerRecord(
      itemId: item.id,
      itemCode: item.code,
      gridX: startX,
      gridY: startY,
      rotation: rotation,
    );

    final updatedPlacedItems = List<PlacerRecord>.from(state.placedItems)..add(newPlacer);
    final updatedWeight = state.currentWeightKg + item.weight;

    state = state.copyWith(
      gridRows: updatedGrid,
      placedItems: updatedPlacedItems,
      currentWeightKg: updatedWeight,
    );

    await _persist();
    return true;
  }

  /// Eşyayı ızgaradan kaldırır
  Future<bool> removeItem(int itemId) async {
    final index = state.placedItems.indexWhere((p) => p.itemId == itemId);
    if (index == -1) return false;

    final placer = state.placedItems[index];
    final item = await DatabaseService.instance.getItemById(itemId);

    if (item != null && placer.gridX != null && placer.gridY != null) {
      final mask = _getRotatedMask(item.bitmask, item.width, item.height, placer.rotation ?? 0);
      final updatedGrid = BitboardEngine.removeItem(
        gridRows: state.gridRows,
        itemMask: mask,
        startX: placer.gridX!,
        startY: placer.gridY!,
      );

      final updatedPlacedItems = List<PlacerRecord>.from(state.placedItems)..removeAt(index);
      final updatedWeight = (state.currentWeightKg - item.weight).clamp(0.0, double.infinity);

      state = state.copyWith(
        gridRows: updatedGrid,
        placedItems: updatedPlacedItems,
        currentWeightKg: updatedWeight,
      );

      await _persist();
      return true;
    }

    return false;
  }

  /// Eşyayı bagajdaki ilk uygun boşluğa otomatik yerleştirmeye çalışır (Auto-Snap)
  Future<bool> autoPlaceItem(ItemModel item) async {
    for (int y = 0; y < state.gridHeight; y++) {
      for (int x = 0; x < state.gridWidth; x++) {
        for (int r = 0; r < 4; r++) {
          final rot = r * 90;
          if (canPlaceItem(item: item, startX: x, startY: y, rotation: rot)) {
            return placeItem(item: item, startX: x, startY: y, rotation: rot);
          }
        }
      }
    }
    return false;
  }

  /// Belirtilen hücreye denk gelen yerleşmiş eşyayı bulur, ızgaradan kaldırır ve ItemModel olarak döndürür
  Future<PoppedTrunkItem?> popItemAt(int x, int y) async {
    for (int i = 0; i < state.placedItems.length; i++) {
      final placer = state.placedItems[i];
      if (placer.itemId == null || placer.gridX == null || placer.gridY == null) continue;

      final item = await DatabaseService.instance.getItemById(placer.itemId!);
      if (item == null) continue;

      final mask = _getRotatedMask(item.bitmask, item.width, item.height, placer.rotation ?? 0);
      final itemH = mask.length;

      // Koordinat kontrolü
      for (int r = 0; r < itemH; r++) {
        final rowVal = mask[r];
        for (int c = 0; c < 32; c++) {
          if ((rowVal & (1 << c)) != 0) {
            final cellX = placer.gridX! + c;
            final cellY = placer.gridY! + r;
            if (cellX == x && cellY == y) {
              // Eşya bulundu! Izgaradan kaldır ve döndür
              await removeItem(item.id);
              return PoppedTrunkItem(item: item, rotation: placer.rotation ?? 0);
            }
          }
        }
      }
    }
    return null;
  }

  /// Bagajdaki tüm eşyaları temizler
  Future<void> clearTrunk() async {
    state = state.copyWith(
      gridRows: BitboardEngine.createEmptyGrid(state.gridHeight),
      placedItems: const [],
      currentWeightKg: 0.0,
    );
    await _persist();
  }

  /// Bagaj durumunu kaydeder
  Future<void> _persist() async {
    try {
      final vehicle = VehicleModel(
        id: state.vehicleId,
        name: state.vehicleName,
        gridWidth: state.gridWidth,
        gridHeight: state.gridHeight,
        maxWeightKg: state.maxWeightKg,
        placedItems: state.placedItems,
      );
      await DatabaseService.instance.saveVehicle(vehicle);
    } catch (_) {}
  }
}

/// Global TrunkInventory Provider'ı
final trunkInventoryProvider =
    StateNotifierProvider<TrunkInventoryNotifier, TrunkInventoryState>((ref) {
  return TrunkInventoryNotifier();
});

class PoppedTrunkItem {
  final ItemModel item;
  final int rotation;
  const PoppedTrunkItem({required this.item, required this.rotation});
}


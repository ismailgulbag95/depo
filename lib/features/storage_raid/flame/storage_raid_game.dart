import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/flame/components/raid_item_component.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/services/storage_generator_service.dart';

/// 2D Katmanlı Gerçekçi Depo Yağmalama Flame Sahnesi (ADR-019 & ADR-022)
class StorageRaidGame extends FlameGame {
  final GeneratedStorageUnit storageUnit;
  final void Function(RaidItemComponent item) onItemSelected;
  final VoidCallback onRaidFinished;

  StorageRaidGame({
    required this.storageUnit,
    required this.onItemSelected,
    required this.onRaidFinished,
  });

  /// Sıfır Jank için Flutter HUD ile paylaşılan sayaç
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(
    GameConstants.defaultRaidDurationSeconds,
  );

  double _timerAcc = 0.0;
  bool isRaidActive = true;

  RaidItemComponent? selectedItem;
  final List<RaidItemComponent> _activeRaidItems = [];

  @override
  Color backgroundColor() => const Color(0xFF141210);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = '';

    // 1. Gerçekçi Depo Arka Planı (Beton Zemin, Tuğla Duvar, Işık Huzmesi)
    _buildRealisticWarehouseEnvironment();

    // 2. Fiziksel Zemin ve Raflara Eşyaları Oturtma
    await _populatePhysicalItems();
  }

  /// Gerçekçi depo ortamı: Tuğla duvar, beton zemin ve ışık huzmesi
  void _buildRealisticWarehouseEnvironment() {
    final wallComponent = CustomPainterComponent(
      painter: _RealisticWarehousePainter(),
      size: size,
    );
    add(wallComponent);
  }

  /// Eşyaları havada süzülmeden, fiziksel zemin ve raf çizgilerine "ayak basacak" şekilde yerleştirir
  Future<void> _populatePhysicalItems() async {
    final w = size.x;
    final h = size.y;

    // 1. KATMAN 3: Arka Çelik Raf Üstü (Üst Seviye Y: h * 0.40)
    // Boyut: 60x60 px (Küçük / Değerli / Antika)
    // Anchor: Anchor.bottomCenter (Eşyanın altı raf çizgisine tam oturur)
    final l3 = storageUnit.layer3Items;
    final l3Spacing = w / (l3.length + 1);
    for (int i = 0; i < l3.length; i++) {
      final item = l3[i];
      Sprite? sprite;
      try {
        sprite = await loadSprite(item.spritePath);
      } catch (_) {}

      final comp = RaidItemComponent(
        itemModel: item,
        layer: 3,
        shadowOpacity: 1.0, // Zifiri karanlık
        position: Vector2((i + 1) * l3Spacing, h * 0.40),
        size: Vector2(62, 62),
        sprite: sprite,
        onSelected: _handleItemTap,
      );
      add(comp);
      _activeRaidItems.add(comp);
    }

    // 2. KATMAN 2: Orta Zemin Hattı (Orta Seviye Y: h * 0.65)
    // Boyut: 95x95 px (Kutular, Aletler, Elektronikler)
    // Anchor: Anchor.bottomCenter (Orta zemin hattına oturur)
    final l2 = storageUnit.layer2Items;
    final l2Spacing = w / (l2.length + 1);
    for (int i = 0; i < l2.length; i++) {
      final item = l2[i];
      Sprite? sprite;
      try {
        sprite = await loadSprite(item.spritePath);
      } catch (_) {}

      final comp = RaidItemComponent(
        itemModel: item,
        layer: 2,
        shadowOpacity: 0.75, // %75 koyu siluet
        position: Vector2((i + 1) * l2Spacing, h * 0.65),
        size: Vector2(95, 95),
        sprite: sprite,
        onSelected: _handleItemTap,
      );
      add(comp);
      _activeRaidItems.add(comp);
    }

    // 3. KATMAN 1: Ön Zemin Tabanı (En Yakın Y: h * 0.92)
    // Boyut: 135x135 px (Büyük Hacimli Koltuk, Buzdolabı, Jeneratör)
    // Anchor: Anchor.bottomCenter (Doğrudan beton zemine basar)
    final l1 = storageUnit.layer1Items;
    final l1Spacing = w / (l1.length + 1);
    for (int i = 0; i < l1.length; i++) {
      final item = l1[i];
      Sprite? sprite;
      try {
        sprite = await loadSprite(item.spritePath);
      } catch (_) {}

      final comp = RaidItemComponent(
        itemModel: item,
        layer: 1,
        shadowOpacity: 0.0, // Tamamen net
        position: Vector2((i + 1) * l1Spacing, h * 0.92),
        size: Vector2(135, 135),
        sprite: sprite,
        onSelected: _handleItemTap,
      );
      add(comp);
      _activeRaidItems.add(comp);
    }
  }

  void _handleItemTap(RaidItemComponent tappedItem) {
    if (!isRaidActive) return;

    if (selectedItem != null) {
      selectedItem!.unselect();
    }

    selectedItem = tappedItem;
    selectedItem!.select();
    onItemSelected(tappedItem);
  }

  /// Seçili eşya hurdaya ayrıldığında veya araca yüklendiğinde çağrılır
  void removeSelectedItem() {
    if (selectedItem == null) return;

    final removedLayer = selectedItem!.layer;
    _activeRaidItems.remove(selectedItem);
    selectedItem!.loot();
    selectedItem = null;

    // Kademeli aydınlanma
    for (final item in _activeRaidItems) {
      if (item.layer > removedLayer) {
        item.revealDepth();
      }
    }

    if (_activeRaidItems.isEmpty) {
      finishRaid();
    }
  }

  void clearSelection() {
    selectedItem?.unselect();
    selectedItem = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isRaidActive) return;

    _timerAcc += dt;
    if (_timerAcc >= 1.0) {
      _timerAcc = 0.0;
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        if (remainingSeconds.value <= 0) {
          finishRaid();
        }
      }
    }
  }

  void finishRaid() {
    if (!isRaidActive) return;
    isRaidActive = false;
    onRaidFinished();
  }

  List<ItemModel> getRemainingItems() {
    return _activeRaidItems.map((e) => e.itemModel).toList();
  }
}

/// Gerçekçi Endüstriyel Depo Arka Planı (Beton Zemin, Tuğla Duvar, Işık Huzmesi)
class _RealisticWarehousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Arka Tuğla / Metal Duvar (0 -> h * 0.65)
    final wallRect = Rect.fromLTWH(0, 0, w, h * 0.65);
    final wallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF28231E), Color(0xFF191613)],
      ).createShader(wallRect);
    canvas.drawRect(wallRect, wallPaint);

    // Tuğla derz çizgileri
    final brickLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.0;
    for (double y = 10; y < h * 0.65; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(w, y), brickLinePaint);
    }

    // 2. Arka Çelik Raf (Y: h * 0.40)
    final shelfRect = Rect.fromLTWH(0, h * 0.40, w, 8);
    final shelfPaint = Paint()..color = const Color(0xFF3E362E);
    canvas.drawRect(shelfRect, shelfPaint);
    // Raf destek kolonları
    final shelfLegPaint = Paint()..color = const Color(0xFF2B251F);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.40, 8, h * 0.25),
      shelfLegPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.75, h * 0.40, 8, h * 0.25),
      shelfLegPaint,
    );

    // 3. Perspektifli Beton Zemin (h * 0.65 -> h)
    final floorPath = Path()
      ..moveTo(0, h * 0.65)
      ..lineTo(w, h * 0.65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF201D1A), Color(0xFF0F0E0C)],
      ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.35));
    canvas.drawPath(floorPath, floorPaint);

    // 4. Sarı-Siyah Endüstriyel Tehlike Şeridi (Zemin Başlangıcı Y: h * 0.65)
    final hazardPaint = Paint()..strokeWidth = 3.0;
    for (double x = 0; x < w; x += 16) {
      hazardPaint.color = (x ~/ 16) % 2 == 0
          ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.5);
      canvas.drawLine(
        Offset(x, h * 0.65),
        Offset(x + 10, h * 0.65 + 6),
        hazardPaint,
      );
    }

    // 5. Tavandan Sarkan Endüstriyel Ampul ve Sıcak Işık Huzmesi
    final lightConePath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.9, h)
      ..lineTo(w * 0.1, h)
      ..close();

    final lightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -1),
        radius: 1.2,
        colors: [
          Colors.amber.withValues(alpha: 0.18),
          Colors.amber.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(lightConePath, lightPaint);

    // Lamba kablosu ve duy
    final cordPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, 20), cordPaint);
    final bulbPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(Offset(w * 0.5, 24), 5, bulbPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

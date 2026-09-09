import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/flame/components/raid_item_component.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/services/storage_generator_service.dart';

/// 2D Katmanlı Gerçekçi Depo Yağmalama Flame Sahnesi (ADR-019 & ADR-022)
/// 2D Katmanlı Gerçekçi Depo Yağmalama Flame Sahnesi (ADR-019 & ADR-022)
class StorageRaidGame extends FlameGame {
  final GeneratedStorageUnit storageUnit;
  final void Function(RaidItemComponent item)? onItemSelected;
  final VoidCallback? onRaidFinished;
  final bool isReadOnly;

  StorageRaidGame({
    required this.storageUnit,
    this.onItemSelected,
    this.onRaidFinished,
    this.isReadOnly = false,
  });

  /// Sıfır Jank için Flutter HUD ile paylaşılan sayaç
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(
    GameConstants.defaultRaidDurationSeconds,
  );

  double _timerAcc = 0.0;
  bool isRaidActive = true;
  bool isTimerPaused = true; // Araç sağdan gelip park edene kadar sayaç duraklatılır

  RaidItemComponent? selectedItem;
  final List<RaidItemComponent> _activeRaidItems = [];

  @override
  Color backgroundColor() => const Color(0xFF141210);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = '';

    if (isReadOnly) {
      isRaidActive = false;
      isTimerPaused = true;
    }

    // 1. Gerçekçi Depo Arka Planı (Beton Zemin, Tuğla Duvar, Işık Huzmesi)
    _buildRealisticWarehouseEnvironment();

    // 2. Fiziksel Zemin ve Raflara Eşyaları Oturtma
    await _populatePhysicalItems();
  }

  bool showDebugGrid = false;

  void toggleDebugGrid() {
    showDebugGrid = !showDebugGrid;
    for (final comp in _activeRaidItems) {
      comp.showDebugGrid = showDebugGrid;
    }
  }

  /// Gerçekçi depo ortamı: Tuğla duvar, beton zemin ve ışık huzmesi
  void _buildRealisticWarehouseEnvironment() {
    final wallComponent = CustomPainterComponent(
      painter: _RealisticWarehousePainter(game: this),
      size: size,
    );
    add(wallComponent);
  }

  /// Eşyaları gerçek fiziksel oda yüksekliği oranlarına (Buzdolabı: %60, Ketıl: %17, Kalem/Buji: %8)
  /// ve deponun perspektif zemin çizgilerine göre milimetrik oturtur.
  Future<void> _populatePhysicalItems() async {
    final w = size.x;
    final h = size.y;

    // Katman Zemin Taban Çizgileri (2.5D Derinlik Perspektifi)
    // anchor: Anchor.bottomCenter olduğundan tüm eşyaların tabanı bu çizgilere tam oturur.
    final l3GroundY = h * 0.80; // Arka Sıra (Perspektif olarak arkada ve yukarıda)
    final l2GroundY = h * 0.87; // Orta Sıra
    final l1GroundY = h * 0.94; // Ön Sıra (En önde ve aşağıda)

    // Eşya görsellerini asenkron ve güvenli yükleme yardımcı fonksiyonu
    Future<Sprite?> safeLoadItemSprite(ItemModel item) async {
      if (item.spritePath.isEmpty) return null;
      try {
        final fullPath = item.spritePath.startsWith('assets/')
            ? item.spritePath
            : 'assets/${item.spritePath}';
        return await loadSprite(fullPath).timeout(const Duration(milliseconds: 700));
      } catch (e) {
        debugPrint('Sprite yüklenemedi, yedek kart kullanılacak: ${item.code} ($e)');
        return null;
      }
    }

    // Ortak boyutlandırma motoru: Oda yüksekliği oranına göre yükseklik ve en-boy korumalı genişlik
    Vector2 calculateItemSize(ItemModel item, Sprite? sprite, double layerScaleMultiplier) {
      // roomHeightRatio: Buzdolabı ~0.62, Büyük TV ~0.40, Mikrodalga ~0.26, Ketıl ~0.17, Buji/Kalem ~0.08
      final targetH = (h * item.roomHeightRatio * layerScaleMultiplier).clamp(18.0, h * 0.75);

      double aspect = 1.0;
      if (sprite != null && sprite.srcSize.y > 0) {
        aspect = sprite.srcSize.x / sprite.srcSize.y;
      } else {
        aspect = item.width / item.height.toDouble();
      }
      aspect = aspect.clamp(0.4, 2.5);

      final targetW = (targetH * aspect).clamp(18.0, w * 0.65);
      return Vector2(targetW, targetH);
    }

    // 1. KATMAN 3: En Arka Sıra (Küçük & Mikro Eşyalar: Kalem, Buji, Külçe, Takı vb.)
    final l3 = storageUnit.layer3Items;
    final l3StartX = w * 0.20;
    final l3EndX = w * 0.80;
    final l3Spacing = (l3EndX - l3StartX) / (l3.length + 1);

    for (int i = 0; i < l3.length; i++) {
      final item = l3[i];
      final sprite = await safeLoadItemSprite(item);
      // Katman 3 için derinlik perspektif katsayısı: 0.85
      final itemSize = calculateItemSize(item, sprite, 0.85);

      final comp = RaidItemComponent(
        itemModel: item,
        layer: 3,
        shadowOpacity: isReadOnly ? 0.35 : 1.0,
        position: Vector2(l3StartX + (i + 1) * l3Spacing, l3GroundY),
        size: itemSize,
        sprite: sprite,
        onSelected: _handleItemTap,
      )..showDebugGrid = showDebugGrid;
      add(comp);
      _activeRaidItems.add(comp);
    }

    // 2. KATMAN 2: Orta Sıra (Orta & Küçük Eşyalar: Mikrodalga, Ketıl, Süpürge, Alet Çantası)
    final l2 = storageUnit.layer2Items;
    final l2StartX = w * 0.15;
    final l2EndX = w * 0.85;
    final l2Spacing = (l2EndX - l2StartX) / (l2.length + 1);

    for (int i = 0; i < l2.length; i++) {
      final item = l2[i];
      final sprite = await safeLoadItemSprite(item);
      // Katman 2 için derinlik perspektif katsayısı: 0.95
      final itemSize = calculateItemSize(item, sprite, 0.95);

      final comp = RaidItemComponent(
        itemModel: item,
        layer: 2,
        shadowOpacity: isReadOnly ? 0.18 : 0.75,
        position: Vector2(l2StartX + (i + 1) * l2Spacing, l2GroundY),
        size: itemSize,
        sprite: sprite,
        onSelected: _handleItemTap,
      )..showDebugGrid = showDebugGrid;
      add(comp);
      _activeRaidItems.add(comp);
    }

    // 3. KATMAN 1: En Ön Sıra (Mega & Büyük Parçalar: Buzdolabı, Kanepe, Dolap, V8 Motor)
    final l1 = storageUnit.layer1Items;
    final l1StartX = w * 0.10;
    final l1EndX = w * 0.90;
    final l1Spacing = (l1EndX - l1StartX) / (l1.length + 1);

    for (int i = 0; i < l1.length; i++) {
      final item = l1[i];
      final sprite = await safeLoadItemSprite(item);
      // Katman 1 için tam ön plan boyutu (katsayı: 1.05)
      final itemSize = calculateItemSize(item, sprite, 1.05);

      final comp = RaidItemComponent(
        itemModel: item,
        layer: 1,
        shadowOpacity: 0.0,
        position: Vector2(l1StartX + (i + 1) * l1Spacing, l1GroundY),
        size: itemSize,
        sprite: sprite,
        onSelected: _handleItemTap,
      )..showDebugGrid = showDebugGrid;
      add(comp);
      _activeRaidItems.add(comp);
    }
  }

  void _handleItemTap(RaidItemComponent tappedItem) {
    if (isReadOnly || !isRaidActive) return;

    if (selectedItem != null) {
      selectedItem!.unselect();
    }

    selectedItem = tappedItem;
    selectedItem!.select();
    onItemSelected?.call(tappedItem);
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
    if (!isRaidActive || isTimerPaused) return;

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

  void addExtraTime(int seconds) {
    remainingSeconds.value += seconds;
  }

  void finishRaid() {
    if (!isRaidActive) return;
    isRaidActive = false;
    onRaidFinished?.call();
  }

  List<ItemModel> getRemainingItems() {
    return _activeRaidItems.map((e) => e.itemModel).toList();
  }

  List<ItemModel> getAllActiveItemModels() {
    return _activeRaidItems.map((e) => e.itemModel).toList();
  }

  List<RaidItemComponent> getActiveComponents() {
    return List.unmodifiable(_activeRaidItems);
  }
}

/// Gerçekçi 3D Perspektif Depo Ortamı (Tavan, Yan Duvarlar, Arka Duvar, Beton Zemin ve Işık Huzmesi)
class _RealisticWarehousePainter extends CustomPainter {
  final StorageRaidGame? game;

  _RealisticWarehousePainter({this.game});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Tavan Bölgesi (Y: 0 -> h * 0.18)
    final ceilingRect = Rect.fromLTWH(0, 0, w, h * 0.20);
    final ceilingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF191715), Color(0xFF26221E)],
      ).createShader(ceilingRect);
    canvas.drawRect(ceilingRect, ceilingPaint);

    // Tavan çelik kirişleri
    final girderPaint = Paint()
      ..color = const Color(0xFF141210)
      ..strokeWidth = 3.0;
    canvas.drawLine(Offset(0, h * 0.08), Offset(w, h * 0.08), girderPaint);
    canvas.drawLine(Offset(0, h * 0.16), Offset(w, h * 0.16), girderPaint);

    // 2. Arka Tuğla / Sac Duvar (Y: h * 0.18 -> h * 0.62)
    final backWallRect = Rect.fromLTWH(w * 0.08, h * 0.18, w * 0.84, h * 0.44);
    final backWallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2A241F), Color(0xFF1B1713)],
      ).createShader(backWallRect);
    canvas.drawRect(backWallRect, backWallPaint);

    // Arka duvar tuğla/derz çizgileri
    final brickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    for (double y = h * 0.20; y < h * 0.62; y += 14) {
      canvas.drawLine(Offset(w * 0.08, y), Offset(w * 0.92, y), brickPaint);
    }

    // 3. Sol Yan Duvar (Perspektif)
    final leftWallPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.08, h * 0.18)
      ..lineTo(w * 0.08, h * 0.62)
      ..lineTo(0, h)
      ..close();
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [const Color(0xFF100E0C), const Color(0xFF221D18)],
      ).createShader(Rect.fromLTWH(0, 0, w * 0.08, h));
    canvas.drawPath(leftWallPath, leftWallPaint);

    // Sol Kepenk Rayı
    final railPaint = Paint()
      ..color = const Color(0xFF38322B)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(w * 0.075, h * 0.18), Offset(w * 0.075, h * 0.62), railPaint);

    // 4. Sağ Yan Duvar (Perspektif)
    final rightWallPath = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.92, h * 0.18)
      ..lineTo(w * 0.92, h * 0.62)
      ..lineTo(w, h)
      ..close();
    final rightWallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [const Color(0xFF100E0C), const Color(0xFF221D18)],
      ).createShader(Rect.fromLTWH(w * 0.92, 0, w * 0.08, h));
    canvas.drawPath(rightWallPath, rightWallPaint);

    // Sağ Kepenk Rayı
    canvas.drawLine(Offset(w * 0.925, h * 0.18), Offset(w * 0.925, h * 0.62), railPaint);

    // 5. Arka Çelik Raf (Y: h * 0.40)
    final shelfRect = Rect.fromLTWH(w * 0.08, h * 0.40, w * 0.84, 8);
    final shelfPaint = Paint()..color = const Color(0xFF3E362E);
    canvas.drawRect(shelfRect, shelfPaint);
    final shelfLegPaint = Paint()..color = const Color(0xFF2B251F);
    canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.40, 8, h * 0.22), shelfLegPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.72, h * 0.40, 8, h * 0.22), shelfLegPaint);

    // 6. Beton Zemin (Y: h * 0.62 -> h)
    final floorPath = Path()
      ..moveTo(0, h)
      ..lineTo(w * 0.08, h * 0.62)
      ..lineTo(w * 0.92, h * 0.62)
      ..lineTo(w, h)
      ..close();
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF24201C), Color(0xFF100F0D)],
      ).createShader(Rect.fromLTWH(0, h * 0.62, w, h * 0.38));
    canvas.drawPath(floorPath, floorPaint);

    // Zemin kılavuz çizgileri
    final floorGridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.30, h * 0.62), Offset(w * 0.20, h), floorGridPaint);
    canvas.drawLine(Offset(w * 0.50, h * 0.62), Offset(w * 0.50, h), floorGridPaint);
    canvas.drawLine(Offset(w * 0.70, h * 0.62), Offset(w * 0.80, h), floorGridPaint);

    // 7. Sarı-Siyah Endüstriyel Tehlike Şeridi (Zemin Başlangıcı Y: h * 0.62)
    final hazardPaint = Paint()..strokeWidth = 3.0;
    for (double x = 0; x < w; x += 16) {
      hazardPaint.color = (x ~/ 16) % 2 == 0
          ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.5);
      canvas.drawLine(
        Offset(x, h * 0.62),
        Offset(x + 10, h * 0.62 + 6),
        hazardPaint,
      );
    }

    // 8. Tavandan Sarkan Endüstriyel Ampul ve Sıcak Işık Huzmesi
    final lightConePath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.95, h)
      ..lineTo(w * 0.05, h)
      ..close();

    final lightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -1),
        radius: 1.2,
        colors: [
          Colors.amber.withValues(alpha: 0.20),
          Colors.amber.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(lightConePath, lightPaint);

    // Lamba kablosu ve duy
    final cordPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, 20), cordPaint);
    final bulbPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(Offset(w * 0.5, 24), 5, bulbPaint);

    // 9. DEBUG GRID MODU: 12 Sütun ve 3 Katman Derinlik Izgarası (Debug Modunda Görünür)
    if (game?.showDebugGrid == true) {
      final gridPaint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // 12 Dikey Sütun
      final colWidth = w / 12.0;
      for (int c = 0; c <= 12; c++) {
        final x = c * colWidth;
        canvas.drawLine(Offset(x, h * 0.62), Offset(x, h), gridPaint);
      }

      // 3 Yatay Katman Çizgisi
      final l3Y = h * 0.82;
      final l2Y = h * 0.88;
      final l1Y = h * 0.94;

      final layerPaint = Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawLine(Offset(0, l3Y), Offset(w, l3Y), layerPaint);
      canvas.drawLine(Offset(0, l2Y), Offset(w, l2Y), layerPaint);
      canvas.drawLine(Offset(0, l1Y), Offset(w, l1Y), layerPaint);

      final tp = TextPainter(
        text: const TextSpan(
          text: '📐 DEPO IZGARASI (12 SÜTUN x 3 KATMAN DERİNLİK)',
          style: TextStyle(color: Colors.cyanAccent, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(10, h * 0.63));
    }
  }

  @override
  bool shouldRepaint(covariant _RealisticWarehousePainter oldDelegate) {
    return oldDelegate.game?.showDebugGrid != game?.showDebugGrid;
  }
}

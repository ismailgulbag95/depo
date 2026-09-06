import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';

/// Depo Sahnesindeki 2D Katmanlı Eşya Bileşeni
class RaidItemComponent extends SpriteComponent with TapCallbacks {
  final ItemModel itemModel;
  final int layer; // 1: Ön Plan, 2: Orta Plan, 3: Arka Plan
  final void Function(RaidItemComponent item) onSelected;

  // Kademeli gölge opaklığı: 0.0: Tam net, 0.75: Koyu siluet, 1.0: Tam karanlık
  double shadowOpacity;
  bool isSelected = false;
  bool isLooted = false;

  late final Paint _shadowPaint;

  RaidItemComponent({
    required this.itemModel,
    required this.layer,
    required this.onSelected,
    required super.position,
    required super.size,
    super.sprite,
    this.shadowOpacity = 0.0,
  }) : super(anchor: Anchor.bottomCenter) {
    // Katman sırasına göre render önceliği (Priority)
    // Katman 1 (Ön): 30, Katman 2 (Orta): 20, Katman 3 (Arka): 10
    priority = (4 - layer) * 10;
    _shadowPaint = Paint()..color = Colors.black;
  }

  @override
  void render(Canvas canvas) {
    if (isLooted) return;

    // 1. Eğer sprite henüz yoksa veya yüklenemediyse şık bir yedek kart çiz
    if (sprite == null) {
      final placeholderPaint = Paint()..color = const Color(0xFF3A352F);
      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
        placeholderPaint,
      );
    } else {
      super.render(canvas);
    }

    // 2. Kademeli gölge maskesi çiz (%0, %75 veya %100)
    if (shadowOpacity > 0.0) {
      _shadowPaint.color = Colors.black.withValues(alpha: shadowOpacity.clamp(0.0, 1.0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
        _shadowPaint,
      );
    }

    // 3. Seçiliyse etrafına parlak cam neon çerçeve çiz
    if (isSelected) {
      final borderPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect().inflate(2), const Radius.circular(8)),
        borderPaint,
      );
    }

    // 4. Debug Grid Modu Açıksa: Izgara Bounding Box & Boyut Etiketi Çiz
    if (showDebugGrid) {
      final debugPaint = Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRect(size.toRect(), debugPaint);

      final textSpan = TextSpan(
        text: '${itemModel.width}x${itemModel.height} [L$layer]',
        style: const TextStyle(
          color: Colors.amberAccent,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black87,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, const Offset(2, -12));
    }
  }

  bool showDebugGrid = false;

  void select() {
    isSelected = true;
  }

  void unselect() {
    isSelected = false;
  }

  void loot() {
    isLooted = true;
    removeFromParent();
  }

  void revealDepth() {
    if (shadowOpacity >= 1.0) {
      shadowOpacity = 0.75;
    } else if (shadowOpacity > 0.0) {
      shadowOpacity = 0.0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!isLooted) {
      onSelected(this);
    }
  }
}

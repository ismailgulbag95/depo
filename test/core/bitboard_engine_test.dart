import 'package:flutter_test/flutter_test.dart';
import 'package:yeni_oyun_sablon/core/utils/bitboard_engine.dart';

void main() {
  group('BitboardEngine Birim Testleri', () {
    const int gridW = 8;
    const int gridH = 12;

    test('Boş ızgaraya geçerli bir eşya yerleştirilebilmeli', () {
      final emptyGrid = BitboardEngine.createEmptyGrid(gridH);
      // 2x2 kare: [3, 3] (ikilikte 11 ve 11)
      final squareItem = [3, 3];

      final canPlace = BitboardEngine.canPlace(
        gridRows: emptyGrid,
        itemMask: squareItem,
        startX: 0,
        startY: 0,
        gridWidth: gridW,
        gridHeight: gridH,
      );

      expect(canPlace, isTrue);
    });

    test('Izgara sınırlarını aşan yerleşimler engellenmeli', () {
      final emptyGrid = BitboardEngine.createEmptyGrid(gridH);
      final squareItem = [3, 3]; // 2x2

      // Sağdan taşma: startX = 7, genişlik 2 -> 7 + 2 = 9 > 8
      final overflowRight = BitboardEngine.canPlace(
        gridRows: emptyGrid,
        itemMask: squareItem,
        startX: 7,
        startY: 0,
        gridWidth: gridW,
        gridHeight: gridH,
      );
      expect(overflowRight, isFalse);

      // Alttan taşma: startY = 11, yükseklik 2 -> 11 + 2 = 13 > 12
      final overflowBottom = BitboardEngine.canPlace(
        gridRows: emptyGrid,
        itemMask: squareItem,
        startX: 0,
        startY: 11,
        gridWidth: gridW,
        gridHeight: gridH,
      );
      expect(overflowBottom, isFalse);

      // Negatif koordinat
      final negativeCoord = BitboardEngine.canPlace(
        gridRows: emptyGrid,
        itemMask: squareItem,
        startX: -1,
        startY: 0,
        gridWidth: gridW,
        gridHeight: gridH,
      );
      expect(negativeCoord, isFalse);
    });

    test('Üst üste binen eşyalarda çakışma (Collision) tespit edilmeli', () {
      var grid = BitboardEngine.createEmptyGrid(gridH);
      final itemA = [3, 3]; // 2x2 kare

      // İlk eşyayı (0, 0)'a koyuyoruz
      grid = BitboardEngine.placeItem(
        gridRows: grid,
        itemMask: itemA,
        startX: 0,
        startY: 0,
      );

      // İkinci eşyayı (1, 1)'e koymaya çalışıyoruz (Kısmi çakışma)
      final canPlaceCollision = BitboardEngine.canPlace(
        gridRows: grid,
        itemMask: itemA,
        startX: 1,
        startY: 1,
        gridWidth: gridW,
        gridHeight: gridH,
      );
      expect(canPlaceCollision, isFalse);

      // İkinci eşyayı (2, 0)'a koymaya çalışıyoruz (Bitişik ama çakışma yok)
      final canPlaceAdjacent = BitboardEngine.canPlace(
        gridRows: grid,
        itemMask: itemA,
        startX: 2,
        startY: 0,
        gridWidth: gridW,
        gridHeight: gridH,
      );
      expect(canPlaceAdjacent, isTrue);
    });

    test('Eşya yerleştirme ve kaldırma (place & remove) simetrik çalışmalı', () {
      final emptyGrid = BitboardEngine.createEmptyGrid(gridH);
      final item = [7]; // 1x3 yatay çubuk (111_2)

      // Eşyayı yerleştir
      final placedGrid = BitboardEngine.placeItem(
        gridRows: emptyGrid,
        itemMask: item,
        startX: 2,
        startY: 3,
      );
      expect(placedGrid[3], equals(7 << 2)); // 28

      // Eşyayı geri kaldır
      final restoredGrid = BitboardEngine.removeItem(
        gridRows: placedGrid,
        itemMask: item,
        startX: 2,
        startY: 3,
      );

      // Izgara ilk boş haline dönmeli
      expect(restoredGrid, equals(emptyGrid));
    });

    test('Polyomino 90 derece döndürme matematiği doğru çalışmalı', () {
      // 2x1 yatay çubuk: [3] -> W=2, H=1
      final barHorizontal = [3];
      final barVertical = BitboardEngine.rotate90(
        shape: barHorizontal,
        originalW: 2,
        originalH: 1,
      );

      // Beklenen dikey çubuk: W=1, H=2 -> [1, 1]
      expect(barVertical, equals([1, 1]));

      // 4 kez 90 derece döndürüldüğünde (360 derece) ilk haline dönmeli
      var shape = [1, 1, 3]; // L-bloğu (W=2, H=3)
      var currentW = 2;
      var currentH = 3;

      for (int i = 0; i < 4; i++) {
        shape = BitboardEngine.rotate90(
          shape: shape,
          originalW: currentW,
          originalH: currentH,
        );
        final temp = currentW;
        currentW = currentH;
        currentH = temp;
      }

      expect(shape, equals([1, 1, 3]));
      expect(currentW, equals(2));
      expect(currentH, equals(3));
    });

    test('calculateBounds doğru boyutları hesaplamalı', () {
      // L-bloğu: Satır 0: 1, Satır 1: 1, Satır 2: 3
      final lShape = [1, 1, 3];
      final bounds = BitboardEngine.calculateBounds(lShape);

      expect(bounds.width, equals(2));
      expect(bounds.height, equals(3));
    });
  });
}

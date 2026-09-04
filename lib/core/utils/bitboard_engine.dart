import 'dart:math';

/// 64-Bit Bitboard Polyomino Matematik Motoru
///
/// Izgara üzerindeki her satırı 64-bit bir tamsayı bit maskesi olarak tutar.
/// Çarpışma kontrollerini O(1) sürede bitwise AND (&) işlemi ile gerçekleştirir.
class BitboardEngine {
  /// Boş bir ızgara satır listesi oluşturur
  static List<int> createEmptyGrid(int height) {
    return List<int>.filled(height, 0);
  }

  /// Eşyanın verilen koordinata yerleştirilip yerleştirilemeyeceğini O(1) sürede kontrol eder
  static bool canPlace({
    required List<int> gridRows,
    required List<int> itemMask,
    required int startX,
    required int startY,
    required int gridWidth,
    required int gridHeight,
  }) {
    // Negatif koordinat kontrolü
    if (startX < 0 || startY < 0) return false;

    final itemHeight = itemMask.length;
    // Yükseklik sınırı aşımı kontrolü
    if (startY + itemHeight > gridHeight) return false;
    if (startY + itemHeight > gridRows.length) return false;

    // Satır taşma maskesi (gridWidth genişliğindeki alana uymayan bitler)
    // Örnek: gridWidth = 8 ise geçerli alan (1 << 8) - 1 = 255.
    final int validAreaMask = gridWidth >= 64 ? -1 : ((1 << gridWidth) - 1);

    for (int r = 0; r < itemHeight; r++) {
      final rowMask = itemMask[r];
      if (rowMask == 0) continue; // Boş satır kontrolü atla

      // Eşyanın en sağındaki bit koordinatı grid sınırını aşıyor mu?
      final shiftedMask = rowMask << startX;

      // 1. Genişlik sınırı aşımı kontrolü:
      if (gridWidth < 64) {
        if ((shiftedMask & ~validAreaMask) != 0 || shiftedMask < 0) {
          return false;
        }
      }

      // 2. Çarpışma kontrolü:
      // (GridRow & ShiftedItemMask) != 0 ise o hücrede zaten başka bir eşya vardır
      if ((gridRows[startY + r] & shiftedMask) != 0) {
        return false;
      }
    }

    return true;
  }

  /// Eşyayı ızgaraya yerleştirir ve güncellenmiş yeni ızgara satırlarını döndürür
  static List<int> placeItem({
    required List<int> gridRows,
    required List<int> itemMask,
    required int startX,
    required int startY,
  }) {
    final newGrid = List<int>.from(gridRows);
    for (int r = 0; r < itemMask.length; r++) {
      if (startY + r < newGrid.length) {
        newGrid[startY + r] |= (itemMask[r] << startX);
      }
    }
    return newGrid;
  }

  /// Eşyayı ızgaradan kaldırır (Hücreleri boşaltır) ve güncellenmiş ızgarayı döndürür
  static List<int> removeItem({
    required List<int> gridRows,
    required List<int> itemMask,
    required int startX,
    required int startY,
  }) {
    final newGrid = List<int>.from(gridRows);
    for (int r = 0; r < itemMask.length; r++) {
      if (startY + r < newGrid.length) {
        newGrid[startY + r] &= ~(itemMask[r] << startX);
      }
    }
    return newGrid;
  }

  /// Polyomino şeklini saat yönünde 90 derece döndürür
  ///
  /// [originalW]: Döndürülmeden önceki genişlik
  /// [originalH]: Döndürülmeden önceki yükseklik
  /// Döndürme sonucu: Yeni genişlik = originalH, Yeni yükseklik = originalW
  static List<int> rotate90({
    required List<int> shape,
    required int originalW,
    required int originalH,
  }) {
    final List<int> rotated = List<int>.filled(originalW, 0);

    for (int r = 0; r < originalH; r++) {
      for (int c = 0; c < originalW; c++) {
        // Eğer orijinal şekilde (r, c) hücresi doluysa (bit 1 ise)
        if ((shape[r] & (1 << c)) != 0) {
          final newR = c;
          final newC = originalH - 1 - r;
          rotated[newR] |= (1 << newC);
        }
      }
    }

    return rotated;
  }

  /// Şeklin satır maskelerinden gerçek genişlik ve yüksekliğini hesaplar
  static ({int width, int height}) calculateBounds(List<int> shape) {
    int maxBit = 0;
    int effectiveHeight = 0;

    for (int r = 0; r < shape.length; r++) {
      final mask = shape[r];
      if (mask > 0) {
        effectiveHeight = max(effectiveHeight, r + 1);
        int temp = mask;
        int bitCount = 0;
        while (temp > 0) {
          bitCount++;
          temp >>= 1;
        }
        maxBit = max(maxBit, bitCount);
      }
    }

    return (width: maxBit, height: effectiveHeight);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/utils/bitboard_engine.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

/// Araç Bagajı Polyomino Grid Widget'ı ve İleri Etkileşimler (ADR-023, ADR-024, ADR-026)
class TrunkGridWidget extends ConsumerStatefulWidget {
  final ItemModel? activeDragItem;
  final int activeRotation;
  final VoidCallback? onTransportCalled;
  final Function(int x, int y)? onItemPickedFromTrunk;
  final VoidCallback? onItemPlaced;

  const TrunkGridWidget({
    super.key,
    this.activeDragItem,
    this.activeRotation = 0,
    this.onTransportCalled,
    this.onItemPickedFromTrunk,
    this.onItemPlaced,
  });

  @override
  ConsumerState<TrunkGridWidget> createState() => _TrunkGridWidgetState();
}

class _TrunkGridWidgetState extends ConsumerState<TrunkGridWidget> {
  int _vehicleVisualKey = 0; // Hızlı araç değişim animasyonunu tetikler
  int? _hoveredStartX;
  int? _hoveredStartY;

  /// "Nakliye Çağır" butonuna basıldığında mevcut aracı hızla kaydırıp yeni aracı geri geri yanaştırır
  void _handleCallTransport() {
    setState(() {
      _vehicleVisualKey++;
      _hoveredStartX = null;
      _hoveredStartY = null;
    });

    // Bagajı yeni boş nakliye aracı olarak temizle
    ref.read(trunkInventoryProvider.notifier).clearTrunk();

    widget.onTransportCalled?.call();
  }

  /// Rotasyon uygulanmış bitmask döndürür
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

  /// Eşyanın kaplayacağı tüm ızgara hücre indekslerini hesaplar
  Set<int> _getCoveredIndices(int startX, int startY, List<int> mask, int gridWidth, int gridHeight) {
    final set = <int>{};
    for (int r = 0; r < mask.length; r++) {
      final rowMask = mask[r];
      for (int c = 0; c < 32; c++) {
        if ((rowMask & (1 << c)) != 0) {
          final cellX = startX + c;
          final cellY = startY + r;
          if (cellX >= 0 && cellX < gridWidth && cellY >= 0 && cellY < gridHeight) {
            set.add(cellY * gridWidth + cellX);
          }
        }
      }
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    final trunkState = ref.watch(trunkInventoryProvider);

    // Hoşgörülü ağırlık oranı
    final weightRatio = (trunkState.currentWeightKg / trunkState.maxWeightKg).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: GameColors.panelBorder, width: 2)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: Column(
        children: [
          // 1. Üst Bilgi Başlığı: Araç Adı, Hoşgörülü Ağırlık Barı ve Nakliye Çağır Butonu
          Row(
            children: [
              // Araç Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GameColors.panelDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GameColors.panelBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: GameColors.gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      trunkState.vehicleName.toUpperCase(),
                      style: GameTypography.display(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Ağırlık Göstergesi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YÜK / KAPASİTE',
                          style: GameTypography.body(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${trunkState.currentWeightKg.toStringAsFixed(0)} / ${trunkState.maxWeightKg.toStringAsFixed(0)} kg',
                          style: GameTypography.led(
                            color: weightRatio > 0.85 ? GameColors.lossRed : GameColors.goldLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: weightRatio,
                        minHeight: 5,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          weightRatio > 0.85
                              ? GameColors.lossRed
                              : weightRatio > 0.6
                                  ? GameColors.hazardYellow
                                  : GameColors.profitGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Hızlı Nakliye Çağır Butonu
              ArcadeButton(
                text: 'NAKLİYE (+350 ₺)',
                icon: Icons.add_business_outlined,
                onPressed: _handleCallTransport,
                primaryColor: GameColors.alertOrange,
                shadowColor: const Color(0xFFB24800),
                textColor: Colors.black,
                height: 34,
                fontSize: 9,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. Hızlı Animasyonlu Araç Bagaj Izgarası (Slide-Out / Slide-In: 400ms)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final inAnimation = Tween<Offset>(
                  begin: const Offset(1.2, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                return SlideTransition(position: inAnimation, child: child);
              },
              child: DiegeticMetalPanel(
                key: ValueKey<int>(_vehicleVisualKey),
                padding: const EdgeInsets.all(6),
                showRivets: true,
                backgroundColor: const Color(0xFF16171D),
                borderColor: GameColors.panelBorder,
                child: _buildGridCells(trunkState),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 8x12 veya 12x16 araç bagajı hücrelerini çizer
  Widget _buildGridCells(TrunkInventoryState trunkState) {
    final trunkBgPath = GameAssetPaths.getTrunkBackground(trunkState.vehicleName);
    final activeItem = widget.activeDragItem;
    final activeMask = activeItem != null
        ? _getRotatedMask(activeItem.bitmask, activeItem.width, activeItem.height, widget.activeRotation)
        : null;

    final coveredIndices = (_hoveredStartX != null && _hoveredStartY != null && activeMask != null)
        ? _getCoveredIndices(_hoveredStartX!, _hoveredStartY!, activeMask, trunkState.gridWidth, trunkState.gridHeight)
        : const <int>{};

    final isPlacementValid = (_hoveredStartX != null && _hoveredStartY != null && activeItem != null)
        ? ref.read(trunkInventoryProvider.notifier).canPlaceItem(
            item: activeItem,
            startX: _hoveredStartX!,
            startY: _hoveredStartY!,
            rotation: widget.activeRotation,
          )
        : false;

    final isPickup = trunkState.vehicleName.toLowerCase().contains('pikap') ||
        trunkState.vehicleName.toLowerCase().contains('pickup') ||
        trunkBgPath.contains('pickup');

    return LayoutBuilder(
      builder: (context, constraints) {
        // 16:9 Araç Kadrajı Oranlama
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;

        double carW, carH;
        if (isPickup) {
          // 16:9 pikap aracı orantısı
          if (maxW / maxH > 16 / 9) {
            carH = maxH;
            carW = carH * (16 / 9);
          } else {
            carW = maxW;
            carH = carW * (9 / 16);
          }
        } else {
          final cellW = maxW / trunkState.gridWidth;
          final cellH = maxH / trunkState.gridHeight;
          final cellSize = cellW < cellH ? cellW : cellH;
          carW = cellSize * trunkState.gridWidth + 12;
          carH = cellSize * trunkState.gridHeight + 12;
        }

        // Pikap kasa iç havuzu oranları (16:9 görsel koordinatları)
        final bedLeft = isPickup ? carW * 0.090 : 6.0;
        final bedTop = isPickup ? carH * 0.228 : 6.0;
        final bedWidth = isPickup ? carW * 0.358 : (carW - 12);
        final bedHeight = isPickup ? carH * 0.544 : (carH - 12);

        // Kasa içi 10x6 hücrelerin en/boy oranı
        final cellAspectRatio = (bedWidth / trunkState.gridWidth) / (bedHeight / trunkState.gridHeight);

        return Center(
          child: Container(
            width: carW,
            height: carH,
            decoration: BoxDecoration(
              color: const Color(0xFF14151B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF383A48), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Kuşbakışı Araç Görseli (Pikapta tüm araç: kasa solda, kabin sağda)
                  Image.asset(
                    trunkBgPath,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF181715),
                    ),
                  ),

                  // 2. Kasa Alanı Üzerine Yedirilen Polyomino Izgara Hücreleri
                  Positioned(
                    left: bedLeft,
                    top: bedTop,
                    width: bedWidth,
                    height: bedHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isPickup ? GameColors.gold.withValues(alpha: 0.35) : Colors.transparent,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: isPickup ? Colors.black.withValues(alpha: 0.20) : Colors.transparent,
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: trunkState.gridWidth * trunkState.gridHeight,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: trunkState.gridWidth,
                          childAspectRatio: cellAspectRatio,
                        ),
                    itemBuilder: (context, index) {
                      final x = index % trunkState.gridWidth;
                      final y = index ~/ trunkState.gridWidth;

                      // Bitboard satırından o hücrenin dolu olup olmadığını kontrol et
                      final isOccupied = y < trunkState.gridRows.length &&
                          (trunkState.gridRows[y] & (1 << x)) != 0;

                      final isHoveredFootprint = coveredIndices.contains(index);

                      Color cellColor = isOccupied
                          ? GameColors.profitGreen.withValues(alpha: 0.85) // Dolu hücre
                          : Colors.black.withValues(alpha: 0.32); // Boş hücre (Kasa zeminini gösterir)

                      Color borderColor = isOccupied
                          ? Colors.white54
                          : Colors.white.withValues(alpha: 0.04);
                      double borderWidth = 0.8;
                      List<BoxShadow>? cellShadow;

                      // Sürükleme veya üzerine gelme sırasında tam kapsanan ızgara footprint görseli
                      if (isHoveredFootprint) {
                        if (isPlacementValid) {
                          cellColor = GameColors.neonCyan.withValues(alpha: 0.80);
                          borderColor = GameColors.neonCyan;
                          borderWidth = 2.0;
                          cellShadow = [
                            BoxShadow(
                              color: GameColors.neonCyan.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ];
                        } else {
                          cellColor = GameColors.lossRed.withValues(alpha: 0.80);
                          borderColor = GameColors.lossRed;
                          borderWidth = 2.0;
                          cellShadow = [
                            BoxShadow(
                              color: GameColors.lossRed.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ];
                        }
                      }

                      return DragTarget<ItemModel>(
                        onWillAcceptWithDetails: (details) {
                          setState(() {
                            _hoveredStartX = x;
                            _hoveredStartY = y;
                          });
                          return true;
                        },
                        onMove: (details) {
                          if (_hoveredStartX != x || _hoveredStartY != y) {
                            setState(() {
                              _hoveredStartX = x;
                              _hoveredStartY = y;
                            });
                          }
                        },
                        onLeave: (data) {
                          if (_hoveredStartX == x && _hoveredStartY == y) {
                            setState(() {
                              _hoveredStartX = null;
                              _hoveredStartY = null;
                            });
                          }
                        },
                        onAcceptWithDetails: (details) {
                          final item = details.data;
                          setState(() {
                            _hoveredStartX = null;
                            _hoveredStartY = null;
                          });

                          final canPlace = ref.read(trunkInventoryProvider.notifier).canPlaceItem(
                                item: item,
                                startX: x,
                                startY: y,
                                rotation: widget.activeRotation,
                              );

                          if (canPlace) {
                            HapticFeedback.heavyImpact();
                            ref.read(trunkInventoryProvider.notifier).placeItem(
                                  item: item,
                                  startX: x,
                                  startY: y,
                                  rotation: widget.activeRotation,
                                );
                            widget.onItemPlaced?.call();
                          } else {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bu hücreye sığmıyor veya çakışıyor! 90° döndürün veya başka hücre deneyin.'),
                                backgroundColor: GameColors.alertOrange,
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return GestureDetector(
                            onTap: () {
                              // Eğer hücre doluysa eşyayı yerinden kaldır ve seçili yap
                              if (isOccupied) {
                                widget.onItemPickedFromTrunk?.call(x, y);
                              } else if (widget.activeDragItem != null) {
                                // Boş hücreye dokunarak yerleştirme
                                final canPlace = ref.read(trunkInventoryProvider.notifier).canPlaceItem(
                                      item: widget.activeDragItem!,
                                      startX: x,
                                      startY: y,
                                      rotation: widget.activeRotation,
                                    );
                                if (canPlace) {
                                  HapticFeedback.mediumImpact();
                                  ref.read(trunkInventoryProvider.notifier).placeItem(
                                        item: widget.activeDragItem!,
                                        startX: x,
                                        startY: y,
                                        rotation: widget.activeRotation,
                                      );
                                  widget.onItemPlaced?.call();
                                } else {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bu hücreye sığmıyor veya çakışıyor! 90° döndürün veya başka bir hücre deneyin.'),
                                      backgroundColor: GameColors.alertOrange,
                                      duration: Duration(milliseconds: 1500),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1.2),
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: borderColor,
                                  width: borderWidth,
                                ),
                                boxShadow: cellShadow,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
            ),
          ),
        );
      },
    );
  }
}


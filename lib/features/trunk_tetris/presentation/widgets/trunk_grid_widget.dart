import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

/// Araç Bagajı Polyomino Grid Widget'ı ve İleri Etkileşimler (ADR-023, ADR-024, ADR-026)
class TrunkGridWidget extends ConsumerStatefulWidget {
  final ItemModel? activeDragItem;
  final int activeRotation;
  final VoidCallback? onTransportCalled;
  final Function(int x, int y)? onItemPickedFromTrunk;

  const TrunkGridWidget({
    super.key,
    this.activeDragItem,
    this.activeRotation = 0,
    this.onTransportCalled,
    this.onItemPickedFromTrunk,
  });

  @override
  ConsumerState<TrunkGridWidget> createState() => _TrunkGridWidgetState();
}

class _TrunkGridWidgetState extends ConsumerState<TrunkGridWidget> {
  int _vehicleVisualKey = 0; // Hızlı araç değişim animasyonunu tetikler

  /// "Nakliye Çağır" butonuna basıldığında mevcut aracı hızla kaydırıp yeni aracı geri geri yanaştırır
  void _handleCallTransport() {
    setState(() {
      _vehicleVisualKey++;
    });

    // Bagajı yeni boş nakliye aracı olarak temizle
    ref.read(trunkInventoryProvider.notifier).clearTrunk();

    widget.onTransportCalled?.call();
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = constraints.maxWidth / trunkState.gridWidth;
        final cellH = constraints.maxHeight / trunkState.gridHeight;
        final cellSize = cellW < cellH ? cellW : cellH;

        return Center(
          child: Container(
            width: cellSize * trunkState.gridWidth,
            height: cellSize * trunkState.gridHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameColors.panelBorder, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Dinamik Kasa / Konteyner Zemin Görseli
                  Image.asset(
                    trunkBgPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF191B22),
                    ),
                  ),

                  // Kasa Zemin Karartma Maskesi (Hücre kontrastı için)
                  Container(
                    color: Colors.black.withValues(alpha: 0.38),
                  ),

                  // 2. Polyomino Izgara Hücreleri
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trunkState.gridWidth * trunkState.gridHeight,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: trunkState.gridWidth,
                    ),
                    itemBuilder: (context, index) {
                      final x = index % trunkState.gridWidth;
                      final y = index ~/ trunkState.gridWidth;

                      // Bitboard satırından o hücrenin dolu olup olmadığını kontrol et
                      final isOccupied = y < trunkState.gridRows.length &&
                          (trunkState.gridRows[y] & (1 << x)) != 0;

                      return DragTarget<ItemModel>(
                        onWillAcceptWithDetails: (details) {
                          final item = details.data;
                          return ref.read(trunkInventoryProvider.notifier).canPlaceItem(
                                item: item,
                                startX: x,
                                startY: y,
                                rotation: widget.activeRotation,
                              );
                        },
                        onAcceptWithDetails: (details) {
                          final item = details.data;
                          HapticFeedback.heavyImpact();
                          ref.read(trunkInventoryProvider.notifier).placeItem(
                                item: item,
                                startX: x,
                                startY: y,
                                rotation: widget.activeRotation,
                              );
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHoverValid = candidateData.isNotEmpty;
                          final isHoverInvalid = rejectedData.isNotEmpty;

                          Color cellColor = isOccupied
                              ? GameColors.profitGreen.withValues(alpha: 0.85) // Dolu hücre
                              : Colors.black.withValues(alpha: 0.32); // Boş hücre (Kasa zeminini gösterir)

                          if (isHoverValid) {
                            cellColor = GameColors.neonCyan.withValues(alpha: 0.75); // Yeşil snap
                          } else if (isHoverInvalid) {
                            cellColor = GameColors.lossRed.withValues(alpha: 0.75); // Kırmızı çakışma
                          }

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
                                } else {
                                  HapticFeedback.lightImpact();
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1.2),
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: isOccupied
                                      ? Colors.white54
                                      : isHoverValid
                                          ? GameColors.neonCyan
                                          : Colors.white.withValues(alpha: 0.04),
                                  width: isHoverValid || isHoverInvalid ? 1.5 : 0.8,
                                ),
                                boxShadow: isHoverValid
                                    ? [
                                        BoxShadow(
                                          color: GameColors.neonCyan.withValues(alpha: 0.4),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        },
                      );
                    },
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

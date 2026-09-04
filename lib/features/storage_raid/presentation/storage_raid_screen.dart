import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/localization/localization_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/crafting_benches/presentation/crafting_bench_screen.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/flame/components/raid_item_component.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/flame/storage_raid_game.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/presentation/widgets/raid_summary_sheet.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/services/storage_generator_service.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/presentation/widgets/trunk_grid_widget.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

/// Dikey Hibrit Depo Yağmalama ve Bagaj Yerleşim Ekranı (ADR-013, ADR-014, ADR-023, ADR-024)
class StorageRaidScreen extends ConsumerStatefulWidget {
  final GeneratedStorageUnit? storageUnit;

  const StorageRaidScreen({super.key, this.storageUnit});

  @override
  ConsumerState<StorageRaidScreen> createState() => _StorageRaidScreenState();
}

class _StorageRaidScreenState extends ConsumerState<StorageRaidScreen> {
  StorageRaidGame? _game;
  GeneratedStorageUnit? _activeUnit;
  bool _isLoading = true;

  ItemModel? _inspectedItem;
  int _itemRotation = 0; // 0, 90, 180, 270
  int _totalScrapIncome = 0;
  int _transportCallsCount = 0;
  static const int transportCallCost = 350; // Her ek nakliye çağırma bedeli

  @override
  void initState() {
    super.initState();
    _initRaidGame();
  }

  Future<void> _initRaidGame() async {
    _activeUnit = widget.storageUnit ?? await StorageGeneratorService.instance.generateRandomUnit();

    _game = StorageRaidGame(
      storageUnit: _activeUnit!,
      onItemSelected: (RaidItemComponent comp) {
        setState(() {
          _inspectedItem = comp.itemModel;
          _itemRotation = 0;
        });
      },
      onRaidFinished: _handleRaidFinished,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 90 Derece Döndürme (Buton veya Çift Dokunma)
  void _handleRotateItem() {
    if (_inspectedItem == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _itemRotation = (_itemRotation + 90) % 360;
    });
  }

  /// Bagaj ızgarasından bir eşyaya tıklandığında eşyayı havaya kaldırır (seçili yapar)
  Future<void> _handlePopItemFromTrunk(int x, int y) async {
    final result = await ref.read(trunkInventoryProvider.notifier).popItemAt(x, y);
    if (result != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _inspectedItem = result.item;
        _itemRotation = result.rotation;
      });
    }
  }

  /// "HURDA" seçildiğinde eşya hurdaya ayrılır (%20 değer arka planda hesaplanır)
  void _handleScrapItem() {
    if (_inspectedItem == null) return;

    final scrapValue = (_inspectedItem!.baseValue * 0.20).round();
    _totalScrapIncome += scrapValue;

    // Oyuncunun profiline parayı hemen ekle
    ref.read(playerProfileProvider.notifier).addCash(scrapValue);

    // Flame sahnesinden eşyayı kaldır ve arkadaki gölgeleri aç
    _game?.removeSelectedItem();

    setState(() {
      _inspectedItem = null;
      _itemRotation = 0;
    });
  }

  /// "ARACA YÜKLE" seçildiğinde eşya bagaj ızgarasına sığdırılmaya çalışılır
  Future<void> _handleLoadToVehicle() async {
    if (_inspectedItem == null) return;

    final trunkNotifier = ref.read(trunkInventoryProvider.notifier);
    final placed = await trunkNotifier.autoPlaceItem(_inspectedItem!);

    if (placed) {
      // Eşya başarıyla bagaja girdi, depodan kaldır
      _game?.removeSelectedItem();
      HapticFeedback.mediumImpact();
      setState(() {
        _inspectedItem = null;
        _itemRotation = 0;
      });
    } else {
      // Bagaja sığmadı veya aşırı ağır!
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bagaja sığmadı veya aşırı ağır! Döndürmeyi deneyin, nakliye çağırın veya hurdaya ayırın.',
            style: GameTypography.body(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: GameColors.alertOrange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// "NAKLİYE ÇAĞIR" butonu tıklandığında araç değişir ve 350 ₺ masraf yazılır
  void _handleTransportCalled() {
    _transportCallsCount++;
  }

  /// Raid bittiğinde resmî ihale tasfiye faturasını (RaidSummarySheet) aç
  void _handleRaidFinished() {
    if (_game == null) return;

    final remainingItems = _game!.getRemainingItems();
    final trunkState = ref.read(trunkInventoryProvider);
    final loadedItems = trunkState.placedItems;
    final isMasterPacker = trunkState.isMasterPacker;

    // Usta İstifçi ödülü: %80+ dolulukta 150 İtibar (XP) verilir
    if (isMasterPacker) {
      ref.read(playerProfileProvider.notifier).addReputation(150);
    }

    // Temizlik cezası: Kalan her eşya için taban değerinin %25'i fatura edilir
    int cleaningFine = 0;
    for (final item in remainingItems) {
      cleaningFine += (item.baseValue * GameConstants.raidPenaltyRate).round();
    }

    final totalTransportCost = _transportCallsCount * transportCallCost;

    // Fatura diyaloğunu aç
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RaidSummarySheet(
        loadedItemsCount: loadedItems.length,
        totalScrapIncome: _totalScrapIncome,
        transportCosts: totalTransportCost,
        cleanupPenalty: cleaningFine,
        isMasterPacker: isMasterPacker,
        onContinue: () {
          Navigator.of(ctx).pop(); // Faturayı kapat
          Navigator.of(context).pop(); // Müzayedeye dön
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _game == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF141416),
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    final playerState = ref.watch(playerProfileProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst HUD Bar: Geri Sayım Sayacı, Cüzdan ve Depo Bilgisi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  // Depo Başlığı & Arketip
                  DiegeticMetalPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    borderRadius: 8,
                    showRivets: false,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GameColors.gold.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: GameColors.gold, width: 1),
                          ),
                          child: Text(
                            _activeUnit?.unitNumber ?? '#204',
                            style: GameTypography.display(
                              color: GameColors.goldLight,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _activeUnit?.archetype.label ?? 'Karma Depo',
                          style: GameTypography.display(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Cüzdan Göstergesi
                  DiegeticMetalPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    borderRadius: 8,
                    showRivets: false,
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: GameColors.profitGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${playerState.cash} ₺',
                          style: GameTypography.led(
                            color: GameColors.profitGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Canlı Kalan Süre Sayacı
                  ValueListenableBuilder<int>(
                    valueListenable: _game!.remainingSeconds,
                    builder: (context, seconds, _) {
                      final isUrgent = seconds <= 10;
                      return RetroLedDisplay(
                        icon: Icons.timer,
                        value: '$seconds SN',
                        ledColor: isUrgent ? GameColors.lossRed : GameColors.neonCyan,
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Sarı-Siyah Tehlike İkaz Şeridi
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: HazardStripeBanner(height: 5),
            ),
            const SizedBox(height: 4),

            // 2. Üst Yarı: 2D Katmanlı Depo Flame Sahnesi (%52)
            Expanded(
              flex: 52,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141418),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GameColors.panelBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GameWidget(game: _game!),
                ),
              ),
            ),

            // 3. Seçili Eşya Arcade Aksiyon Çubuğu
            if (_inspectedItem != null) _buildItemActionBar(lang.code),

            // 4. Alt Yarı: Araç Bagajı Grid Tetrisi (%48)
            Expanded(
              flex: 48,
              child: TrunkGridWidget(
                activeDragItem: _inspectedItem,
                activeRotation: _itemRotation,
                onTransportCalled: _handleTransportCalled,
                onItemPickedFromTrunk: _handlePopItemFromTrunk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Eşyaya tıklandığında beliren dinamik arcade oyun çubuğu
  Widget _buildItemActionBar(String langCode) {
    final isTurned = (_itemRotation == 90 || _itemRotation == 270);
    final displayW = isTurned ? _inspectedItem!.height : _inspectedItem!.width;
    final displayH = isTurned ? _inspectedItem!.width : _inspectedItem!.height;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DiegeticMetalPanel(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        borderColor: GameColors.neonCyan,
        borderWidth: 1.5,
        glowColor: GameColors.neonCyan,
        borderRadius: 10,
        child: Row(
          children: [
            // Eşya Görseli (Çift Tıklamayla Döndürme)
            GestureDetector(
              onDoubleTap: _handleRotateItem,
              child: Tooltip(
                message: 'Çift tıkla döndür',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(4),
                    child: RotatedBox(
                      quarterTurns: _itemRotation ~/ 90,
                      child: Image.asset(
                        _inspectedItem!.spritePath,
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber, size: 24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Eşya Bilgisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _inspectedItem!.localizedName(langCode),
                    style: GameTypography.display(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$displayW x $displayH Izgara • ${_inspectedItem!.weight.toStringAsFixed(1)} kg',
                    style: GameTypography.body(
                      color: GameColors.neonCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔄 3D Arcade "DÖNDÜR" Butonu ($90^\circ$)
            ArcadeButton(
              text: '90°',
              icon: Icons.rotate_right,
              onPressed: _handleRotateItem,
              primaryColor: GameColors.gold,
              shadowColor: const Color(0xFF8C711C),
              textColor: Colors.black,
              height: 36,
              fontSize: 10,
            ),
            const SizedBox(width: 4),

            // 🛠️ 3D Arcade "ATÖLYE" Butonu
            ArcadeButton(
              text: 'ATÖLYE',
              icon: Icons.handyman,
              onPressed: () {
                final item = _inspectedItem!;
                _game?.removeSelectedItem();
                setState(() {
                  _inspectedItem = null;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CraftingBenchScreen(initialItem: item)),
                );
              },
              primaryColor: GameColors.neonCyan,
              shadowColor: const Color(0xFF0097A7),
              textColor: Colors.black,
              height: 36,
              fontSize: 9,
            ),
            const SizedBox(width: 4),

            // 🔴 3D Arcade "HURDA" Butonu (%20 anında nakit)
            ArcadeButton(
              text: 'HURDA',
              icon: Icons.delete_sweep,
              onPressed: _handleScrapItem,
              primaryColor: GameColors.lossRed,
              shadowColor: const Color(0xFF8E0000),
              textColor: Colors.white,
              height: 36,
              fontSize: 9,
            ),
            const SizedBox(width: 4),

            // 🟢 3D Arcade "ARACA YÜKLE" Butonu
            ArcadeButton(
              text: 'YÜKLE 📦',
              icon: Icons.unarchive,
              onPressed: _handleLoadToVehicle,
              primaryColor: GameColors.profitGreen,
              shadowColor: const Color(0xFF00893E),
              textColor: Colors.black,
              height: 36,
              fontSize: 9,
            ),
          ],
        ),
      ),
    );
  }
}

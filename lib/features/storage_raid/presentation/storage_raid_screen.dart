import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/localization/localization_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/debug_console_sheet.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/city_map/presentation/city_map_screen.dart';
import 'package:yeni_oyun_sablon/features/crafting_benches/presentation/crafting_bench_screen.dart';
import 'package:yeni_oyun_sablon/features/dungeon/presentation/widgets/dungeon_equipment_guide_sheet.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
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

class _StorageRaidScreenState extends ConsumerState<StorageRaidScreen>
    with SingleTickerProviderStateMixin {
  StorageRaidGame? _game;
  GeneratedStorageUnit? _activeUnit;
  bool _isLoading = true;

  late AnimationController _vehicleEntranceController;
  late Animation<Offset> _vehicleSlideAnimation;

  ItemModel? _inspectedItem;
  int _itemRotation = 0; // 0, 90, 180, 270
  int _totalScrapIncome = 0;
  int _transportCallsCount = 0;
  bool _hasShownDungeonGuide = false;
  static const int transportCallCost = 350; // Her ek nakliye çağırma bedeli

  @override
  void initState() {
    super.initState();

    _vehicleEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _vehicleSlideAnimation = Tween<Offset>(
      begin: const Offset(1.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _vehicleEntranceController,
      curve: Curves.easeOutCubic,
    ));

    _vehicleEntranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted && _game != null) {
          final isFTUE = ref.read(ftueProvider) == FTUEStep.tetrisTutorial;
          if (isFTUE) {
            _game!.isTimerPaused = true;
            _showTetrisTutorialDialog();
          } else {
            setState(() {
              _game!.isTimerPaused = false;
            });
            HapticFeedback.heavyImpact();
          }
        }
      }
    });

    _initRaidGame();
  }

  /// Tetris Başlangıç İnteraktif Kılavuz Modalı
  void _showTetrisTutorialDialog() {
    int tutorialPage = 0;
    final tutorialSteps = [
      {
        'title': '1. DEPO VE SEÇİM',
        'desc': 'Depodaki eşyalara tıklayabilir veya parmağınızla doğrudan tutup bagaja sürükleyebilirsiniz.',
        'icon': Icons.touch_app,
        'color': GameColors.neonCyan,
      },
      {
        'title': '2. ARCADE BUTONLARI',
        'desc': '90° ile eşyaları döndürebilir, ATÖLYE ile craft masalarına aktarabilir veya HURDA ile anında %20 nakite çevirebilirsiniz.',
        'icon': Icons.rotate_right,
        'color': GameColors.gold,
      },
      {
        'title': '3. BAGAJ İSTİFİ',
        'desc': 'Eşyaları en az boşluk kalacak şekilde kasaya yerleştirin. %80+ dolulukta USTA İSTİFÇİ XP bonusu kazanırsınız!',
        'icon': Icons.grid_view_rounded,
        'color': GameColors.profitGreen,
      },
      {
        'title': '4. SÜRE VE CEZA KURALI',
        'desc': 'DİKKAT: Süre sıfırlandığında depoda kalan her eşya için piyasa değerinin %25\'i kadar temizlik cezası faturası kesilir!',
        'icon': Icons.warning_amber_rounded,
        'color': GameColors.lossRed,
      },
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final step = tutorialSteps[tutorialPage];
            final isLast = tutorialPage == tutorialSteps.length - 1;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: DiegeticMetalPanel(
                padding: const EdgeInsets.all(18),
                borderColor: step['color'] as Color,
                borderWidth: 2,
                glowColor: step['color'] as Color,
                borderRadius: 16,
                backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.96),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(step['icon'] as IconData, color: step['color'] as Color, size: 44),
                    const SizedBox(height: 10),
                    Text(
                      step['title'] as String,
                      style: GameTypography.display(
                        color: step['color'] as Color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      step['desc'] as String,
                      style: GameTypography.body(color: Colors.white, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${tutorialPage + 1} / ${tutorialSteps.length}',
                          style: GameTypography.led(color: Colors.white54, fontSize: 12),
                        ),
                        ArcadeButton(
                          text: isLast ? 'İSTİFE BAŞLA! ⏱️' : 'İLERİ ➡️',
                          icon: isLast ? Icons.play_arrow : Icons.arrow_forward,
                          onPressed: () {
                            if (isLast) {
                              Navigator.of(ctx).pop();
                              if (mounted && _game != null) {
                                setState(() {
                                  _game!.isTimerPaused = false;
                                });
                                HapticFeedback.heavyImpact();
                              }
                            } else {
                              setModalState(() {
                                tutorialPage++;
                              });
                              HapticFeedback.lightImpact();
                            }
                          },
                          primaryColor: isLast ? GameColors.profitGreen : GameColors.gold,
                          shadowColor: isLast ? const Color(0xFF00893E) : const Color(0xFF8C711C),
                          height: 42,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _vehicleEntranceController.dispose();
    super.dispose();
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

        // Eğer eşya zindan savaşçıları donanımıysa ve rehber henüz gösterilmediyse rehberi aç
        if (!_hasShownDungeonGuide && DungeonEquipmentGuideSheet.isEquipableDungeonGear(comp.itemModel)) {
          _hasShownDungeonGuide = true;
          Future.microtask(() {
            if (mounted) {
              DungeonEquipmentGuideSheet.show(
                context,
                item: comp.itemModel,
                onDismiss: () {
                  // Kullanıcı rehberi okuyup kapattı
                },
              );
            }
          });
        }
      },
      onRaidFinished: _handleRaidFinished,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Araç sağdan kayarak sahneye yanaşsın
      _vehicleEntranceController.forward();
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

  /// "YERLEŞTİR" seçildiğinde kullanıcıyı bagajda istediği hücreye dokunmaya veya sürüklemeye yönlendirir
  void _handleLoadToVehicle() {
    if (_inspectedItem == null) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.touch_app, color: GameColors.gold, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Aşağıdaki bagajda yerleştirmek istediğiniz hücreye dokunun veya basılı tutup sürükleyin!',
                style: GameTypography.body(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E202B),
        duration: const Duration(seconds: 3),
      ),
    );
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

          if (ref.read(ftueProvider) == FTUEStep.tetrisTutorial) {
            ref.read(ftueProvider.notifier).setStep(FTUEStep.interactiveMapIntro);
          }

          // Araç sağdan çıkış animasyonu yapıp Şehir Haritasına geçiş yap
          _vehicleEntranceController.reverse().then((_) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 600),
                  pageBuilder: (context, animation, secondaryAnimation) => const CityMapScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            }
          });
        },
      ),
    );
  }

  /// Hızlı test için tüm depodaki eşyaları sırayla bagaja istifler
  Future<void> _handleDebugAutoPackAll() async {
    if (_game == null) return;
    final trunkNotifier = ref.read(trunkInventoryProvider.notifier);
    final items = _game!.getAllActiveItemModels();

    for (final item in items) {
      await trunkNotifier.autoPlaceItem(item);
    }
    for (final comp in List.from(_game!.getActiveComponents())) {
      comp.loot();
    }
    _game!.clearSelection();
    setState(() {
      _inspectedItem = null;
    });
    HapticFeedback.heavyImpact();
  }

  /// Hızlı test için tüm depoyu tek tuşla hurdaya satar
  void _handleDebugScrapAll() {
    if (_game == null) return;
    final items = _game!.getAllActiveItemModels();
    int totalScrap = 0;
    for (final item in items) {
      final scrapVal = (item.baseValue * 0.20).round();
      totalScrap = totalScrap + scrapVal;
    }
    _totalScrapIncome = _totalScrapIncome + totalScrap;
    ref.read(playerProfileProvider.notifier).addCash(totalScrap);

    for (final comp in List.from(_game!.getActiveComponents())) {
      comp.loot();
    }
    _game!.clearSelection();
    setState(() {
      _inspectedItem = null;
    });
    HapticFeedback.heavyImpact();
    _game!.finishRaid();
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
            // 1. Üst HUD Bar: Geri Sayım Sayacı, Cüzdan, Depo Bilgisi ve Debug Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Depo Başlığı & Arketip
                        Flexible(
                          child: DiegeticMetalPanel(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            borderRadius: 8,
                            showRivets: false,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: GameColors.gold.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: GameColors.gold, width: 1),
                                  ),
                                  child: Text(
                                    _activeUnit?.unitNumber ?? '#204',
                                    style: GameTypography.display(
                                      color: GameColors.goldLight,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _activeUnit?.archetype.label ?? 'Karma Depo',
                                    overflow: TextOverflow.ellipsis,
                                    style: GameTypography.display(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Cüzdan Göstergesi
                        DiegeticMetalPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          borderRadius: 8,
                          showRivets: false,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet, color: GameColors.profitGreen, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                '${playerState.cash} ₺',
                                style: GameTypography.led(
                                  color: GameColors.profitGreen,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Sağ Grup: Debug + Canlı Kalan Süre Sayacı
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Geliştirici Test Modu',
                        icon: const Icon(Icons.bug_report, color: GameColors.neonCyan, size: 20),
                        onPressed: () {
                          DebugConsoleSheet.show(
                            context,
                            onAddTime: () => setState(() => _game?.addExtraTime(60)),
                            onAutoPackAll: _handleDebugAutoPackAll,
                            onScrapAll: _handleDebugScrapAll,
                            onToggleGrid: () => setState(() => _game?.toggleDebugGrid()),
                            isGridVisible: _game?.showDebugGrid ?? false,
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      ValueListenableBuilder<int>(
                        valueListenable: _game!.remainingSeconds,
                        builder: (context, seconds, _) {
                          final isUrgent = seconds <= 10;
                          return RetroLedDisplay(
                            icon: Icons.timer,
                            value: _game!.isTimerPaused ? 'YANAŞIYOR...' : '$seconds SN',
                            ledColor: _game!.isTimerPaused
                                ? GameColors.hazardYellow
                                : (isUrgent ? GameColors.lossRed : GameColors.neonCyan),
                            fontSize: 12,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sarı-Siyah Tehlike İkaz Şeridi
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: HazardStripeBanner(height: 5),
            ),
            const SizedBox(height: 4),

            // 2. Çift Elle Oynama Alanı: SOLDA Depo Sahnesi, SAĞDA Geri Geri Yanaşan Pikap Araç
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SOL KOLON: 2D Katmanlı Depo Flame Sahnesi
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 4, bottom: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141418),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _inspectedItem != null ? GameColors.neonCyan : GameColors.panelBorder,
                          width: _inspectedItem != null ? 2.5 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_inspectedItem != null ? GameColors.neonCyan : Colors.black).withValues(alpha: 0.5),
                            blurRadius: _inspectedItem != null ? 18 : 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: GameWidget(game: _game!),
                            ),

                            // Depodan Doğrudan Tutup Çekme Overlay'i
                            if (_inspectedItem != null)
                              Positioned.fill(
                                child: _buildWarehouseDirectDragOverlay(lang.code),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SAĞ KOLON: Sağdan Sola Geri Geri Yanaşan Pikap Araç ve Kasasındaki Grid
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4, right: 10, bottom: 6),
                      child: SlideTransition(
                        position: _vehicleSlideAnimation,
                        child: TrunkGridWidget(
                          activeDragItem: _inspectedItem,
                          activeRotation: _itemRotation,
                          onTransportCalled: _handleTransportCalled,
                          onItemPickedFromTrunk: _handlePopItemFromTrunk,
                          onItemPlaced: () {
                            _game?.removeSelectedItem();
                            setState(() {
                              _inspectedItem = null;
                              _itemRotation = 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Alt Kısım: Seçili Eşya Arcade Aksiyon Çubuğu (Döndür, Hurda, Atölye)
            if (_inspectedItem != null) _buildItemActionBar(lang.code),
          ],
        ),
      ),
    );
  }

  /// Depo Sahnesi üzerindeyken eşyayı doğrudan tutup bagaja çekmeyi sağlayan interaktif Draggable katmanı
  Widget _buildWarehouseDirectDragOverlay(String langCode) {
    return Draggable<ItemModel>(
      data: _inspectedItem,
      feedback: _ItemDragFootprintWidget(
        item: _inspectedItem!,
        rotation: _itemRotation,
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.15),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10121A).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GameColors.neonCyan, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: GameColors.neonCyan.withValues(alpha: 0.35),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pan_tool_alt, color: GameColors.neonCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'BURADAN BASILI TUTUP ARACA ÇEKİN 👇',
                style: GameTypography.display(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: GameColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: GameColors.gold, width: 0.8),
                ),
                child: Text(
                  '${_itemRotation == 90 || _itemRotation == 270 ? _inspectedItem!.height : _inspectedItem!.width}x${_itemRotation == 90 || _itemRotation == 270 ? _inspectedItem!.width : _inspectedItem!.height} GRID',
                  style: GameTypography.led(
                    color: GameColors.goldLight,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
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
            // Eşya Görseli & Sürükleme Başlatıcı (Draggable / Çift Dokunma ile Döndürme)
            Draggable<ItemModel>(
              data: _inspectedItem,
              feedback: _ItemDragFootprintWidget(
                item: _inspectedItem!,
                rotation: _itemRotation,
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
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
                      ),
                    ),
                  ),
                ),
              ),
              child: GestureDetector(
                onDoubleTap: _handleRotateItem,
                child: Tooltip(
                  message: 'Basılı tut ve bagaja sürükle / Çift tıkla döndür',
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
            ),
            const SizedBox(width: 8),

            // Eşya Bilgisi (Sürüklenebilir alan)
            Expanded(
              child: Draggable<ItemModel>(
                data: _inspectedItem,
                feedback: _ItemDragFootprintWidget(
                  item: _inspectedItem!,
                  rotation: _itemRotation,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _inspectedItem!.localizedName(langCode),
                            style: GameTypography.display(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (DungeonEquipmentGuideSheet.isEquipableDungeonGear(_inspectedItem!)) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              DungeonEquipmentGuideSheet.show(
                                context,
                                item: _inspectedItem!,
                                onDismiss: () {},
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: GameColors.gold.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: GameColors.gold, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.shield, color: GameColors.gold, size: 10),
                                  const SizedBox(width: 2),
                                  Text(
                                    '+${(_inspectedItem!.baseValue * 0.5).round()} CP',
                                    style: GameTypography.display(
                                      color: GameColors.goldLight,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$displayW x $displayH Grid • ${_inspectedItem!.weight.toStringAsFixed(1)} kg ✋(Sürükle)',
                      style: GameTypography.body(
                        color: GameColors.neonCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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

            // 🟢 3D Arcade "YERLEŞTİR" Butonu (Dokunarak veya Sürükleyerek)
            ArcadeButton(
              text: 'YERLEŞTİR 📦',
              icon: Icons.touch_app,
              onPressed: _handleLoadToVehicle,
              primaryColor: GameColors.profitGreen,
              shadowColor: const Color(0xFF00893E),
              textColor: Colors.black,
              height: 36,
              fontSize: 8.5,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sürükleme esnasında imlecin altında tam kaplayacağı hücreleri ve matrisi gösteren Polyomino Grid Önizleme Widget'ı
class _ItemDragFootprintWidget extends StatelessWidget {
  final ItemModel item;
  final int rotation;

  const _ItemDragFootprintWidget({
    required this.item,
    required this.rotation,
  });

  List<int> _getRotatedMask() {
    final w = item.width;
    final h = item.height;
    final mask = item.bitmask;

    if (rotation == 0) return mask;

    if (rotation == 90) {
      final rotated = List<int>.filled(w, 0);
      for (int r = 0; r < h; r++) {
        for (int c = 0; c < w; c++) {
          if ((mask[r] & (1 << c)) != 0) {
            rotated[c] |= (1 << (h - 1 - r));
          }
        }
      }
      return rotated;
    }

    if (rotation == 180) {
      final rotated = List<int>.filled(h, 0);
      for (int r = 0; r < h; r++) {
        for (int c = 0; c < w; c++) {
          if ((mask[r] & (1 << c)) != 0) {
            rotated[h - 1 - r] |= (1 << (w - 1 - c));
          }
        }
      }
      return rotated;
    }

    if (rotation == 270) {
      final rotated = List<int>.filled(w, 0);
      for (int r = 0; r < h; r++) {
        for (int c = 0; c < w; c++) {
          if ((mask[r] & (1 << c)) != 0) {
            rotated[w - 1 - c] |= (1 << r);
          }
        }
      }
      return rotated;
    }

    return mask;
  }

  @override
  Widget build(BuildContext context) {
    final isTurned = (rotation == 90 || rotation == 270);
    final cols = isTurned ? item.height : item.width;
    final rows = isTurned ? item.width : item.height;
    final rotatedMask = _getRotatedMask();

    const double cellSize = 38.0;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kaplayacağı Polyomino Grid Matrisi
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F111A).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GameColors.neonCyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: GameColors.neonCyan.withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Hücre Izgarası
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(rows, (r) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(cols, (c) {
                        final isOccupied = (rotatedMask[r] & (1 << c)) != 0;
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: isOccupied
                                ? GameColors.neonCyan.withValues(alpha: 0.35)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isOccupied
                                  ? GameColors.neonCyan
                                  : Colors.white.withValues(alpha: 0.1),
                              width: isOccupied ? 1.5 : 0.8,
                            ),
                          ),
                          child: isOccupied
                              ? Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: GameColors.neonCyan,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      }),
                    );
                  }),
                ),

                // Eşya Görseli
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: RotatedBox(
                        quarterTurns: rotation ~/ 90,
                        child: Image.asset(
                          item.spritePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.inventory_2,
                            color: Colors.amber,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Boyut ve Ağırlık Rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF141418).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GameColors.gold, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grid_4x4, color: GameColors.gold, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${cols}x$rows GRID • ${item.weight.toStringAsFixed(1)} kg',
                  style: GameTypography.display(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


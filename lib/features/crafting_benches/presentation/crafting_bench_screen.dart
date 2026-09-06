import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/localization/localization_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/auction_stamp.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/game_screen_shake.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/crafting_benches/providers/crafting_bench_provider.dart';
import 'package:yeni_oyun_sablon/features/marketplace/presentation/marketplace_screen.dart';

/// Atölye ve Dokunsal Eşya Restorasyon Ekranı (ADR-028)
class CraftingBenchScreen extends ConsumerStatefulWidget {
  final ItemModel? initialItem;
  final int initialTab;

  const CraftingBenchScreen({
    super.key,
    this.initialItem,
    this.initialTab = 0,
  });

  @override
  ConsumerState<CraftingBenchScreen> createState() => _CraftingBenchScreenState();
}

class _CraftingBenchScreenState extends ConsumerState<CraftingBenchScreen> {
  final GameScreenShakeController _shakeController = GameScreenShakeController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialItem != null) {
        ref.read(craftingBenchProvider.notifier).setBenchItem(widget.initialItem!);
      } else {
        final allItems = await DatabaseService.instance.getAllItems();
        if (allItems.isNotEmpty) {
          ref.read(craftingBenchProvider.notifier).setBenchItem(allItems.first);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final benchState = ref.watch(craftingBenchProvider);
    final lang = ref.watch(languageProvider);
    final item = benchState.activeItem ?? widget.initialItem;

    if (item == null) {
      return const Scaffold(
        backgroundColor: GameColors.background,
        body: Center(child: CircularProgressIndicator(color: GameColors.gold)),
      );
    }

    final progressPercent = (benchState.cleaningProgress * 100).toInt();

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: GameScreenShake(
          controller: _shakeController,
          child: Column(
            children: [
              // 1. Üst Panel: Atölye Ustalığı ve HUD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    DiegeticMetalPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              'LVL ${benchState.masteryLevel}',
                              style: GameTypography.display(
                                color: GameColors.goldLight,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ATÖLYE USTALIĞI',
                                style: GameTypography.display(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${benchState.masteryXp % 100} / 100 XP',
                                style: GameTypography.body(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    RetroLedDisplay(
                      label: 'TEMİZLİK',
                      value: '$progressPercent %',
                      ledColor: benchState.isRestored ? GameColors.profitGreen : GameColors.gold,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: HazardStripeBanner(height: 6),
              ),
              const SizedBox(height: 8),

              // 2. Restorasyon Masası (Dokunsal Zımparalama Alanı)
              Expanded(
                flex: 60,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1917),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GameColors.panelBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        // Ahşap / Metal Tezgâh Dokusu
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.1,
                                colors: [
                                  Color(0xFF2C251F),
                                  Color(0xFF141210),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Eşya Görseli & İnteraktif Dokunarak Ovalama Alanı
                        Center(
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              if (!benchState.isRestored) {
                                ref.read(craftingBenchProvider.notifier).addRubProgress(0.035);
                                HapticFeedback.selectionClick();
                                if (benchState.cleaningProgress >= 0.95) {
                                  _shakeController.shake(intensity: 6.0);
                                  HapticFeedback.heavyImpact();
                                }
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Temiz/Parlak Hali (Altta)
                                Image.asset(
                                  item.spritePath,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.inventory_2,
                                    color: Colors.amber,
                                    size: 100,
                                  ),
                                ),

                                // Paslı / Kirli Maske Katmanı (Üstte, ovalandıkça şeffaflaşır)
                                if (!benchState.isRestored)
                                  Opacity(
                                    opacity: (1.0 - benchState.cleaningProgress).clamp(0.0, 1.0),
                                    child: ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFF5C3A21),
                                        BlendMode.modulate,
                                      ),
                                      child: Image.asset(
                                        item.spritePath,
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.inventory_2,
                                          color: Colors.brown,
                                          size: 100,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Dokunarak Ovalama Yönergesi
                        if (!benchState.isRestored)
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.touch_app, color: GameColors.neonCyan, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PARMAĞINIZLA PASLARI OVALAYIN 👆',
                                      style: GameTypography.display(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Restorasyon Bitti Damgası
                        if (benchState.isRestored)
                          const Center(
                            child: AuctionStamp(
                              text: 'KUSURSUZ RESTORASYON',
                              color: GameColors.profitGreen,
                              fontSize: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 3. Eşya Bilgi ve Restorasyon Aksiyon Paneli
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: DiegeticMetalPanel(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.localizedName(lang.code),
                            style: GameTypography.display(color: Colors.white, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GameColors.profitGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: GameColors.profitGreen),
                            ),
                            child: Text(
                              benchState.isRestored ? 'MÜKEMMEL (1.5x DEĞER)' : 'PASLI (0.5x DEĞER)',
                              style: GameTypography.body(
                                color: benchState.isRestored ? GameColors.profitGreen : Colors.orangeAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bu eşya atölyede temizlenip parlatılarak pazar yerinde en yüksek fiyata satılmaya hazır hale getirilir.',
                        style: GameTypography.body(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 12),

                      // Aksiyon Butonları
                      if (benchState.isRestored) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ArcadeButton(
                                text: 'PAZAR YERİNDE SATIŞA ÇIKAR 🏷️',
                                icon: Icons.storefront,
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => MarketplaceScreen(itemToSell: item),
                                    ),
                                  );
                                },
                                primaryColor: GameColors.gold,
                                shadowColor: const Color(0xFF8C711C),
                                height: 46,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Seviye 3+ Otomatik Seri Restorasyon Butonu
                        if (benchState.hasAutoPolishUnlocked)
                          ArcadeButton(
                            text: '⚡ OTOMATİK SERİ PARLAT (LVL 3+)',
                            icon: Icons.auto_fix_high,
                            onPressed: () {
                              ref.read(craftingBenchProvider.notifier).performAutoRestore();
                              _shakeController.shake(intensity: 5.0);
                            },
                            primaryColor: GameColors.neonCyan,
                            shadowColor: const Color(0xFF0097A7),
                            textColor: Colors.black,
                            height: 44,
                            fontSize: 11,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text(
                              '🔒 Otomatik Restorasyon Kilidi için: Seviye 3 Atölye Ustalığı Gerekir',
                              style: GameTypography.body(color: Colors.white38, fontSize: 10),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

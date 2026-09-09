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
import 'package:yeni_oyun_sablon/features/home/presentation/home_screen.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/crafting_benches/presentation/widgets/tactile_hydraulic_press.dart';
import 'package:yeni_oyun_sablon/features/crafting_benches/presentation/widgets/collector_field_journal_view.dart';

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

class _CraftingBenchScreenState extends ConsumerState<CraftingBenchScreen>
    with SingleTickerProviderStateMixin {
  final GameScreenShakeController _shakeController = GameScreenShakeController();
  late int _activeTab;
  List<ItemModel> _homeItems = [];
  bool _isAppraised = false;

  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab.clamp(0, 4);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _shineAnimation = Tween<double>(begin: -1.2, end: 1.8).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadHomeItems();
      if (widget.initialItem != null) {
        ref.read(craftingBenchProvider.notifier).setBenchItem(widget.initialItem!);
      } else if (_homeItems.isNotEmpty) {
        ref.read(craftingBenchProvider.notifier).setBenchItem(_homeItems.first);
      } else {
        final allItems = await DatabaseService.instance.getAllItems();
        if (allItems.isNotEmpty) {
          ref.read(craftingBenchProvider.notifier).setBenchItem(allItems.first);
        }
      }
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeItems() async {
    final profile = ref.read(playerProfileProvider);
    final items = <ItemModel>[];
    for (final id in profile.homeStorageItemIds) {
      final it = await DatabaseService.instance.getItemById(id);
      if (it != null) items.add(it);
    }
    if (mounted) {
      setState(() {
        _homeItems = items;
      });
    }
  }

  void _showItemPickerSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141520),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: GameColors.gold, width: 2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('📦 TEZGAHA EŞYA SEÇ (Ev Deposu)',
                      style: GameTypography.display(color: GameColors.goldLight, fontSize: 13)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              if (_homeItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('Ev Deposunda eşya yok! Depodan yeni eşyalar getirin.',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ),
                )
              else
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    itemCount: _homeItems.length,
                    itemBuilder: (context, index) {
                      final item = _homeItems[index];
                      return ListTile(
                        leading: Image.asset(item.spritePath, width: 36, height: 36, fit: BoxFit.contain),
                        title: Text(item.nameTr, style: GameTypography.display(color: Colors.white, fontSize: 11)),
                        subtitle: Text('Değer: ${item.currentValue} ₺ • Kondisyon: ${item.condition.label}',
                            style: const TextStyle(color: Colors.white60, fontSize: 10)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: GameColors.gold),
                          onPressed: () {
                            ref.read(craftingBenchProvider.notifier).setBenchItem(item);
                            setState(() => _isAppraised = false);
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('SEÇ 🛠️',
                              style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
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
                    const SizedBox(width: 8),
                    // Eşya Seçici Butonu
                    ArcadeButton(
                      text: 'EŞYA SEÇ 📦 (${_homeItems.length})',
                      icon: Icons.inventory_2,
                      onPressed: _showItemPickerSheet,
                      primaryColor: const Color(0xFF2A2E3D),
                      shadowColor: Colors.black,
                      textColor: GameColors.goldLight,
                      height: 34,
                      fontSize: 10,
                    ),
                    const Spacer(),
                    RetroLedDisplay(
                      label: _activeTab == 2 ? 'EKSPERTİZ' : 'İLERLEME',
                      value: _activeTab == 2
                          ? (_isAppraised ? 'TAMAM' : 'BEKLİYOR')
                          : '$progressPercent %',
                      ledColor: (benchState.isRestored || _isAppraised) ? GameColors.profitGreen : GameColors.gold,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),

              // 2. Mod Seçici Segment Bar (Temizleme, Restorasyon, Ekspertiz, Üretim, Setler)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildModeTab(0, 'TEMİZLEME 🧽', GameColors.neonCyan),
                      const SizedBox(width: 6),
                      _buildModeTab(1, 'RESTORASYON 🛠️', GameColors.gold),
                      const SizedBox(width: 6),
                      _buildModeTab(2, 'EKSPERTİZ 🔍', GameColors.profitGreen),
                      const SizedBox(width: 6),
                      _buildModeTab(3, 'ÜRETİM ⚙️', Colors.orangeAccent),
                      const SizedBox(width: 6),
                      _buildModeTab(4, 'SETLER 🏆', Colors.purpleAccent),
                    ],
                  ),
                ),
              ),


              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: HazardStripeBanner(height: 5),
              ),

              // 3. Restorasyon Masası (Dokunsal Zımparalama Alanı)
              Expanded(
                flex: 55,
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
                    child: _activeTab == 3
                        ? TactileHydraulicPress(
                            userInventory: _homeItems,
                            userMasteryLevel: benchState.masteryLevel,
                            onScreenShake: () => _shakeController.shake(intensity: 7.0),
                            onCraftSuccess: (recipe, outputItem) async {
                              await ref
                                  .read(craftingBenchProvider.notifier)
                                  .craftRecipe(recipe, _homeItems);
                              await _loadHomeItems();
                            },
                          )
                        : _activeTab == 4
                            ? CollectorFieldJournalView(
                                userInventory: _homeItems,
                                onClaimBonus: (set) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🎉 ${set.nameTr} koleksiyon ödülü alındı!'),
                                      backgroundColor: GameColors.profitGreen,
                                    ),
                                  );
                                },
                              )
                            : Stack(
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
                              if (!benchState.isRestored && _activeTab != 2) {
                                ref.read(craftingBenchProvider.notifier).addRubProgress(0.04);
                                HapticFeedback.selectionClick();
                                if (benchState.cleaningProgress >= 0.95) {
                                  _shakeController.shake(intensity: 6.0);
                                  HapticFeedback.heavyImpact();
                                  if (!_shineController.isAnimating) {
                                    _shineController.forward(from: 0.0);
                                  }
                                }
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Temiz/Parlak Hali (Altta)
                                Image.asset(
                                  item.spritePath,
                                  width: 170,
                                  height: 170,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.inventory_2,
                                    color: Colors.amber,
                                    size: 100,
                                  ),
                                ),

                                // Paslı / Kirli Maske Katmanı (Temizleme veya Restorasyon modunda ovalanır)
                                if (!benchState.isRestored && _activeTab != 2)
                                  Opacity(
                                    opacity: (1.0 - benchState.cleaningProgress).clamp(0.0, 1.0),
                                    child: ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFF5C3A21),
                                        BlendMode.modulate,
                                      ),
                                      child: Image.asset(
                                        item.spritePath,
                                        width: 170,
                                        height: 170,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.inventory_2,
                                          color: Colors.brown,
                                          size: 100,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Tamamlandığında Çapraz Altın Parıltı Hüzmesi (Shine Sweep)
                                if (benchState.isRestored)
                                  AnimatedBuilder(
                                    animation: _shineAnimation,
                                    builder: (ctx, child) {
                                      return IgnorePointer(
                                        child: Container(
                                          width: 170,
                                          height: 170,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment(_shineAnimation.value - 0.5, -1.0),
                                              end: Alignment(_shineAnimation.value + 0.5, 1.0),
                                              colors: [
                                                Colors.transparent,
                                                Colors.amber.withValues(alpha: 0.25),
                                                Colors.white.withValues(alpha: 0.55),
                                                Colors.amber.withValues(alpha: 0.25),
                                                Colors.transparent,
                                              ],
                                              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Dokunarak Ovalama Yönergesi
                        if (!benchState.isRestored && _activeTab != 2)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.touch_app, color: GameColors.neonCyan, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      _activeTab == 0
                                          ? 'PARMAĞINIZLA LEKE VE PASLARI OVALAYIN 👆'
                                          : 'PARMAĞINIZLA PARLATIP RESTORE EDİN 👆',
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
                        if (benchState.isRestored && _activeTab != 2)
                          const Center(
                            child: AuctionStamp(
                              text: 'KUSURSUZ RESTORASYON',
                              color: GameColors.profitGreen,
                              fontSize: 20,
                            ),
                          ),

                        // Ekspertiz Onay Damgası
                        if (_activeTab == 2 && _isAppraised)
                          const Center(
                            child: AuctionStamp(
                              text: 'ORİJİNAL KOLEKSİYONLUK',
                              color: GameColors.gold,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_activeTab <= 2) ...[
                const SizedBox(height: 6),

                // 4. Eşya Bilgi ve Restorasyon Aksiyon Paneli
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                            style: GameTypography.display(color: Colors.white, fontSize: 13),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GameColors.profitGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: GameColors.profitGreen),
                            ),
                            child: Text(
                              benchState.isRestored
                                  ? 'MÜKEMMEL (1.25x - 2.0x DEĞER)'
                                  : '${item.condition.label.toUpperCase()} (${item.currentValue} ₺)',
                              style: GameTypography.body(
                                color: benchState.isRestored ? GameColors.profitGreen : Colors.orangeAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activeTab == 4
                            ? 'Koleksiyon setlerini tamamlayarak kalıcı satış çarpanları (+%45), itibar ve özel yetkiler kazanın.'
                            : _activeTab == 3
                                ? 'Hurda eşyaları parçalayarak değerli motor/devre parçaları sökün veya birleştirip lüks kitler üretin.'
                                : _activeTab == 2
                                    ? 'Ekspertiz masasında antika sertifikası verilir, eşyanın gerçek değeri onaylanır.'
                                    : 'Bu eşya atölyede temizlenip parlatılarak internet pazarında en yüksek fiyata satılmaya hazır hale getirilir.',
                        style: GameTypography.body(color: Colors.white60, fontSize: 10),
                      ),

                      const SizedBox(height: 10),

                      // Aksiyon Butonları
                      if (benchState.isRestored || (_activeTab == 2 && _isAppraised)) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ArcadeButton(
                                text: 'EV DEPOSUNA KAYDET 💾',
                                icon: Icons.check,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                primaryColor: GameColors.profitGreen,
                                shadowColor: const Color(0xFF006622),
                                textColor: Colors.black,
                                height: 40,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ArcadeButton(
                                text: 'MEZATNET\'TE SAT 🌐',
                                icon: Icons.storefront,
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const HomeScreen(initialTabIndex: 0),
                                    ),
                                  );
                                },
                                primaryColor: GameColors.gold,
                                shadowColor: const Color(0xFF8C711C),
                                textColor: Colors.black,
                                height: 40,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ] else if (_activeTab == 2) ...[
                        ArcadeButton(
                          text: 'EKSPERTİZ RAPORU ÇIKAR 🔍 (50 ₺)',
                          icon: Icons.verified,
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            ref.read(playerProfileProvider.notifier).deductCash(50);
                            ref.read(playerProfileProvider.notifier).addReputation(40);
                            setState(() => _isAppraised = true);
                            _shakeController.shake(intensity: 5.0);
                          },
                          primaryColor: GameColors.neonCyan,
                          shadowColor: const Color(0xFF00838F),
                          textColor: Colors.black,
                          height: 42,
                          fontSize: 11,
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
                            height: 40,
                            fontSize: 10,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
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
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(int index, String label, Color color) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : const Color(0xFF1E202B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GameTypography.display(
            color: isSelected ? color : Colors.white60,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}


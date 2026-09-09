import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/crafting_benches/presentation/crafting_bench_screen.dart';
import 'package:yeni_oyun_sablon/features/dungeon/models/mercenary_model.dart';
import 'package:yeni_oyun_sablon/features/dungeon/presentation/dungeon_hub_screen.dart';
import 'package:yeni_oyun_sablon/features/dungeon/presentation/widgets/dungeon_equipment_guide_sheet.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/marketplace/models/web_listing_model.dart';
import 'package:yeni_oyun_sablon/features/marketplace/providers/vip_orders_provider.dart';
import 'package:yeni_oyun_sablon/features/marketplace/providers/market_whisper_provider.dart';
import 'package:yeni_oyun_sablon/features/marketplace/providers/web_marketplace_provider.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
import 'package:yeni_oyun_sablon/features/onboarding/widgets/ftue_guide_overlay.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/tavern/presentation/tavern_screen.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

/// 🏠 Ev & Karargah Ekranı (HomeScreen - 3 Odalı)
class HomeScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ItemModel> _homeStorageItems = [];
  List<ItemModel> _trunkItems = [];
  bool _isLoading = true;
  bool _isMonitorZoomed = false;

  @override
  void initState() {
    super.initState();

    // FTUE başlangıç sekmesi kontrolü
    int startTab = widget.initialTabIndex;
    final ftue = ref.read(ftueProvider);
    if (ftue == FTUEStep.homeInventoryTransfer) {
      startTab = 2; // Atölye & Depo
    } else if (ftue == FTUEStep.marketplaceFirstSale) {
      startTab = 0; // Çalışma Odası
    } else if (ftue == FTUEStep.gearAndNpcIntro ||
        ftue == FTUEStep.tavernHiring ||
        ftue == FTUEStep.restRoomEquip) {
      startTab = 1; // Dinlenme Odası
    }

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: startTab,
    );
    _loadAllInventories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllInventories() async {
    final profile = ref.read(playerProfileProvider);
    final trunkState = ref.read(trunkInventoryProvider);

    // Ev Deposu eşyaları
    final homeItems = <ItemModel>[];
    for (final id in profile.homeStorageItemIds) {
      final item = await DatabaseService.instance.getItemById(id);
      if (item != null) homeItems.add(item);
    }

    // Araç Bagajı eşyaları
    final trunkLoaded = <ItemModel>[];
    for (final placer in trunkState.placedItems) {
      if (placer.itemId != null) {
        final item = await DatabaseService.instance.getItemById(placer.itemId!);
        if (item != null) trunkLoaded.add(item);
      }
    }

    if (mounted) {
      setState(() {
        _homeStorageItems = homeItems;
        _trunkItems = trunkLoaded;
        _isLoading = false;
      });
    }
  }

  /// Büyülü Savaş Ekipmanı Açıklama Diyaloğu (FTUE)
  void _showMagicGearDialogue(ItemModel gearItem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: DiegeticMetalPanel(
          padding: const EdgeInsets.all(18),
          borderColor: GameColors.gold,
          borderWidth: 2,
          glowColor: GameColors.gold,
          borderRadius: 16,
          backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.98),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: GameColors.gold, size: 44),
              const SizedBox(height: 10),
              Text(
                'BÜYÜLÜ SAVAŞ EKİPMANI BULUNDU!',
                style: GameTypography.display(
                  color: GameColors.goldLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Bu büyülü bir savaş eşyasıdır (${gearItem.nameTr})! Bu ekipmanları kullanabilen paralı savaşçılar vardır.\n\nSavaşçılar evindeki DİNLENME ODASINDA dinlenir ve zindanlara sefere çıkarlar!',
                style: GameTypography.body(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ArcadeButton(
                text: 'DİNLENME ODASINA GİT 🛌',
                icon: Icons.hotel,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _tabController.animateTo(1); // Dinlenme odasına geç
                  ref.read(ftueProvider.notifier).setStep(FTUEStep.tavernHiring);
                },
                primaryColor: GameColors.gold,
                shadowColor: const Color(0xFF8C711C),
                textColor: Colors.black,
                height: 42,
                fontSize: 11,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// FTUE Büyülü Savaş Ekipmanı Koruma Açıklama Diyaloğu
  void _showProtectedGearExplanationDialog(ItemModel item) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: DiegeticMetalPanel(
          padding: const EdgeInsets.all(18),
          borderColor: GameColors.gold,
          borderWidth: 2,
          glowColor: GameColors.gold,
          borderRadius: 16,
          backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.98),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, color: GameColors.gold, size: 44),
              const SizedBox(height: 10),
              Text(
                '🛡️ BÜYÜLÜ SAVAŞ EKİPMANI (KORUMALI)',
                style: GameTypography.display(
                  color: GameColors.goldLight,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Bu kadim bir savaş ekipmanıdır (${item.nameTr})!\n\nBu nadide parçayı internette üç kuruşa satamazsın. Birazdan normal eşyaları satıp kazandığımız parayla Han\'dan kiralayacağımız paralı askerimize bu ekipmanı giydirip zindan seferlerine göndereceğiz!',
                style: GameTypography.body(color: Colors.white, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ArcadeButton(
                text: 'ANLADIM, NORMAL EŞYA SATACAĞIM 👍',
                icon: Icons.check,
                onPressed: () => Navigator.of(ctx).pop(),
                primaryColor: GameColors.gold,
                shadowColor: const Color(0xFF8C711C),
                textColor: Colors.black,
                height: 40,
                fontSize: 11,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// İlk Satış Başarılı & Han'a Yönlendirme Modalı (FTUE)
  void _showFTUESaleCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: DiegeticMetalPanel(
          padding: const EdgeInsets.all(20),
          borderColor: GameColors.profitGreen,
          borderWidth: 2.5,
          glowColor: GameColors.profitGreen,
          borderRadius: 16,
          backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.98),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: GameColors.profitGreen, size: 54),
              const SizedBox(height: 12),
              Text(
                'İLK SATIŞ TAMAMLANDI! 💰🎉',
                style: GameTypography.display(
                  color: GameColors.profitGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tebrikler! İnternet pazarında ilk satışını yaptın ve kasanı doldurdun!\n\nArtık bir paralı asker tutacak kadar bütçen var. Şimdi o satmadığımız BÜYÜLÜ SAVAŞ EKİPMANI\'nı kuşanacak bir savaşçı kiralamak için Kara Ejder Hanı\'na gidelim!',
                style: GameTypography.body(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ArcadeButton(
                text: 'DİNLENME ODASINA GEÇ 🛌',
                icon: Icons.hotel,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(ftueProvider.notifier).setStep(FTUEStep.tavernHiring);
                  _tabController.animateTo(1); // Dinlenme Odasına geç
                },
                primaryColor: GameColors.gold,
                shadowColor: const Color(0xFF8C711C),
                textColor: Colors.black,
                height: 44,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tüm Bagajı Tek Tıkla Ev Deposuna Aktar
  Future<void> _transferAllTrunkToHome() async {
    if (_trunkItems.isEmpty) return;

    HapticFeedback.heavyImpact();
    final ids = _trunkItems.map((i) => i.id).toList();

    // 1. Ev deposuna ekle
    await ref.read(playerProfileProvider.notifier).transferAllToHomeStorage(ids);

    // 2. Bagajı temizle
    await ref.read(trunkInventoryProvider.notifier).clearTrunk();

    await _loadAllInventories();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ids.length} adet eşya Ev Deposuna aktarıldı!'),
        backgroundColor: GameColors.profitGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Bagajdaki Tek Eşyayı Çift Dokunarak Ev Deposuna Aktar
  Future<void> _transferSingleTrunkToHome(ItemModel item) async {
    HapticFeedback.mediumImpact();
    await ref.read(trunkInventoryProvider.notifier).removeItem(item.id);
    await ref.read(playerProfileProvider.notifier).addToHomeStorage(item.id);
    await _loadAllInventories();
  }

  /// Ev Deposundaki Tek Eşyayı Çift Dokunarak Araca Yükle
  Future<void> _transferSingleHomeToTrunk(ItemModel item) async {
    final trunkNotifier = ref.read(trunkInventoryProvider.notifier);
    final placed = await trunkNotifier.autoPlaceItem(item);

    if (placed) {
      HapticFeedback.mediumImpact();
      await ref.read(playerProfileProvider.notifier).removeFromHomeStorage(item.id);
      await _loadAllInventories();
    } else {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Araç bagajında yer yok veya aşırı ağır!'),
          backgroundColor: GameColors.alertOrange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        title: Text(
          '🏠 KARARGAH & EV (${profile.homeTierTitle})',
          style: GameTypography.display(color: GameColors.goldLight, fontSize: 13),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GameColors.gold,
          indicatorWeight: 3,
          labelColor: GameColors.gold,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.computer), text: '💻 ÇALIŞMA ODASI'),
            Tab(icon: Icon(Icons.hotel), text: '🛌 DİNLENME ODASI'),
            Tab(icon: Icon(Icons.handyman), text: '🛠️ ATÖLYE & DEPO'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: RetroLedDisplay(
                icon: Icons.account_balance_wallet,
                value: '${profile.cash} ₺',
                ledColor: GameColors.profitGreen,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: GameColors.gold))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOfficeTab(),
                _buildLoungeTab(),
                _buildWorkshopTab(),
              ],
            ),
    );
  }

  // ==========================================
  // 1. 💻 ÇALIŞMA ODASI (Modern Ofis & MezatNet)
  // ==========================================
  Widget _buildOfficeTab() {
    final webState = ref.watch(webMarketplaceProvider);
    final isFTUEMarket = ref.watch(ftueProvider) == FTUEStep.marketplaceFirstSale;
    final vipState = ref.watch(vipOrdersProvider);
    final whisper = ref.watch(marketWhisperProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        if (_isMonitorZoomed) {
          // MONİTÖR YAKINLAŞMIŞ DURUMDA: Tam Ekran Web Pazarı Terminali
          return Container(
            color: const Color(0xFF0C0D14),
            child: Column(
              children: [
                // Monitör Üst Çerçevesi & Geri Dön Butonu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF141520),
                    border: Border(bottom: BorderSide(color: GameColors.neonCyan, width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      ArcadeButton(
                        text: 'ODAYA DÖN ↩️',
                        icon: Icons.arrow_back,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _isMonitorZoomed = false);
                        },
                        primaryColor: const Color(0xFF2A2D3A),
                        shadowColor: Colors.black,
                        textColor: Colors.white,
                        height: 32,
                        fontSize: 10,
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.language, color: GameColors.neonCyan, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'MEZATNET v2.4 • GİZLİ WEB AÇIK ARTIRMA PAZARI',
                        style: GameTypography.display(color: GameColors.neonCyan, fontSize: 11),
                      ),
                      const Spacer(),
                      if (whisper.isLampOn)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GameColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: GameColors.gold),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lightbulb, color: GameColors.gold, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '+%${(whisper.priceBonus * 100).toInt()} Fiyat Primi Aktif!',
                                style: const TextStyle(color: GameColors.goldLight, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Web Pazarı İçeriği
                Expanded(
                  child: _buildWebMarketplaceContent(webState, isFTUEMarket),
                ),
              ],
            ),
          );
        }

        // MONİTÖR UZAKTA: Modern Çalışma Odası Sahnesi
        return Stack(
          children: [
            // 1. Modern Ofis Arka Planı (Full Bleed)
            Positioned.fill(
              child: Image.asset(
                GameAssetPaths.bgHomeOffice,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF141722),
                  child: const Center(
                    child: Icon(Icons.computer, color: GameColors.neonCyan, size: 60),
                  ),
                ),
              ),
            ),

            // 2. Masa Lambası Açık İse Işık Parıltısı (Warm Radial Glow)
            if (whisper.isLampOn)
              Positioned(
                left: 0,
                bottom: 0,
                width: w * 0.65,
                height: h * 0.75,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.5, 0.4),
                        radius: 0.8,
                        colors: [
                          const Color(0xFFFFB300).withValues(alpha: 0.28),
                          const Color(0xFFFF8F00).withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Üst Bar: Oda Durumu & Kısayollar
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GameColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.computer, color: GameColors.neonCyan, size: 16),
                        const SizedBox(width: 6),
                        Text('MODERN OFİS & MEZATNET', style: GameTypography.display(color: Colors.white, fontSize: 11)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.white38)),
                        const SizedBox(width: 8),
                        Text(
                          whisper.isLampOn ? '💡 Lamba: AÇIK' : '💡 Lamba: KAPALI',
                          style: TextStyle(
                            color: whisper.isLampOn ? GameColors.goldLight : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Pano Kısayolu
                  ArcadeButton(
                    text: 'VIP PANO 📌 (${vipState.orders.where((o) => !o.isCompleted).length})',
                    icon: Icons.push_pin,
                    onPressed: _showVipOrdersDialog,
                    primaryColor: GameColors.gold,
                    shadowColor: const Color(0xFF8C711C),
                    textColor: Colors.black,
                    height: 32,
                    fontSize: 10,
                  ),
                ],
              ),
            ),

            // 4. Lamba Açık İse Canlı Piyasa Fısıltısı Bildirimi
            if (whisper.isLampOn)
              Positioned(
                top: 52,
                left: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B10).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.gold, width: 1.5),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: GameColors.gold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(whisper.title, style: GameTypography.display(color: GameColors.goldLight, fontSize: 11)),
                            Text(whisper.message, style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 5. İNTERAKTİF MONİTÖR HOTSPOT'U (Geniş Kavisli Monitör)
            Positioned(
              left: w * 0.28,
              top: h * 0.36,
              width: w * 0.38,
              height: h * 0.38,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _isMonitorZoomed = true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GameColors.neonCyan.withValues(alpha: 0.8), width: 2),
                    color: GameColors.neonCyan.withValues(alpha: 0.08),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GameColors.neonCyan, width: 1.5),
                        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search, color: GameColors.neonCyan, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'MEZATNET (${webState.listings.length} İlan) • YAKLAŞ 🔍',
                            style: GameTypography.display(color: GameColors.neonCyan, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 6. İNTERAKTİF MASA LAMBASI HOTSPOT'U (Sol Masa Üstü)
            Positioned(
              left: w * 0.16,
              top: h * 0.42,
              width: w * 0.13,
              height: h * 0.36,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(marketWhisperProvider.notifier).toggleLamp();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: GameColors.gold.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: GameColors.gold),
                      ),
                      child: Text(
                        whisper.isLampOn ? '💡 AÇIK' : '💡 YAK',
                        style: const TextStyle(color: GameColors.goldLight, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 7. İNTERAKTİF DUVARDAKİ MANTAR PANO HOTSPOT'U (Sağ Duvar)
            Positioned(
              right: w * 0.08,
              top: h * 0.08,
              width: w * 0.24,
              height: h * 0.48,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showVipOrdersDialog();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.gold.withValues(alpha: 0.7), width: 2),
                    color: GameColors.gold.withValues(alpha: 0.06),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: GameColors.gold),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📌', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'VIP SİPARİŞLER (${vipState.orders.where((o) => !o.isCompleted).length})',
                            style: GameTypography.display(color: GameColors.goldLight, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 8. FTUE REHBER SPOTLIGHT
            if (isFTUEMarket)
              Positioned(
                left: w * 0.32,
                top: h * 0.26,
                child: const GuideArrowSpotlight(
                  text: 'Monitöre dokunarak Web Pazarına yaklaş ve ilk ilanını ver!',
                ),
              ),
          ],
        );
      },
    );
  }

  /// Web Pazarı İçeriği (Monitör İçi)
  Widget _buildWebMarketplaceContent(WebMarketplaceState webState, bool isFTUEMarket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFTUEMarket) ...[
            const GuideArrowSpotlight(
              text: 'Aşağıdaki Ev Deposundan normal bir eşyayı seçip "İLANA KOY" diyerek ilk satışını başlat. (Büyülü savaş eşyaları korumalıdır, onları satamazsın!)',
            ),
            const SizedBox(height: 8),
          ],

          // İnternet Masası Bilgi Paneli
          DiegeticMetalPanel(
            padding: const EdgeInsets.all(12),
            borderColor: GameColors.neonCyan,
            borderWidth: 2,
            child: Row(
              children: [
                const Icon(Icons.wifi, color: GameColors.neonCyan, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🌐 GİZLİ MÜZAYEDE & WEB PAZARI', style: GameTypography.display(color: Colors.white, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(
                        'Ev Deposundaki eşyaları internete listeleyin. Fiyatı piyasaya göre ayarlayın, geri sayım bitince veya pazarlık tekliflerini kabul edince paranızı tahsil edin!',
                        style: GameTypography.body(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Aktif İlanlar Bölümü
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📡 AKTİF İNTERNET İLANLARI (${webState.listings.length})', style: GameTypography.display(color: GameColors.goldLight, fontSize: 12)),
              if (webState.listings.any((l) => l.isSold || l.pendingOfferPrice != null))
                Text('💰 Alıcılar Hazır!', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),

          if (webState.listings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: const Center(
                child: Text(
                  'Henüz aktif bir internet ilanı yok.\nAşağıdaki Ev Deposundan bir eşyayı seçip ilana koyun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: webState.listings.length,
              itemBuilder: (context, index) {
                final listing = webState.listings[index];
                return _buildListingCard(listing);
              },
            ),

          const SizedBox(height: 18),

          // Ev Deposundan İlana Koyulacak Eşya Seçimi
          Text('📦 EV DEPOSUNDAKİ EŞYALAR (İlana Koymak İçin Dokunun)', style: GameTypography.display(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),

          if (_homeStorageItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Ev deposu boş. Bagajınızdaki eşyaları Atölye sekmesinden aktarın.', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _homeStorageItems.length,
              itemBuilder: (context, index) {
                final item = _homeStorageItems[index];
                final isGear = DungeonEquipmentGuideSheet.isEquipableDungeonGear(item);

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E202B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isGear && isFTUEMarket
                          ? GameColors.gold.withValues(alpha: 0.5)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        item.spritePath,
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(item.nameTr, style: GameTypography.display(color: Colors.white, fontSize: 11)),
                                if (isGear && isFTUEMarket) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: GameColors.gold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: GameColors.gold, width: 0.8),
                                    ),
                                    child: const Text(
                                      '🛡️ BÜYÜLÜ',
                                      style: TextStyle(color: GameColors.goldLight, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text('Taban Değer: ${item.baseValue} ₺', style: GameTypography.body(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                      if (isGear && isFTUEMarket)
                        ArcadeButton(
                          text: '🔒 SATILAMAZ',
                          icon: Icons.shield,
                          onPressed: () => _showProtectedGearExplanationDialog(item),
                          primaryColor: const Color(0xFF3E2723),
                          shadowColor: Colors.black,
                          textColor: GameColors.goldLight,
                          height: 34,
                          fontSize: 10,
                        )
                      else
                        ArcadeButton(
                          text: 'İLANA KOY 💻',
                          icon: Icons.upload_file,
                          onPressed: () => _showCreateListingDialog(item),
                          primaryColor: GameColors.neonCyan,
                          shadowColor: const Color(0xFF00838F),
                          textColor: Colors.black,
                          height: 34,
                          fontSize: 10,
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// 📌 VIP Müşteri Siparişleri Panosu Modalı
  void _showVipOrdersDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final vipState = ref.watch(vipOrdersProvider);

            return Dialog(
              backgroundColor: Colors.transparent,
              child: DiegeticMetalPanel(
                padding: const EdgeInsets.all(16),
                borderColor: GameColors.gold,
                borderWidth: 2,
                glowColor: GameColors.gold,
                borderRadius: 16,
                backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.98),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('📌', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('VIP KOLEKSİYONCU SİPARİŞLERİ', style: GameTypography.display(color: GameColors.goldLight, fontSize: 13)),
                              const Text('Zengin koleksiyoncuların nadir ve efsanevi eşya talepleri. Piyasa değerinin kat kat üzerinde nakit ve itibar kazandırır.', style: TextStyle(color: Colors.white60, fontSize: 10)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white38),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 340,
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: vipState.orders.length,
                        itemBuilder: (context, index) {
                          final order = vipState.orders[index];
                          final matchingItem = _homeStorageItems.where((i) => order.matchesItem(i)).firstOrNull;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: order.isCompleted
                                  ? Colors.black26
                                  : const Color(0xFF1E202B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: order.isCompleted
                                    ? Colors.white10
                                    : (matchingItem != null ? GameColors.profitGreen : Colors.white24),
                                width: matchingItem != null ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(order.clientAvatar, style: const TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${order.clientName} (${order.clientTitle})', style: GameTypography.display(color: Colors.white, fontSize: 11)),
                                          Text('Kategori: ${order.requiredCategory.replaceAll('_', ' ').toUpperCase()} • Min Değer: ${order.minBaseValue} ₺', style: const TextStyle(color: GameColors.goldLight, fontSize: 9)),
                                        ],
                                      ),
                                    ),
                                    if (order.isCompleted)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: GameColors.profitGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                        child: const Text('TESLİM EDİLDİ ✅', style: TextStyle(color: GameColors.profitGreen, fontSize: 9)),
                                      )
                                    else
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('+${order.cashReward} ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 11)),
                                          Text('+${order.xpReward} XP', style: const TextStyle(color: GameColors.gold, fontSize: 9)),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('"${order.requestDescription}"', style: const TextStyle(color: Colors.white70, fontSize: 10, fontStyle: FontStyle.italic)),
                                if (!order.isCompleted) ...[
                                  const SizedBox(height: 8),
                                  if (matchingItem != null)
                                    ArcadeButton(
                                      text: 'EŞYAYI TESLİM ET 🎁 (${matchingItem.nameTr})',
                                      icon: Icons.check_circle,
                                      onPressed: () async {
                                        HapticFeedback.heavyImpact();
                                        final success = ref.read(vipOrdersProvider.notifier).deliverOrder(
                                              orderId: order.id,
                                              item: matchingItem,
                                            );
                                        if (success) {
                                          await ref.read(playerProfileProvider.notifier).removeFromHomeStorage(matchingItem.id);
                                          await _loadAllInventories();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${order.clientName} siparişini teslim aldı! +${order.cashReward} ₺ ve +${order.xpReward} XP kazandınız!'),
                                                backgroundColor: GameColors.profitGreen,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      primaryColor: GameColors.profitGreen,
                                      shadowColor: const Color(0xFF006622),
                                      textColor: Colors.black,
                                      height: 32,
                                      fontSize: 10,
                                    )
                                  else
                                    const Text('⚠️ Ev deponuzda bu siparişe uygun nadir eşya bulunmuyor. Depo müzayedelerinden bulun!', style: TextStyle(color: Colors.white38, fontSize: 9)),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
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

  Widget _buildListingCard(WebListingModel listing) {
    String demandBadgeText;
    Color demandBadgeColor;
    switch (listing.demandLevel) {
      case MarketDemandLevel.high:
        demandBadgeText = '🔥 Çok Yüksek İlgi';
        demandBadgeColor = GameColors.profitGreen;
        break;
      case MarketDemandLevel.normal:
        demandBadgeText = '⚡ Dengeli Piyasa';
        demandBadgeColor = GameColors.gold;
        break;
      case MarketDemandLevel.low:
        demandBadgeText = '⚠️ Yüksek Fiyat (Pazarlık)';
        demandBadgeColor = GameColors.alertOrange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E202B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: listing.isSold
              ? GameColors.profitGreen
              : (listing.pendingOfferPrice != null ? GameColors.gold : GameColors.neonCyan.withValues(alpha: 0.4)),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                listing.item.spritePath,
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.item.nameTr, style: GameTypography.display(color: Colors.white, fontSize: 11)),
                    Text(
                      'İlan Fiyatı: ${listing.listingPrice} ₺ (Taban: ${listing.item.baseValue} ₺)',
                      style: GameTypography.body(color: Colors.white60, fontSize: 9),
                    ),
                  ],
                ),
              ),
              if (listing.isSold)
                ArcadeButton(
                  text: 'PARAYI AL 💰',
                  icon: Icons.check,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    ref.read(webMarketplaceProvider.notifier).claimSale(listing.id);
                    _handleFTUESaleCompleted();
                  },
                  primaryColor: GameColors.profitGreen,
                  shadowColor: const Color(0xFF006622),
                  textColor: Colors.black,
                  height: 32,
                  fontSize: 10,
                )
              else if (listing.pendingOfferPrice == null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: demandBadgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: demandBadgeColor, width: 1),
                      ),
                      child: Text(
                        demandBadgeText,
                        style: TextStyle(color: demandBadgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.close, color: GameColors.lossRed, size: 18),
                      tooltip: 'İlanı Geri Al',
                      onPressed: () {
                        ref.read(webMarketplaceProvider.notifier).cancelListing(listing.id);
                        _loadAllInventories();
                      },
                    ),
                  ],
                ),
            ],
          ),

          // Satış Onay veya Teşekkür Mesajı
          if (listing.isSold && listing.offerCustomerName != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GameColors.profitGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GameColors.profitGreen.withValues(alpha: 0.5)),
              ),
              child: Text(
                '${listing.offerCustomerName}: "${listing.offerMessage ?? 'Satın aldım, teşekkürler!'}"',
                style: GameTypography.body(color: Colors.white, fontSize: 10).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],

          // Canlı Pazarlık Teklifi Bildirimi (Replikli & Alıcılı)
          if (listing.pendingOfferPrice != null && !listing.isSold) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GameColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GameColors.gold, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.forum, color: GameColors.gold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${listing.offerCustomerName} Pazarlık Teklifi:',
                        style: GameTypography.display(color: GameColors.goldLight, fontSize: 10),
                      ),
                      const Spacer(),
                      Text(
                        '${listing.pendingOfferPrice} ₺',
                        style: GameTypography.led(color: GameColors.profitGreen, fontSize: 13),
                      ),
                    ],
                  ),
                  if (listing.offerMessage != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      '"${listing.offerMessage}"',
                      style: GameTypography.body(color: Colors.white, fontSize: 10).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ArcadeButton(
                        text: 'REDDET',
                        icon: Icons.close,
                        onPressed: () {
                          ref.read(webMarketplaceProvider.notifier).rejectOffer(listing.id);
                        },
                        primaryColor: GameColors.lossRed,
                        shadowColor: const Color(0xFF8E0000),
                        textColor: Colors.white,
                        height: 28,
                        fontSize: 9,
                      ),
                      const SizedBox(width: 8),
                      ArcadeButton(
                        text: 'KABUL ET (${listing.pendingOfferPrice} ₺)',
                        icon: Icons.check,
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          ref.read(webMarketplaceProvider.notifier).acceptOffer(listing.id);
                          _handleFTUESaleCompleted();
                        },
                        primaryColor: GameColors.profitGreen,
                        shadowColor: const Color(0xFF006622),
                        textColor: Colors.black,
                        height: 28,
                        fontSize: 9,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleFTUESaleCompleted() {
    if (ref.read(ftueProvider) == FTUEStep.marketplaceFirstSale) {
      _showFTUESaleCelebrationDialog();
    }
  }

  /// FTUE Tamamlandı Kutlama Modalı
  void _showFTUECompletedCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: DiegeticMetalPanel(
          padding: const EdgeInsets.all(20),
          borderColor: GameColors.gold,
          borderWidth: 2.5,
          glowColor: GameColors.gold,
          borderRadius: 16,
          backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.98),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: GameColors.gold, size: 54),
              const SizedBox(height: 12),
              Text(
                'TEBRİKLER! REHBERİ TAMAMLADINIZ! 🏆',
                style: GameTypography.display(
                  color: GameColors.goldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'İlk müzayedeni kazandın, eşyaları istifledin, internet pazarında satıp paranı kazandın, Han\'dan paralı asker kiraladın ve ona kadim savaş ekipmanını kuşandın!\n\nArtık tüm şehir emrinde. Canlı Depo Mezatına giderek imparatorluğunu kurmaya başlayabilir veya otomatik zindan seferlerine çıkabilirsin!',
                style: GameTypography.body(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ArcadeButton(
                text: 'ŞEHİR HARİTASINA GEÇ 🗺️',
                icon: Icons.map,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                primaryColor: GameColors.profitGreen,
                shadowColor: const Color(0xFF00893E),
                textColor: Colors.black,
                height: 44,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateListingDialog(ItemModel item) {
    if (ref.read(ftueProvider) == FTUEStep.marketplaceFirstSale &&
        DungeonEquipmentGuideSheet.isEquipableDungeonGear(item)) {
      _showProtectedGearExplanationDialog(item);
      return;
    }

    double markup = 1.0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final targetPrice = (item.baseValue * markup).round();
          final demand = WebListingModel.calculateDemandLevel(
            baseValue: item.baseValue,
            listingPrice: targetPrice,
          );
          String demandText;
          Color demandColor;
          if (markup <= 0.85) {
            demandText = '🔥 Kelepir Fiyat • Anında Satılır!';
            demandColor = GameColors.profitGreen;
          } else if (demand == MarketDemandLevel.high || demand == MarketDemandLevel.normal) {
            demandText = '⚡ Dengeli Fiyat • Hızlı Teklifler Gelir';
            demandColor = GameColors.gold;
          } else {
            demandText = '⚠️ Yüksek Fiyat • Bot Müşteriler Pazarlık Yapar';
            demandColor = GameColors.alertOrange;
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1B1D26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: GameColors.neonCyan, width: 2),
            ),
            title: Text('🌐 İNTERNET İLANI OLUŞTUR', style: GameTypography.display(color: Colors.white, fontSize: 13)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.nameTr, style: GameTypography.display(color: GameColors.gold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Taban Değeri: ${item.baseValue} ₺', style: GameTypography.body(color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fiyat Çarpanı: %${(markup * 100).toInt()}', style: GameTypography.display(color: Colors.white, fontSize: 11)),
                    Text('$targetPrice ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 14)),
                  ],
                ),
                Slider(
                  value: markup,
                  min: 0.5,
                  max: 2.5,
                  divisions: 20,
                  activeColor: GameColors.neonCyan,
                  onChanged: (val) => setDlgState(() => markup = val),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: demandColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: demandColor, width: 1),
                  ),
                  child: Text(
                    demandText,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: demandColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'İpucu: Taban fiyata yakın tutarsanız alıcılar daha çabuk çıkar. Fiyatı çok artırırsanız müşteriler replikleriyle daha düşük pazarlık teklifleri sunar.',
                  style: GameTypography.body(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
              ),
              ArcadeButton(
                text: 'YAYINLA 🚀',
                icon: Icons.send,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(playerProfileProvider.notifier).removeFromHomeStorage(item.id);
                  ref.read(webMarketplaceProvider.notifier).createListing(
                        item: item,
                        listingPrice: targetPrice,
                      );
                  await _loadAllInventories();
                },
                primaryColor: GameColors.neonCyan,
                shadowColor: const Color(0xFF00838F),
                textColor: Colors.black,
                height: 36,
                fontSize: 11,
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 2. 🛌 DİNLENME ODASI (Lounge & Auto-Expedition - %100 Görsel & Tıklanabilir)
  // ==========================================
  Widget _buildLoungeTab() {
    final dungeonState = ref.watch(dungeonProvider);
    final profile = ref.watch(playerProfileProvider);
    final ftue = ref.watch(ftueProvider);
    final mercs = dungeonState.mercenaries;

    String baseImage = mercs.isNotEmpty ? _getMercenaryBedAsset(mercs[0].role) : GameAssetPaths.bgBarracksEmpty;
    String? rightMercImage = mercs.length >= 2 ? _getMercenaryBedAsset(mercs[1].role) : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // 1. SOL YATAK & ANA ODA ZEMİNİ (Tam Ekran Görsel)
            Positioned.fill(
              child: Image.asset(
                baseImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF161822),
                  child: const Center(
                    child: Icon(Icons.hotel, color: GameColors.gold, size: 60),
                  ),
                ),
              ),
            ),

            // 2. SAĞ YATAK İÇİN 2. ASKER (Sağ yarıya aynalanmış görsel)
            if (rightMercImage != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: w * 0.5,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerRight,
                    minWidth: w,
                    maxWidth: w,
                    minHeight: h,
                    maxHeight: h,
                    child: Transform.scale(
                      scaleX: -1,
                      child: Image.asset(
                        rightMercImage,
                        fit: BoxFit.cover,
                        width: w,
                        height: h,
                      ),
                    ),
                  ),
                ),
              ),

            // 3. SİNEMATİK VİGNETTE VE KARARTMA
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 4. İNTERAKTİF DOKUNMA ALANI (SOL RANZA / 1. ASKER)
            Positioned(
              left: 0,
              top: 0,
              width: w * 0.5,
              bottom: 0,
              child: _buildBedInteractiveArea(
                slotIndex: 0,
                merc: mercs.isNotEmpty ? mercs[0] : null,
                dungeonState: dungeonState,
                isLeft: true,
                isFTUEHighlight: ftue == FTUEStep.restRoomEquip || (ftue == FTUEStep.tavernHiring && mercs.isEmpty),
              ),
            ),

            // 5. İNTERAKTİF DOKUNMA ALANI (SAĞ RANZA / 2. ASKER)
            Positioned(
              right: 0,
              top: 0,
              width: w * 0.5,
              bottom: 0,
              child: _buildBedInteractiveArea(
                slotIndex: 1,
                merc: mercs.length >= 2 ? mercs[1] : null,
                dungeonState: dungeonState,
                isLeft: false,
                isFTUEHighlight: false,
              ),
            ),

            // 6. ÜST DIEGETIC ODA BİLGİ VE KISAYOL ÇUBUĞU
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  // Kapasite & Konfor Göstergesi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GameColors.gold.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hotel, color: GameColors.gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Kapasite: ${mercs.length} / ${profile.maxMercenaryCapacity}',
                          style: GameTypography.display(color: Colors.white, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.white38)),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: GameColors.goldLight, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Konfor: ${dungeonState.lounge.totalComfortScore}',
                          style: GameTypography.body(color: GameColors.goldLight, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Aktif Sefer Sürüyorsa Canlı Gösterge
                  if (dungeonState.activeExpedition != null) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2410C).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GameColors.gold, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            'SEFER SÜRÜYOR: ${dungeonState.activeExpedition!.remainingSeconds}s',
                            style: GameTypography.display(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Han Kısayolu Butonu
                  ArcadeButton(
                    text: 'HAN 🍺',
                    icon: Icons.local_bar,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TavernScreen()),
                      );
                    },
                    primaryColor: GameColors.gold,
                    shadowColor: const Color(0xFF8C711C),
                    textColor: Colors.black,
                    height: 32,
                    fontSize: 10,
                  ),
                  const SizedBox(width: 8),
                  // Zindan Komuta Merkezi
                  ArcadeButton(
                    text: 'ZİNDANLAR ⚔️',
                    icon: Icons.castle,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DungeonHubScreen()),
                      );
                    },
                    primaryColor: const Color(0xFFB91C1C),
                    shadowColor: const Color(0xFF7F1D1D),
                    textColor: Colors.white,
                    height: 32,
                    fontSize: 10,
                  ),
                ],
              ),
            ),

            // 7. FTUE REHBER SPOTLIGHT
            if (ftue == FTUEStep.restRoomEquip && mercs.isNotEmpty)
              Positioned(
                left: 30,
                bottom: 85,
                child: const GuideArrowSpotlight(
                  text: 'Savaşçına dokun ve açılan menüden büyülü eşyayı kuşan!',
                ),
              ),
            if (ftue == FTUEStep.tavernHiring && mercs.isEmpty)
              Positioned(
                left: 30,
                bottom: 85,
                child: const GuideArrowSpotlight(
                  text: 'Ranzaya dokunarak veya üstteki HAN butonundan ilk savaşçını kirala!',
                ),
              ),
          ],
        );
      },
    );
  }

  /// Ranza & Karakter İnteraktif Dokunma Alanı
  Widget _buildBedInteractiveArea({
    required int slotIndex,
    required MercenaryModel? merc,
    required DungeonState dungeonState,
    required bool isLeft,
    required bool isFTUEHighlight,
  }) {
    final hasMerc = merc != null;
    String statusLabel = 'BOŞ RANZA';
    Color statusColor = Colors.white54;
    IconData statusIcon = Icons.bed;

    if (hasMerc) {
      if (merc.status == MercenaryStatus.ready) {
        statusLabel = 'HAZIR';
        statusColor = GameColors.profitGreen;
        statusIcon = Icons.check_circle_outline;
      } else if (merc.status == MercenaryStatus.onExpedition) {
        statusLabel = 'SEFERDE';
        statusColor = GameColors.alertOrange;
        statusIcon = Icons.explore;
      } else {
        statusLabel = 'DİNLENİYOR (${merc.restTimeRemainingSeconds}s)';
        statusColor = GameColors.hazardYellow;
        statusIcon = Icons.bedtime;
      }
    }

    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (hasMerc) {
          _showMercenaryActionModal(merc);
        } else {
          _showEmptyBedModal(slotIndex);
        }
      },
      splashColor: GameColors.gold.withValues(alpha: 0.15),
      highlightColor: GameColors.gold.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFTUEHighlight
                      ? GameColors.gold
                      : (hasMerc ? statusColor : Colors.white24),
                  width: isFTUEHighlight ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isFTUEHighlight
                        ? GameColors.gold.withValues(alpha: 0.4)
                        : Colors.black87,
                    blurRadius: isFTUEHighlight ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLeft) ...[
                        Text(
                          hasMerc ? merc.name : 'Ranza #${slotIndex + 1}',
                          style: GameTypography.display(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(hasMerc ? merc.avatar : '🛌', style: const TextStyle(fontSize: 20)),
                      ] else ...[
                        Text(hasMerc ? merc.avatar : '🛌', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          hasMerc ? merc.name : 'Ranza #${slotIndex + 1}',
                          style: GameTypography.display(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GameTypography.display(color: statusColor, fontSize: 10),
                      ),
                      if (hasMerc) ...[
                        const SizedBox(width: 6),
                        Text('• ${merc.role}', style: const TextStyle(color: Colors.white60, fontSize: 10)),
                        const SizedBox(width: 6),
                        Text('${merc.totalCombatPower} CP', style: const TextStyle(color: GameColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: GameColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app, color: GameColors.goldLight, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          hasMerc ? 'DOKUN VE YÖNET 👆' : 'ASKER KİRALA 🍺',
                          style: GameTypography.display(color: GameColors.goldLight, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Boş Ranza Tıklama Modalı
  void _showEmptyBedModal(int slotIndex) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: DiegeticMetalPanel(
          padding: const EdgeInsets.all(18),
          borderColor: GameColors.gold,
          borderWidth: 2,
          glowColor: GameColors.gold,
          borderRadius: 16,
          backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.98),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛌', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                'BOŞ RANZA (SLOT ${slotIndex + 1})',
                style: GameTypography.display(color: GameColors.goldLight, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu yatak şu anda boş. Kara Ejder Hanı\'na giderek kiralayacağınız yeni savaşçılar doğrudan bu odaya yerleşir ve zindanlara sefere çıkar.',
                textAlign: TextAlign.center,
                style: GameTypography.body(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('KAPAT', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  ArcadeButton(
                    text: 'HANA GİT 🍺',
                    icon: Icons.local_bar,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TavernScreen()),
                      );
                    },
                    primaryColor: GameColors.gold,
                    shadowColor: const Color(0xFF8C711C),
                    textColor: Colors.black,
                    height: 38,
                    fontSize: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Asker Üzerine Tıklandığında Açılan Diegetik Aksiyon Menüsü
  void _showMercenaryActionModal(MercenaryModel merc) {
    final dungeonState = ref.read(dungeonProvider);
    final isReady = merc.status == MercenaryStatus.ready;
    final isOnExpedition = merc.status == MercenaryStatus.onExpedition;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: DiegeticMetalPanel(
          padding: const EdgeInsets.all(18),
          borderColor: isReady ? GameColors.profitGreen : GameColors.gold,
          borderWidth: 2,
          glowColor: isReady ? GameColors.profitGreen : null,
          borderRadius: 16,
          backgroundColor: const Color(0xFF14141E).withValues(alpha: 0.98),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Karakter Özeti
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GameColors.gold, width: 1.5),
                    ),
                    child: Text(merc.avatar, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(merc.name, style: GameTypography.display(color: Colors.white, fontSize: 14)),
                        Text('${merc.role} • ${merc.totalCombatPower} CP Güç', style: GameTypography.body(color: GameColors.goldLight, fontSize: 11)),
                        Text('Kuşanılan Eşya: ${merc.equippedItems.length} adet', style: GameTypography.body(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isReady
                          ? GameColors.profitGreen.withValues(alpha: 0.2)
                          : (isOnExpedition
                              ? GameColors.alertOrange.withValues(alpha: 0.2)
                              : GameColors.hazardYellow.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isReady
                            ? GameColors.profitGreen
                            : (isOnExpedition ? GameColors.alertOrange : GameColors.hazardYellow),
                      ),
                    ),
                    child: Text(
                      isReady ? 'HAZIR' : (isOnExpedition ? 'SEFERDE' : 'DİNLENİYOR'),
                      style: GameTypography.display(
                        color: isReady
                            ? GameColors.profitGreen
                            : (isOnExpedition ? GameColors.alertOrange : GameColors.hazardYellow),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),

              // Aksiyon 1: Ekipman Donat
              ArcadeButton(
                text: '🛡️ EKİPMAN DONAT / DEĞİŞTİR (${merc.equippedItems.length} Kuşandı)',
                icon: Icons.shield,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showEquipMercenaryDialog(merc);
                },
                primaryColor: GameColors.gold,
                shadowColor: const Color(0xFF8C711C),
                textColor: Colors.black,
                height: 40,
                fontSize: 11,
              ),
              const SizedBox(height: 10),

              // Aksiyon 2: Hızlı Sefer Başlatma (Eğer Hazırsa)
              if (isReady && dungeonState.activeExpedition == null) ...[
                Text('⚔️ HIZLI SEFERE GÖNDER:', style: GameTypography.display(color: GameColors.goldLight, fontSize: 11)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E202B),
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(dungeonProvider.notifier).startExpedition(
                                mercenaryId: merc.id,
                                dungeonName: 'Karanlık Madenler',
                                dungeonDifficulty: 60,
                                durationSeconds: 20,
                              );
                        },
                        child: const Column(
                          children: [
                            Text('Maden (Lvl 1)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('60 CP • 20s', style: TextStyle(color: Colors.white54, fontSize: 8)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E202B),
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(dungeonProvider.notifier).startExpedition(
                                mercenaryId: merc.id,
                                dungeonName: 'Gölgeli Mahzen',
                                dungeonDifficulty: 120,
                                durationSeconds: 35,
                              );
                        },
                        child: const Column(
                          children: [
                            Text('Mahzen (Lvl 2)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('120 CP • 35s', style: TextStyle(color: Colors.white54, fontSize: 8)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E202B),
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(dungeonProvider.notifier).startExpedition(
                                mercenaryId: merc.id,
                                dungeonName: 'Taktik Sığınak',
                                dungeonDifficulty: 220,
                                durationSeconds: 50,
                              );
                        },
                        child: const Column(
                          children: [
                            Text('Sığınak (Lvl 3)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('220 CP • 50s', style: TextStyle(color: Colors.white54, fontSize: 8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ] else if (isOnExpedition) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GameColors.alertOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GameColors.alertOrange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.explore, color: GameColors.alertOrange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Savaşçı şu an zindan seferinde! Döndüğünde topladığı ganimetler doğrudan ev deposuna aktarılacak.',
                          style: GameTypography.body(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GameColors.hazardYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GameColors.hazardYellow),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bedtime, color: GameColors.hazardYellow, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Savaşçı dinleniyor (${merc.restTimeRemainingSeconds} sn kaldı). Dinlenme bitince yeni sefere hazır olacak.',
                          style: GameTypography.body(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Aksiyon 3: Zindan Komuta Merkezine Git
              TextButton.icon(
                icon: const Icon(Icons.castle, color: GameColors.neonCyan, size: 16),
                label: const Text('Tüm Zindan Haritasını İncele 🗺️', style: TextStyle(color: GameColors.neonCyan, fontSize: 11)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DungeonHubScreen()),
                  );
                },
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('KAPAT', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMercenaryBedAsset(String role) {
    final r = role.toLowerCase();
    if (r.contains('savaşçı') || r.contains('tank') || r.contains('barbar')) {
      return GameAssetPaths.bgBarracksWarrior;
    } else if (r.contains('suikastçı') || r.contains('hırsız') || r.contains('asas') || r.contains('rogue')) {
      return GameAssetPaths.bgBarracksAssassin;
    } else if (r.contains('okçu') || r.contains('avcı') || r.contains('ranger')) {
      return GameAssetPaths.bgBarracksArcher;
    } else if (r.contains('büyücü') || r.contains('mage') || r.contains('simyager')) {
      return GameAssetPaths.bgBarracksMage;
    } else {
      return GameAssetPaths.bgBarracksKnight;
    }
  }

  void _showEquipMercenaryDialog(MercenaryModel merc) {
    showDialog(
      context: context,
      builder: (ctx) {
        final equipable = _homeStorageItems.where((i) => DungeonEquipmentGuideSheet.isEquipableDungeonGear(i)).toList();

        return AlertDialog(
          backgroundColor: const Color(0xFF1B1D26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: GameColors.gold, width: 2),
          ),
          title: Text('${merc.name} Donat', style: GameTypography.display(color: GameColors.gold, fontSize: 13)),
          content: SizedBox(
            width: double.maxFinite,
            child: equipable.isEmpty
                ? const Text('Ev Deposunda kuşanılabilir silah veya zırh bulunmuyor.', style: TextStyle(color: Colors.white60, fontSize: 11))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: equipable.length,
                    itemBuilder: (itemCtx, index) {
                      final item = equipable[index];
                      return ListTile(
                        leading: Image.asset(item.spritePath, width: 32, height: 32, fit: BoxFit.contain),
                        title: Text(item.nameTr, style: GameTypography.display(color: Colors.white, fontSize: 11)),
                        subtitle: Text('+${(item.baseValue * 0.5).round()} CP Güç', style: const TextStyle(color: GameColors.profitGreen, fontSize: 10)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: GameColors.gold),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await ref.read(playerProfileProvider.notifier).removeFromHomeStorage(item.id);
                            ref.read(dungeonProvider.notifier).equipItemToMercenary(merc.id, item);
                            await _loadAllInventories();

                            if (ref.read(ftueProvider) == FTUEStep.restRoomEquip) {
                              ref.read(ftueProvider.notifier).setStep(FTUEStep.completed);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tebrikler! Savaşçın büyülü ekipmanı kuşandı ve gücüne güç kattı!'),
                                    backgroundColor: GameColors.profitGreen,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                              Future.delayed(const Duration(milliseconds: 600), () {
                                if (mounted) {
                                  _showFTUECompletedCelebrationDialog();
                                }
                              });
                            }
                          },
                          child: const Text('KUŞAN', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }


  // ==========================================
  // 3. 🛠️ ATÖLYE & EV DEPOSU (Workshop & Storage)
  // ==========================================
  Widget _buildWorkshopTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Atölye & Depo İllüstrasyon Başlığı
          Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameColors.panelBorder, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                GameAssetPaths.bgHomeWorkshop,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.build_circle, color: GameColors.gold, size: 40),
                ),
              ),
            ),
          ),

          // Craft Masaları Buton Çubuğu
          Row(
            children: [
              Expanded(
                child: ArcadeButton(
                  text: 'TEMİZLEME 🧽',
                  icon: Icons.cleaning_services,
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CraftingBenchScreen(initialTab: 0)));
                    _loadAllInventories();
                  },
                  primaryColor: GameColors.neonCyan,
                  shadowColor: const Color(0xFF00838F),
                  textColor: Colors.black,
                  height: 38,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ArcadeButton(
                  text: 'RESTORASYON 🛠️',
                  icon: Icons.build,
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CraftingBenchScreen(initialTab: 1)));
                    _loadAllInventories();
                  },
                  primaryColor: GameColors.gold,
                  shadowColor: const Color(0xFF8C711C),
                  textColor: Colors.black,
                  height: 38,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ArcadeButton(
                  text: 'EKSPERTİZ 🔍',
                  icon: Icons.search,
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CraftingBenchScreen(initialTab: 2)));
                    _loadAllInventories();
                  },
                  primaryColor: GameColors.profitGreen,
                  shadowColor: const Color(0xFF006622),
                  textColor: Colors.black,
                  height: 38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // İki Yönlü Eşya Transfer Kontrolü
          DiegeticMetalPanel(
            padding: const EdgeInsets.all(12),
            borderColor: GameColors.panelBorder,
            borderWidth: 1.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (ref.watch(ftueProvider) == FTUEStep.homeInventoryTransfer && _trunkItems.isNotEmpty) ...[
                  const GuideArrowSpotlight(
                    text: 'Tüm bagajı tek tıkla Ev Deposuna aktarmak için "HEPSİNİ AKTAR" butonuna bas!',
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🚚 ARAÇ BAGAJI (${_trunkItems.length} Eşya)', style: GameTypography.display(color: GameColors.hazardYellow, fontSize: 11)),
                    ArcadeButton(
                      text: 'HEPSİNİ AKTAR ➡️',
                      icon: Icons.move_to_inbox,
                      onPressed: _trunkItems.isNotEmpty
                          ? () async {
                              await _transferAllTrunkToHome();
                              if (ref.read(ftueProvider) == FTUEStep.homeInventoryTransfer) {
                                ref.read(ftueProvider.notifier).setStep(FTUEStep.marketplaceFirstSale);
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    _tabController.animateTo(0); // 💻 Çalışma Odası (Web Pazar)
                                  }
                                });
                              }
                            }
                          : null,
                      primaryColor: _trunkItems.isNotEmpty ? GameColors.profitGreen : Colors.grey,
                      shadowColor: const Color(0xFF006622),
                      textColor: Colors.black,
                      height: 32,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('İpucu: Bagajdaki eşyaya ÇİFT TIKLAYARAK doğrudan depoya aktarabilirsiniz.', style: GameTypography.body(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 8),

                // Bagaj Eşyaları Yatay Listesi
                if (_trunkItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Araç kasasında eşya yok.', style: TextStyle(color: Colors.white30, fontSize: 11)),
                  )
                else
                  SizedBox(
                    height: 64,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trunkItems.length,
                      itemBuilder: (context, index) {
                        final item = _trunkItems[index];
                        return GestureDetector(
                          onDoubleTap: () => _transferSingleTrunkToHome(item),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GameColors.hazardYellow.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(item.spritePath, width: 28, height: 28, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber, size: 20)),
                                Text(item.nameTr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 8)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // FTUE Büyülü Eşya Vurgulama
          if (ref.watch(ftueProvider) == FTUEStep.gearAndNpcIntro) ...[
            const GuideArrowSpotlight(
              text: 'Depodan çıkan büyülü savaş eşyasının üzerine dokunarak incele!',
            ),
            const SizedBox(height: 8),
          ],

          // Sınırsız Ev Deposu Başlığı ve Izgarası
          Text('🏛️ SINIRSIZ EV DEPOSU (${_homeStorageItems.length} Eşya)', style: GameTypography.display(color: GameColors.goldLight, fontSize: 12)),
          const SizedBox(height: 4),
          Text('İpucu: Depodaki eşyaya ÇİFT TIKLAYARAK araca yükleyebilirsiniz.', style: GameTypography.body(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 8),

          if (_homeStorageItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: const Center(
                child: Text('Ev Deposunda eşya yok.', style: TextStyle(color: Colors.white38)),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _homeStorageItems.length,
              itemBuilder: (context, index) {
                final item = _homeStorageItems[index];
                final isGear = DungeonEquipmentGuideSheet.isEquipableDungeonGear(item);
                final isFTUEGear = isGear && ref.watch(ftueProvider) == FTUEStep.gearAndNpcIntro;

                return GestureDetector(
                  onTap: () {
                    if (isFTUEGear) {
                      _showMagicGearDialogue(item);
                    }
                  },
                  onDoubleTap: () => _transferSingleHomeToTrunk(item),
                  child: DiegeticMetalPanel(
                    padding: const EdgeInsets.all(6),
                    borderColor: isFTUEGear
                        ? GameColors.gold
                        : (isGear ? GameColors.neonCyan : GameColors.panelBorder),
                    borderWidth: isFTUEGear ? 2.5 : (isGear ? 1.5 : 1),
                    glowColor: isFTUEGear ? GameColors.gold : (isGear ? GameColors.neonCyan : null),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              item.spritePath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber, size: 28),
                            ),
                          ),
                        ),
                        Text(
                          item.nameTr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GameTypography.display(color: Colors.white, fontSize: 9),
                        ),
                        Text(
                          '${item.currentValue} ₺',
                          style: GameTypography.led(color: GameColors.profitGreen, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}


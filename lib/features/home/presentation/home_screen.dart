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
import 'package:yeni_oyun_sablon/features/dungeon/presentation/widgets/dungeon_equipment_guide_sheet.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/marketplace/models/web_listing_model.dart';
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

  @override
  void initState() {
    super.initState();

    // FTUE başlangıç sekmesi kontrolü
    int startTab = widget.initialTabIndex;
    final ftue = ref.read(ftueProvider);
    if (ftue == FTUEStep.homeInventoryTransfer) {
      startTab = 2; // Atölye & Depo
    } else if (ftue == FTUEStep.gearAndNpcIntro || ftue == FTUEStep.restRoomEquip) {
      startTab = 1; // Dinlenme Odası
    } else if (ftue == FTUEStep.marketplaceFirstSale) {
      startTab = 0; // Çalışma Odası
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
  // 1. 💻 ÇALIŞMA ODASI (PC Web Marketplace)
  // ==========================================
  Widget _buildOfficeTab() {
    final webState = ref.watch(webMarketplaceProvider);
    final isFTUEMarket = ref.watch(ftueProvider) == FTUEStep.marketplaceFirstSale;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFTUEMarket) ...[
            const GuideArrowSpotlight(
              text: 'Çalışma Odasına hoş geldin! Aşağıdaki Ev Deposundan bir eşyayı seçip "İLANA KOY" diyerek ilk satışını başlat.',
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E202B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Image.asset(item.spritePath, width: 36, height: 36, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nameTr, style: GameTypography.display(color: Colors.white, fontSize: 11)),
                            Text('Taban Değer: ${item.baseValue} ₺', style: GameTypography.body(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
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
      ref.read(ftueProvider.notifier).setStep(FTUEStep.completed);
      _showFTUECompletedCelebrationDialog();
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
                'İlk müzayedeni kazandın, eşyaları istifledin, büyülü savaş ekipmanı kuşanıp paralı asker tuttun ve ilk internet satışını yaptın!\n\nArtık tüm şehir emrinde. Canlı Depo Mezatına giderek imparatorluğunu kurmaya başlayabilirsin!',
                style: GameTypography.body(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ArcadeButton(
                text: 'ŞEHİR HARİTASINA GEÇ 🗺️',
                icon: Icons.map,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // Şehir Haritasına dön
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
  // 2. 🛌 DİNLENME ODASI (Lounge & Auto-Expedition)
  // ==========================================
  Widget _buildLoungeTab() {
    final dungeonState = ref.watch(dungeonProvider);
    final profile = ref.watch(playerProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Konfor ve Kapasite Bilgi Paneli
          DiegeticMetalPanel(
            padding: const EdgeInsets.all(12),
            borderColor: GameColors.gold,
            borderWidth: 2,
            child: Row(
              children: [
                const Icon(Icons.bed, color: GameColors.gold, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🛌 KIŞLA & DİNLENME ODASI', style: GameTypography.display(color: Colors.white, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(
                        'Kapasite: ${dungeonState.mercenaries.length} / ${profile.maxMercenaryCapacity} Asker • Konfor Skoru: ${dungeonState.lounge.totalComfortScore}',
                        style: GameTypography.body(color: GameColors.goldLight, fontSize: 11),
                      ),
                      Text(
                        'Seferden dönen askerler ganimetleri DOĞRUDAN Ev Deposuna getirir (Altın yok, eşya ganimeti).',
                        style: GameTypography.body(color: Colors.white60, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dinlenme Odası 2-Slotlu Görsel Ranza Ortamı
          _buildBarracksVisualRoom(dungeonState),

          // Paralı Asker Listesi
          Text('🛡️ KARARGAHTAKİ ASKERLER', style: GameTypography.display(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),

          if (dungeonState.mercenaries.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.group_off, color: Colors.white30, size: 40),
                    const SizedBox(height: 8),
                    Text('Henüz paralı askeriniz yok!', style: GameTypography.display(color: Colors.white, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Şehir Haritasındaki HAN (Tavern) binasına giderek yeni askerler kiralayın.', textAlign: TextAlign.center, style: GameTypography.body(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 12),
                    if (ref.watch(ftueProvider) == FTUEStep.tavernHiring)
                      const GuideArrowSpotlight(
                        text: 'Dinlenme odan henüz boş! Kara Ejder Hanı\'na git ve ilk savaşçını kirala.',
                      ),
                    const SizedBox(height: 8),
                    ArcadeButton(
                      text: 'KARA EJDER HANI\'NA GİT 🍺',
                      icon: Icons.local_bar,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TavernScreen()),
                        );
                      },
                      primaryColor: GameColors.gold,
                      shadowColor: const Color(0xFF8C711C),
                      textColor: Colors.black,
                      height: 40,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (ref.watch(ftueProvider) == FTUEStep.restRoomEquip) ...[
              const GuideArrowSpotlight(
                text: 'Yeni kiraladığın askere "EKİPMAN VER" diyerek depodaki büyülü eşyayı giydir!',
              ),
              const SizedBox(height: 8),
            ],
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dungeonState.mercenaries.length,
              itemBuilder: (context, index) {
                final merc = dungeonState.mercenaries[index];
                return _buildMercenaryCard(merc);
              },
            ),
          ],

          const SizedBox(height: 18),

          // Otomatik Sefer Başlatma Butonları
          Text('🗺️ OTOMATİK ZİNDAN SEFERLERİ', style: GameTypography.display(color: GameColors.goldLight, fontSize: 12)),
          const SizedBox(height: 8),

          _buildExpeditionButton(
            name: 'Karanlık Madenler (Seviye 1)',
            difficulty: 60,
            duration: 20,
            dungeonState: dungeonState,
          ),
          const SizedBox(height: 6),
          _buildExpeditionButton(
            name: 'Gölgeli Mahzen (Seviye 2)',
            difficulty: 120,
            duration: 35,
            dungeonState: dungeonState,
          ),
          const SizedBox(height: 6),
          _buildExpeditionButton(
            name: 'Taktik Sığınak Harabeleri (Seviye 3)',
            difficulty: 220,
            duration: 50,
            dungeonState: dungeonState,
          ),
        ],
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

  Widget _buildBarracksVisualRoom(DungeonState dungeonState) {
    final mercs = dungeonState.mercenaries;

    String baseImage = GameAssetPaths.bgBarracksEmpty;
    String? rightMercImage;

    if (mercs.isNotEmpty) {
      baseImage = _getMercenaryBedAsset(mercs[0].role);
    }
    if (mercs.length >= 2) {
      rightMercImage = _getMercenaryBedAsset(mercs[1].role);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.panelBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: [
                // 1. Sol Yatak & Ana Oda: Her zaman orijinal, sol tarafa asla dokunulmaz
                Positioned.fill(
                  child: Image.asset(
                    baseImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.bed, color: GameColors.gold, size: 40),
                    ),
                  ),
                ),

                // 2. Sağ Yatak İçin 2. Asker: SADECE sağ yarının üzerine aynalanmış görüntü
                if (rightMercImage != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: w * 0.5, // Sadece sağ yarının alanı
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerRight,
                        minWidth: w,
                        maxWidth: w,
                        minHeight: h,
                        maxHeight: h,
                        child: Transform.scale(
                          scaleX: -1, // Yatay aynalama ile sol yatak sağ yatağın üzerine gelir
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

            // Üst durum çubuğu / slot rozetleri
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol Yatak Slot 1
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: mercs.isNotEmpty ? GameColors.profitGreen : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mercs.isNotEmpty ? Icons.bedtime : Icons.bed,
                          color: mercs.isNotEmpty ? GameColors.profitGreen : Colors.white38,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mercs.isNotEmpty
                              ? '1: ${mercs[0].name.split(' ').first} (${mercs[0].status == MercenaryStatus.onExpedition ? "ZİNDANDA" : "DİNLENİYOR"})'
                              : '1: BOŞ RANZA',
                          style: GameTypography.display(
                            color: mercs.isNotEmpty ? GameColors.profitGreen : Colors.white54,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sağ Yatak Slot 2
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: mercs.length >= 2 ? GameColors.profitGreen : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mercs.length >= 2 ? Icons.bedtime : Icons.bed,
                          color: mercs.length >= 2 ? GameColors.profitGreen : Colors.white38,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mercs.length >= 2
                              ? '2: ${mercs[1].name.split(' ').first} (${mercs[1].status == MercenaryStatus.onExpedition ? "ZİNDANDA" : "DİNLENİYOR"})'
                              : '2: BOŞ RANZA',
                          style: GameTypography.display(
                            color: mercs.length >= 2 ? GameColors.profitGreen : Colors.white54,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  ),
);
}

  Widget _buildMercenaryCard(MercenaryModel merc) {
    String statusText;
    Color statusColor;
    if (merc.status == MercenaryStatus.ready) {
      statusText = 'HAZIR';
      statusColor = GameColors.profitGreen;
    } else if (merc.status == MercenaryStatus.onExpedition) {
      statusText = 'SEFERDE';
      statusColor = GameColors.alertOrange;
    } else {
      statusText = 'DİNLENİYOR (${merc.restTimeRemainingSeconds}s)';
      statusColor = GameColors.hazardYellow;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E202B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
            child: Text(merc.avatar, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(merc.name, style: GameTypography.display(color: Colors.white, fontSize: 12)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(statusText, style: GameTypography.display(color: statusColor, fontSize: 9)),
                    ),
                  ],
                ),
                Text('${merc.role} • Toplam Güç: ${merc.totalCombatPower} CP', style: GameTypography.body(color: GameColors.goldLight, fontSize: 10)),
                Text('Kuşanılan Eşya: ${merc.equippedItems.length} Adet', style: GameTypography.body(color: Colors.white38, fontSize: 9)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shield, color: GameColors.gold, size: 20),
            tooltip: 'Donanım Kuşan',
            onPressed: () => _showEquipMercenaryDialog(merc),
          ),
        ],
      ),
    );
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
                              ref.read(ftueProvider.notifier).setStep(FTUEStep.marketplaceFirstSale);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tebrikler! Savaşçın güçlendi. Şimdi Çalışma Odasına geçerek ilk internet satışını yap!'),
                                    backgroundColor: GameColors.profitGreen,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                              Future.delayed(const Duration(milliseconds: 500), () {
                                if (mounted) {
                                  _tabController.animateTo(0); // Çalışma Odası (Web Pazar)
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

  Widget _buildExpeditionButton({
    required String name,
    required int difficulty,
    required int duration,
    required DungeonState dungeonState,
  }) {
    final readyMerc = dungeonState.mercenaries.where((m) => m.status == MercenaryStatus.ready).firstOrNull;
    final isAvailable = readyMerc != null && dungeonState.activeExpedition == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E202B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isAvailable ? GameColors.gold.withValues(alpha: 0.3) : Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GameTypography.display(color: Colors.white, fontSize: 11)),
                Text('Zorluk: $difficulty CP • Süre: $duration sn', style: GameTypography.body(color: Colors.white54, fontSize: 9)),
              ],
            ),
          ),
          ArcadeButton(
            text: 'SEFERE GÖNDER ⚔️',
            icon: Icons.navigation,
            onPressed: isAvailable
                ? () {
                    HapticFeedback.heavyImpact();
                    ref.read(dungeonProvider.notifier).startExpedition(
                          mercenaryId: readyMerc.id,
                          dungeonName: name,
                          dungeonDifficulty: difficulty,
                          durationSeconds: duration,
                        );
                  }
                : null,
            primaryColor: isAvailable ? GameColors.gold : Colors.grey,
            shadowColor: const Color(0xFF8C711C),
            textColor: Colors.black,
            height: 34,
            fontSize: 10,
          ),
        ],
      ),
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
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CraftingBenchScreen(initialTab: 0))),
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
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CraftingBenchScreen(initialTab: 1))),
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
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CraftingBenchScreen(initialTab: 2))),
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
                                ref.read(ftueProvider.notifier).setStep(FTUEStep.gearAndNpcIntro);
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


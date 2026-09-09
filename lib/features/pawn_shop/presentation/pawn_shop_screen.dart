import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/services/game_audio_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

/// Dükkan Müşteri Teklifi
class ShopCustomerOffer {
  final ItemModel item;
  final String customerName;
  final String customerAvatar;
  final String dialogue;
  final int offeredPrice;
  final int basePrice;
  final double patience; // 0.0 - 1.0

  ShopCustomerOffer({
    required this.item,
    required this.customerName,
    required this.customerAvatar,
    required this.dialogue,
    required this.offeredPrice,
    required this.basePrice,
    this.patience = 0.6,
  });
}

/// 🛒 Fiziksel Rehin Dükkanı (PawnShopScreen)
/// Vitrin Satışı (5 Küçük + 3 Orta + 2 Büyük), Müşteri Pazarlığı & İki Yönlü Eşya Transferi
class PawnShopScreen extends ConsumerStatefulWidget {
  const PawnShopScreen({super.key});

  @override
  ConsumerState<PawnShopScreen> createState() => _PawnShopScreenState();
}

class _PawnShopScreenState extends ConsumerState<PawnShopScreen> {
  List<ItemModel> _showcaseItems = [];
  List<ItemModel> _shopStorageItems = [];
  List<ItemModel> _trunkItems = [];
  bool _isLoading = true;

  Timer? _customerStreamTimer;
  ShopCustomerOffer? _activeCustomerOffer;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _loadInventories();
    _startCustomerSimulation();
  }

  @override
  void dispose() {
    _customerStreamTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInventories() async {
    final profile = ref.read(playerProfileProvider);
    final trunkState = ref.read(trunkInventoryProvider);

    // Vitrin eşyaları
    final showcase = <ItemModel>[];
    for (final id in profile.shopShowcaseItemIds) {
      final item = await DatabaseService.instance.getItemById(id);
      if (item != null) showcase.add(item);
    }

    // Dükkan & Ev Deposu eşyaları (Oyuncunun tüm depolardaki eşyalarını vitrine koyabilmesi için)
    final storage = <ItemModel>[];
    final allStorageIds = <int>[
      ...profile.shopStorageItemIds,
      ...profile.homeStorageItemIds.where((id) => !profile.shopStorageItemIds.contains(id)),
    ];
    for (final id in allStorageIds) {
      final item = await DatabaseService.instance.getItemById(id);
      if (item != null) storage.add(item);
    }

    // Araç bagajı
    final trunk = <ItemModel>[];
    for (final placer in trunkState.placedItems) {
      if (placer.itemId != null) {
        final item = await DatabaseService.instance.getItemById(placer.itemId!);
        if (item != null) trunk.add(item);
      }
    }

    if (mounted) {
      setState(() {
        _showcaseItems = showcase;
        _shopStorageItems = storage;
        _trunkItems = trunk;
        _isLoading = false;
      });
    }
  }

  /// Poisson Müşteri Simülasyonu
  void _startCustomerSimulation() {
    _customerStreamTimer?.cancel();
    _customerStreamTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _activeCustomerOffer != null || _showcaseItems.isEmpty) return;

      // Vitrinden rastgele bir eşya seç
      final item = _showcaseItems[_rnd.nextInt(_showcaseItems.length)];
      _generateCustomerFor(item);
    });
  }

  void _generateCustomerFor(ItemModel item) {
    final customers = const [
      _PawnCustomerTpl('Koleksiyoncu Selim', 'assets/characters/customer_victoria.jpg', 1.35, 'Bu antika parçaya bayıldım! Vitrindeki fiyatın üzerine biraz daha ekleyebilirim.'),
      _PawnCustomerTpl('Hurdacı Rıza', 'assets/characters/customer_bob.jpg', 0.90, 'Parçayı beğendim ama biraz masrafı var. Şu fiyata anlaşırsak hemen nakit alırım.'),
      _PawnCustomerTpl('Antikacı Melahat', 'assets/characters/customer_victoria.jpg', 1.20, 'Dükkanıma çok yakışacak nadide bir ürün. Nakit çalışalım mı?'),
      _PawnCustomerTpl('Tüccar Kenan', 'assets/characters/customer_bob.jpg', 1.10, 'Müşterim için arıyordum. Peşin ödemede bu fiyata el sıkışalım.'),
    ];

    final chosen = customers[_rnd.nextInt(customers.length)];
    final offerPrice = (item.baseValue * chosen.multiplier).round();

    setState(() {
      _activeCustomerOffer = ShopCustomerOffer(
        item: item,
        customerName: chosen.name,
        customerAvatar: chosen.avatar,
        dialogue: chosen.phrase,
        offeredPrice: offerPrice,
        basePrice: item.baseValue,
        patience: 0.5 + _rnd.nextDouble() * 0.4,
      );
    });
  }

  /// Müşteri Teklifini Kabul Et
  Future<void> _handleAcceptOffer() async {
    if (_activeCustomerOffer == null) return;
    final offer = _activeCustomerOffer!;

    HapticFeedback.heavyImpact();
    GameAudioService.instance.playCoin();

    // 1. Nakit ve itibar ekle
    await ref.read(playerProfileProvider.notifier).addCash(offer.offeredPrice);
    await ref.read(playerProfileProvider.notifier).addReputation(25);

    // 2. Vitrinden kaldır
    await ref.read(playerProfileProvider.notifier).removeFromShowcase(offer.item.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: GameColors.profitGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🎉 ANLAŞMA SAĞLANDI! +${offer.offeredPrice} ₺ KAZANILDI (+25 XP)',
                  style: GameTypography.body(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF132218),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _activeCustomerOffer = null;
    });

    await _loadInventories();
  }

  /// Müşteriyle Pazarlık Yap (+%15 Fiyat Artışı)
  Future<void> _handleBargainOffer() async {
    if (_activeCustomerOffer == null) return;
    final offer = _activeCustomerOffer!;

    final successChance = offer.patience;
    final isSuccess = _rnd.nextDouble() <= successChance;

    if (isSuccess) {
      final newOfferPrice = (offer.offeredPrice * 1.15).round();
      HapticFeedback.mediumImpact();
      GameAudioService.instance.playClick();
      setState(() {
        _activeCustomerOffer = ShopCustomerOffer(
          item: offer.item,
          customerName: offer.customerName,
          customerAvatar: offer.customerAvatar,
          dialogue: '"Pekala usta, senin tatlı dilin için bu fiyata razıyım!"',
          offeredPrice: newOfferPrice,
          basePrice: offer.basePrice,
          patience: 0.0, // Tekrar pazarlık yapılamaz
        );
      });
    } else {
      HapticFeedback.heavyImpact();
      GameAudioService.instance.playWarning();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${offer.customerName}: "Bu fiyat çok fazla, anlaşamıyoruz!" diyerek dükkandan ayrıldı.'),
          backgroundColor: GameColors.alertOrange,
        ),
      );
      setState(() {
        _activeCustomerOffer = null;
      });
    }
  }

  /// Teklifi Reddet
  void _handleRejectOffer() {
    GameAudioService.instance.playClick();
    setState(() {
      _activeCustomerOffer = null;
    });
  }

  /// Bagajdaki Tüm Eşyaları Dükkan Deposuna Aktar
  Future<void> _transferAllTrunkToShop() async {
    if (_trunkItems.isEmpty) return;

    HapticFeedback.heavyImpact();
    final ids = _trunkItems.map((i) => i.id).toList();

    final added = await ref.read(playerProfileProvider.notifier).transferAllToShopStorage(ids);
    await ref.read(trunkInventoryProvider.notifier).clearTrunk();

    await _loadInventories();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$added adet eşya Dükkan Deposuna aktarıldı!'),
        backgroundColor: GameColors.profitGreen,
      ),
    );
  }

  /// Çift Dokunarak Bagajdan Dükkan Deposuna Aktarma
  Future<void> _transferSingleTrunkToShop(ItemModel item) async {
    HapticFeedback.mediumImpact();
    await ref.read(trunkInventoryProvider.notifier).removeItem(item.id);
    await ref.read(playerProfileProvider.notifier).addItemToShopStorage(item.id);
    await _loadInventories();
  }

  /// Çift Dokunarak Dükkan Deposundan Vitrine Koyma
  Future<void> _addToShowcase(ItemModel item) async {
    if (_showcaseItems.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vitrin dolu (Maks 10 Eşya)!')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    await ref.read(playerProfileProvider.notifier).removeItemFromShopStorage(item.id);
    await ref.read(playerProfileProvider.notifier).removeFromHomeStorage(item.id);
    await ref.read(playerProfileProvider.notifier).addToShowcase(item.id);
    await _loadInventories();
  }

  /// Vitrinden Depoya Geri Alma
  Future<void> _removeFromShowcase(ItemModel item) async {
    HapticFeedback.mediumImpact();
    await ref.read(playerProfileProvider.notifier).removeFromShowcase(item.id);
    await ref.read(playerProfileProvider.notifier).addToHomeStorage(item.id);
    await _loadInventories();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        title: Text(
          '🛒 REHİN DÜKKANI & VİTRİN',
          style: GameTypography.display(color: GameColors.goldLight, fontSize: 13),
        ),
        centerTitle: true,
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: GameColors.gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const HazardStripeBanner(height: 5),
                    const SizedBox(height: 8),

                    // 1. Aktif Müşteri Pazarlık Paneli (Eğer müşteri varsa)
                    if (_activeCustomerOffer != null) _buildCustomerNegotiationPanel(),

                    // 2. Dükkan Vitrini (10 Yuvalı Vitrin: 5 Küçük, 3 Orta, 2 Büyük)
                    DiegeticMetalPanel(
                      padding: const EdgeInsets.all(12),
                      borderColor: GameColors.gold,
                      borderWidth: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('✨ DÜKKAN VİTRİNİ (${_showcaseItems.length} / 10 Eşya)', style: GameTypography.display(color: GameColors.gold, fontSize: 12)),
                              Text('Müşteriler Vitrini İnceliyor...', style: GameTypography.body(color: GameColors.neonCyan, fontSize: 9)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_showcaseItems.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: Text('Vitrin boş! Aşağıdaki Dükkan Deposundan eşyaları vitrine ekleyin.', style: TextStyle(color: Colors.white38, fontSize: 11))),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                                childAspectRatio: 0.80,
                              ),
                              itemCount: _showcaseItems.length,
                              itemBuilder: (context, index) {
                                final item = _showcaseItems[index];
                                return GestureDetector(
                                  onTap: () => _removeFromShowcase(item),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: GameColors.gold.withValues(alpha: 0.5)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Image.asset(item.spritePath, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber)),
                                        ),
                                        Text(item.nameTr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 8)),
                                        Text('${item.baseValue} ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 8)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Araç Bagajından Dükkana Aktarma Bölümü
                    DiegeticMetalPanel(
                      padding: const EdgeInsets.all(12),
                      borderColor: GameColors.panelBorder,
                      borderWidth: 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('🚚 ARAÇ BAGAJI (${_trunkItems.length} Eşya)', style: GameTypography.display(color: GameColors.hazardYellow, fontSize: 11)),
                              ArcadeButton(
                                text: 'HEPSİNİ AKTAR ➡️',
                                icon: Icons.move_to_inbox,
                                onPressed: _trunkItems.isNotEmpty ? _transferAllTrunkToShop : null,
                                primaryColor: _trunkItems.isNotEmpty ? GameColors.profitGreen : Colors.grey,
                                shadowColor: const Color(0xFF006622),
                                textColor: Colors.black,
                                height: 30,
                                fontSize: 9,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (_trunkItems.isEmpty)
                            const Text('Araç kasasında eşya yok.', style: TextStyle(color: Colors.white30, fontSize: 10))
                          else
                            SizedBox(
                              height: 58,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _trunkItems.length,
                                itemBuilder: (context, index) {
                                  final item = _trunkItems[index];
                                  return GestureDetector(
                                    onDoubleTap: () => _transferSingleTrunkToShop(item),
                                    child: Container(
                                      width: 56,
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: GameColors.hazardYellow.withValues(alpha: 0.4)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(item.spritePath, width: 26, height: 26, fit: BoxFit.contain),
                                          Text(item.nameTr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 7)),
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

                    // 4. Dükkan Deposu (Vitrini Besleyen Depo)
                    Text('📦 DÜKKAN DEPOSU (${_shopStorageItems.length} / ${profile.maxStorageSlots} Kapasite)', style: GameTypography.display(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('İpucu: Depodaki eşyaya dokunarak Vitrine yerleştirin.', style: GameTypography.body(color: Colors.white54, fontSize: 9)),
                    const SizedBox(height: 8),

                    if (_shopStorageItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1B1D26), borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('Dükkan deposu boş.', style: TextStyle(color: Colors.white30, fontSize: 11))),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _shopStorageItems.length,
                        itemBuilder: (context, index) {
                          final item = _shopStorageItems[index];
                          return GestureDetector(
                            onTap: () => _addToShowcase(item),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E202B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: Image.asset(item.spritePath, fit: BoxFit.contain)),
                                  Text(item.nameTr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 8)),
                                  Text('${item.baseValue} ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 9)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCustomerNegotiationPanel() {
    final offer = _activeCustomerOffer!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DiegeticMetalPanel(
        padding: const EdgeInsets.all(12),
        borderColor: GameColors.profitGreen,
        borderWidth: 2,
        glowColor: GameColors.profitGreen,
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    offer.customerAvatar,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(width: 50, height: 50, color: Colors.blueGrey, child: const Center(child: Text('🧑‍💼'))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(offer.customerName, style: GameTypography.display(color: GameColors.gold, fontSize: 12)),
                          RetroLedDisplay(
                            value: '${offer.offeredPrice} ₺',
                            ledColor: GameColors.profitGreen,
                            fontSize: 12,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(offer.dialogue, style: GameTypography.body(color: Colors.white70, fontSize: 10).copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ArcadeButton(
                    text: 'KABUL ET 💰',
                    icon: Icons.check,
                    onPressed: _handleAcceptOffer,
                    primaryColor: GameColors.profitGreen,
                    shadowColor: const Color(0xFF006622),
                    textColor: Colors.black,
                    height: 36,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ArcadeButton(
                    text: 'PAZARLIK (+%15) 🤝',
                    icon: Icons.handshake,
                    onPressed: offer.patience > 0 ? _handleBargainOffer : null,
                    primaryColor: offer.patience > 0 ? GameColors.gold : Colors.grey,
                    shadowColor: const Color(0xFF8C711C),
                    textColor: Colors.black,
                    height: 36,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close, color: GameColors.lossRed),
                  tooltip: 'Reddet',
                  onPressed: _handleRejectOffer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PawnCustomerTpl {
  final String name;
  final String avatar;
  final double multiplier;
  final String phrase;
  const _PawnCustomerTpl(this.name, this.avatar, this.multiplier, this.phrase);
}


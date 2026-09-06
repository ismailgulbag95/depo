import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

/// Toptancı Tasfiye Merkezi (Wholesaler Hub)
/// Bagajdaki tüm eşyaları tek tıkla taban değerinin %50'sine nakde çevirir.
class WholesalerScreen extends ConsumerStatefulWidget {
  const WholesalerScreen({super.key});

  @override
  ConsumerState<WholesalerScreen> createState() => _WholesalerScreenState();
}

class _WholesalerScreenState extends ConsumerState<WholesalerScreen> {
  List<ItemModel> _trunkItems = [];
  bool _isLoading = true;
  int _totalEstimatedValue = 0;
  int _wholesalerOffer = 0;

  @override
  void initState() {
    super.initState();
    _loadTrunkItems();
  }

  Future<void> _loadTrunkItems() async {
    final trunkState = ref.read(trunkInventoryProvider);
    final items = <ItemModel>[];
    int totalBase = 0;

    for (final placer in trunkState.placedItems) {
      if (placer.itemId != null) {
        final item = await DatabaseService.instance.getItemById(placer.itemId!);
        if (item != null) {
          items.add(item);
          totalBase += item.baseValue;
        }
      }
    }

    if (mounted) {
      setState(() {
        _trunkItems = items;
        _totalEstimatedValue = totalBase;
        _wholesalerOffer = (totalBase * 0.50).round();
        _isLoading = false;
      });
    }
  }

  /// Toplu Satış Gerçekleştir
  Future<void> _handleBulkSell() async {
    if (_trunkItems.isEmpty || _wholesalerOffer <= 0) return;

    HapticFeedback.heavyImpact();

    // 1. Nakit ve itibar ekle
    await ref.read(playerProfileProvider.notifier).addCash(_wholesalerOffer);
    await ref.read(playerProfileProvider.notifier).addReputation((_wholesalerOffer * 0.05).round().clamp(10, 100));

    // 2. Bagajı boşalt
    await ref.read(trunkInventoryProvider.notifier).clearTrunk();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1D26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: GameColors.profitGreen, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: GameColors.profitGreen),
            const SizedBox(width: 8),
            Text('TOPTAN SATIŞ TAMAMLANDI', style: GameTypography.display(color: GameColors.profitGreen, fontSize: 14)),
          ],
        ),
        content: Text(
          'Toptancı Bob tüm bagajı satın aldı!\n+$_wholesalerOffer ₺ cüzdanınıza eklendi.',
          style: GameTypography.body(color: Colors.white, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadTrunkItems();
            },
            child: Text('HARİKAYDI', style: GameTypography.display(color: GameColors.gold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        title: Text(
          '🏪 TOPTANCI BOB & HURDA BORSASI',
          style: GameTypography.display(color: GameColors.goldLight, fontSize: 14),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: RetroLedDisplay(
                icon: Icons.account_balance_wallet,
                value: '${playerState.cash} ₺',
                ledColor: GameColors.profitGreen,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: GameColors.gold))
            : Column(
                children: [
                  const HazardStripeBanner(height: 6),

                  // 1. Toptancı Karakter Kartı ve Diyalog
                  Container(
                    margin: const EdgeInsets.all(14),
                    child: DiegeticMetalPanel(
                      padding: const EdgeInsets.all(12),
                      borderColor: GameColors.alertOrange,
                      borderWidth: 2,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/characters/customer_bob.jpg',
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 75,
                                height: 75,
                                color: Colors.orange.shade900,
                                child: const Center(child: Text('👨‍💼', style: TextStyle(fontSize: 32))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Toptancı Bob', style: GameTypography.display(color: GameColors.gold, fontSize: 13)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: GameColors.alertOrange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: GameColors.alertOrange, width: 1),
                                      ),
                                      child: Text('%50 ANINDA NAKİT', style: GameTypography.display(color: GameColors.alertOrange, fontSize: 9)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"Uğraşmak istemiyorsan arabadaki tüm yükü tek kalemde alırım. Değerinin yarısını peşin veririm, gerisi senin kârın!"',
                                  style: GameTypography.body(color: Colors.white70, fontSize: 11).copyWith(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Fiyat Teklif Özeti ve Aksiyon Butonu
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GameColors.panelBorder, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bagajdaki Eşya: ${_trunkItems.length} Adet', style: GameTypography.body(color: Colors.white70, fontSize: 11)),
                            Text('Piyasa Değeri: $_totalEstimatedValue ₺', style: GameTypography.body(color: Colors.white38, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text('Toptancı Teklifi: $_wholesalerOffer ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 15)),
                          ],
                        ),
                        ArcadeButton(
                          text: 'HEPSİNİ SAT 💰',
                          icon: Icons.payments_outlined,
                          onPressed: _trunkItems.isNotEmpty ? _handleBulkSell : null,
                          primaryColor: _trunkItems.isNotEmpty ? GameColors.profitGreen : Colors.grey,
                          shadowColor: const Color(0xFF006622),
                          textColor: Colors.black,
                          height: 42,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 3. Bagajdaki Eşyaların Listesi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('🚚 ARAÇ BAGAJINDAKİ YÜK', style: GameTypography.display(color: Colors.white70, fontSize: 11)),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Expanded(
                    child: _trunkItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.remove_shopping_cart, color: Colors.white24, size: 48),
                                const SizedBox(height: 8),
                                Text('Araç bagajı şu anda boş!', style: GameTypography.display(color: Colors.white38, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('İhaleye girerek yeni depolar yağmalayın.', style: GameTypography.body(color: Colors.white24, fontSize: 11)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            itemCount: _trunkItems.length,
                            itemBuilder: (context, index) {
                              final item = _trunkItems[index];
                              final halfVal = (item.baseValue * 0.50).round();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E202B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        item.spritePath,
                                        width: 38,
                                        height: 38,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: Colors.amber, size: 28),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.nameTr, style: GameTypography.display(color: Colors.white, fontSize: 11)),
                                          Text('${item.width}x${item.height} Izgara • ${item.weight} kg', style: GameTypography.body(color: Colors.white38, fontSize: 9)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Taban: ${item.baseValue} ₺', style: GameTypography.body(color: Colors.white38, fontSize: 9)),
                                        Text('$halfVal ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 12)),
                                      ],
                                    ),
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
  }
}

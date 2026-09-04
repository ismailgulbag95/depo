import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/localization/localization_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/auction_stamp.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/game_screen_shake.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/auction/presentation/live_auction_screen.dart';
import 'package:yeni_oyun_sablon/features/marketplace/providers/marketplace_provider.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// Pazar Yeri & Müşteri Pazarlık Ekranı (ADR-029)
class MarketplaceScreen extends ConsumerStatefulWidget {
  final ItemModel itemToSell;

  const MarketplaceScreen({super.key, required this.itemToSell});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final GameScreenShakeController _shakeController = GameScreenShakeController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceProvider.notifier).setItemForSale(widget.itemToSell);
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(marketplaceProvider);
    final playerCash = ref.watch(playerProfileProvider).cash;
    final lang = ref.watch(languageProvider);
    final item = marketState.activeItem ?? widget.itemToSell;

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: GameScreenShake(
          controller: _shakeController,
          child: Column(
            children: [
              // 1. Üst Bar: Kasa & Pazar Yeri HUD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    DiegeticMetalPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      borderRadius: 8,
                      showRivets: false,
                      child: Row(
                        children: [
                          const Icon(Icons.storefront, color: GameColors.gold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'PAZAR YERİ VİTRİNİ',
                            style: GameTypography.display(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    RetroLedDisplay(
                      label: 'KASA',
                      value: '$playerCash ₺',
                      ledColor: GameColors.profitGreen,
                      fontSize: 15,
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: HazardStripeBanner(height: 6),
              ),
              const SizedBox(height: 8),

              // 2. Eşya Vitrin Kartı
              Expanded(
                flex: 48,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  child: DiegeticMetalPanel(
                    padding: const EdgeInsets.all(12),
                    showRivets: true,
                    borderColor: marketState.isSold ? GameColors.profitGreen : GameColors.panelBorder,
                    glowColor: marketState.isSold ? GameColors.profitGreen : null,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Eşya Görseli
                            Center(
                              child: Image.asset(
                                item.spritePath,
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.inventory_2,
                                  color: Colors.amber,
                                  size: 80,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.localizedName(lang.code),
                              style: GameTypography.display(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Taban Değer: ${item.baseValue} ₺ • ${item.weight.toStringAsFixed(1)} kg',
                              style: GameTypography.body(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),

                        // Satıldı Damgası
                        if (marketState.isSold)
                          Center(
                            child: AuctionStamp(
                              text: 'SATILDI: +${marketState.finalSalePrice} ₺',
                              color: GameColors.profitGreen,
                              fontSize: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 3. Fiyat Belirleme ve Müşteri Pazarlık Bölümü
              Expanded(
                flex: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DiegeticMetalPanel(
                    padding: const EdgeInsets.all(12),
                    child: marketState.isSold
                        ? _buildSoldSummaryPanel()
                        : (marketState.currentOffer != null
                            ? _buildCustomerOfferPanel(marketState.currentOffer!)
                            : _buildPricingControls(marketState)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Aşama: Fiyat Belirleme ve Vitrine Koyma
  Widget _buildPricingControls(MarketplaceState state) {
    final percent = (state.priceMultiplier * 100).toInt();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'İSTEDİĞİNİZ SATIŞ FİYATI:',
              style: GameTypography.display(color: Colors.white, fontSize: 12),
            ),
            RetroLedDisplay(
              value: '${state.listingPrice} ₺ (%$percent)',
              ledColor: state.priceMultiplier > 1.2 ? GameColors.goldLight : GameColors.profitGreen,
              fontSize: 14,
            ),
          ],
        ),

        // Fiyat Slider'ı
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: GameColors.gold,
            inactiveTrackColor: Colors.white12,
            thumbColor: GameColors.goldLight,
            overlayColor: GameColors.gold.withValues(alpha: 0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: state.priceMultiplier,
            min: 0.5,
            max: 2.5,
            divisions: 20,
            onChanged: (val) {
              ref.read(marketplaceProvider.notifier).updatePriceMultiplier(val);
            },
          ),
        ),

        Text(
          state.priceMultiplier <= 0.85
              ? '⚡ Hızlı Satış: Fiyat ucuz olduğu için anında kapışılır!'
              : (state.priceMultiplier <= 1.3
                  ? '⚖️ Normal Piyasa: Kısa süre içinde teklifler gelir.'
                  : '⏳ Yüksek Fiyat: Alıcı bulmak zaman alabilir, pazarlık gelecektir.'),
          style: GameTypography.body(
            color: state.priceMultiplier <= 0.85 ? GameColors.profitGreen : Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),

        // Vitrine Koy Butonu
        ArcadeButton(
          text: state.isListed ? 'MÜŞTERİ BEKLENİYOR... ⏳' : 'VİTRİNE KOY VE SATIŞA BAŞLA 🏷️',
          icon: state.isListed ? Icons.hourglass_top : Icons.storefront,
          onPressed: state.isListed
              ? null
              : () {
                  ref.read(marketplaceProvider.notifier).listForSale();
                  HapticFeedback.mediumImpact();
                },
          primaryColor: GameColors.gold,
          shadowColor: const Color(0xFF8C711C),
          height: 46,
          fontSize: 12,
        ),
      ],
    );
  }

  /// 2. Aşama: Gelen Müşteri Pazarlık Teklifi
  Widget _buildCustomerOfferPanel(CustomerOffer offer) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Müşteri Başlığı ve Konuşma Balonu
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: GameColors.panelDark,
                shape: BoxShape.circle,
                border: Border.all(color: GameColors.gold, width: 1.5),
              ),
              child: Center(child: Text(offer.avatar, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.customerName.toUpperCase(),
                    style: GameTypography.display(color: GameColors.goldLight, fontSize: 11),
                  ),
                  Text(
                    '"${offer.dialogue}"',
                    style: GameTypography.body(color: Colors.white, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Teklif Edilen Nakit Fiyat
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GameColors.profitGreen.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MÜŞTERİNİN NAKİT TEKLİFİ:',
                style: GameTypography.display(color: Colors.white70, fontSize: 11),
              ),
              RetroLedDisplay(
                value: '${offer.offeredPrice} ₺',
                ledColor: GameColors.profitGreen,
                fontSize: 16,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            ],
          ),
        ),

        // Kabul Et / Reddet Butonları
        Row(
          children: [
            // Reddet Butonu
            Expanded(
              child: ArcadeButton(
                text: 'REDDET ⏳',
                icon: Icons.close,
                onPressed: () {
                  ref.read(marketplaceProvider.notifier).rejectOffer();
                  HapticFeedback.lightImpact();
                },
                primaryColor: GameColors.lossRed,
                shadowColor: const Color(0xFF8E0000),
                textColor: Colors.white,
                height: 44,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),

            // Kabul Et Butonu
            Expanded(
              child: ArcadeButton(
                text: 'EL SIKIŞ 🤝',
                icon: Icons.check,
                onPressed: () {
                  ref.read(marketplaceProvider.notifier).acceptOffer();
                  _shakeController.shake(intensity: 8.0);
                  HapticFeedback.heavyImpact();
                },
                primaryColor: GameColors.profitGreen,
                shadowColor: const Color(0xFF00893E),
                textColor: Colors.black,
                height: 44,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. Aşama: Satış Özeti ve Yeni İhale Butonu
  Widget _buildSoldSummaryPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          '🎉 TEBRİKLER! PARÇA BAŞARIYLA SATILDI!',
          style: GameTypography.display(color: GameColors.profitGreen, fontSize: 13),
        ),
        Text(
          'Kazandığınız nakit paranız kasaya eklendi. Daha büyük ihalelere katılmak için sermayeniz arttı.',
          style: GameTypography.body(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        ArcadeButton(
          text: 'YENİ İHALELERE DÖN 🏆',
          icon: Icons.gavel,
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LiveAuctionScreen()),
              (route) => false,
            );
          },
          primaryColor: GameColors.gold,
          shadowColor: const Color(0xFF8C711C),
          height: 48,
          fontSize: 12,
        ),
      ],
    );
  }
}

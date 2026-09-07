import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/auction/presentation/live_auction_screen.dart';
import 'package:yeni_oyun_sablon/features/city_map/models/zone_data.dart';
import 'package:yeni_oyun_sablon/features/city_map/presentation/widgets/city_map_view.dart';
import 'package:yeni_oyun_sablon/features/dealership/presentation/dealership_screen.dart';
import 'package:yeni_oyun_sablon/features/dungeon/presentation/dungeon_hub_screen.dart';
import 'package:yeni_oyun_sablon/features/home/presentation/home_screen.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
import 'package:yeni_oyun_sablon/features/onboarding/widgets/ftue_guide_overlay.dart';
import 'package:yeni_oyun_sablon/features/pawn_shop/presentation/pawn_shop_screen.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/real_estate/presentation/real_estate_screen.dart';
import 'package:yeni_oyun_sablon/features/tavern/presentation/tavern_screen.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';
import 'package:yeni_oyun_sablon/features/wholesaler/presentation/wholesaler_screen.dart';

/// 🗺️ İNTERAKTİF VEKTÖREL ŞEHİR HARİTASI (Interactive Stylized City Map Hub)
class CityMapScreen extends ConsumerStatefulWidget {
  const CityMapScreen({super.key});

  @override
  ConsumerState<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends ConsumerState<CityMapScreen> {

  void _navigateTo(Widget screen, {VoidCallback? onBeforeNav}) {
    HapticFeedback.mediumImpact();
    onBeforeNav?.call();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    final trunkState = ref.watch(trunkInventoryProvider);
    final ftueStep = ref.watch(ftueProvider);
    final isMapIntroFTUE = ftueStep == FTUEStep.interactiveMapIntro;
    final isTavernHiringFTUE = ftueStep == FTUEStep.tavernHiring;
    final isAnyFTUE = isMapIntroFTUE || isTavernHiringFTUE;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst HUD Barı (Cüzdan, İtibar, Bagaj Durumu)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF141418),
              child: Row(
                children: [
                  RetroLedDisplay(
                    icon: Icons.account_balance_wallet,
                    value: '${profile.cash} ₺',
                    ledColor: GameColors.profitGreen,
                    fontSize: 12,
                  ),
                  const SizedBox(width: 8),
                  RetroLedDisplay(
                    icon: Icons.star,
                    value: '${profile.reputation} XP',
                    ledColor: GameColors.gold,
                    fontSize: 12,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trunkState.placedItems.isNotEmpty
                          ? GameColors.hazardYellow.withValues(alpha: 0.2)
                          : Colors.black26,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: trunkState.placedItems.isNotEmpty
                            ? GameColors.hazardYellow
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping, color: GameColors.hazardYellow, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${trunkState.placedItems.length} Eşya (${trunkState.currentWeightKg.toInt()} kg)',
                          style: GameTypography.display(
                            color: trunkState.placedItems.isNotEmpty
                                ? GameColors.goldLight
                                : Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const HazardStripeBanner(height: 4),

            // 2. İnteraktif Şehir Haritası Tuvali (CityMapView)
            Expanded(
              child: CityMapView(
                backgroundAssetPath: GameAssetPaths.bgCityMapTactical,
                zones: [
                  // 1. Toptancı & Hurda (Sol alttaki sarı portal vinç ve hurda araç yığınları)
                  ZoneData(
                    id: 'wholesaler',
                    name: 'TOPTANCI & HURDA',
                    subtitle: 'Hurda & Toptan Satış',
                    icon: Icons.storefront,
                    alignment: const Alignment(-0.52, 0.32),
                    accentColor: const Color(0xFFE5A823), // Vinç ve hurdalık sarı-amberi
                    onTap: () => _navigateTo(const WholesalerScreen()),
                  ),

                  // 2. Ev & Karargah (Sol orta adadaki havuzlu yeşil müstakil villalar)
                  ZoneData(
                    id: 'home',
                    name: 'EV & KARARGAH',
                    subtitle: 'Atölye, Dinlenme & Ofis',
                    icon: Icons.home_filled,
                    alignment: const Alignment(-0.18, 0.12),
                    accentColor: const Color(0xFF43A047), // Yeşil müstakil ada yeşili
                    isHighlighted: isMapIntroFTUE,
                    onTap: () {
                      _navigateTo(
                        const HomeScreen(),
                        onBeforeNav: isMapIntroFTUE
                            ? () => ref.read(ftueProvider.notifier).setStep(FTUEStep.homeInventoryTransfer)
                            : null,
                      );
                    },
                  ),

                  // 3. Rehin Dükkanı (Haritanın sol tarafındaki turuncu çarşı bölgesi)
                  ZoneData(
                    id: 'pawn',
                    name: 'REHİN DÜKKANI',
                    subtitle: 'Nadir & Antika Alım',
                    icon: Icons.account_balance,
                    alignment: const Alignment(-0.78, 0.15),
                    accentColor: const Color(0xFFE08226), // Sol çarşı turuncusu
                    onTap: () => _navigateTo(const PawnShopScreen()),
                  ),

                  // 4. Oto Sanayi (Üst merkezdeki açık sarı otoparklı tamirhangar binaları)
                  ZoneData(
                    id: 'dealership',
                    name: 'OTO SANAYİ',
                    subtitle: 'Araç & Bagaj Filosu',
                    icon: Icons.directions_car,
                    alignment: const Alignment(-0.06, -0.58),
                    accentColor: const Color(0xFFFBC02D), // Sanayi ve otopark sarısı
                    onTap: () => _navigateTo(const DealershipScreen()),
                  ),

                  // 5. Canlı Depo Mezatı (Sol üst rıhtımdaki gri renkli kapalı antrepo/depo blokları)
                  ZoneData(
                    id: 'auction',
                    name: 'CANLI DEPO MEZATI',
                    subtitle: 'Depo Savaşları',
                    icon: Icons.gavel,
                    alignment: const Alignment(-0.54, -0.72),
                    accentColor: const Color(0xFF607D8B), // Çelik gri/mavi antrepo depoları
                    badgeText: 'CANLI MEZAT',
                    isImportant: true,
                    onTap: () => _navigateTo(const LiveAuctionScreen()),
                  ),

                  // 6. Kara Ejder Hanı (Sağ üst gölet kenarındaki ahşap/kiremit han ve iskele alanı)
                  ZoneData(
                    id: 'tavern',
                    name: 'KARA EJDER HANI',
                    subtitle: 'Paralı Asker Kiralama',
                    icon: Icons.sports_bar,
                    alignment: const Alignment(0.42, -0.65),
                    accentColor: const Color(0xFFC26E2D), // Ahşap han ve kırsal kiremit rengi
                    isHighlighted: isTavernHiringFTUE,
                    onTap: () => _navigateTo(const TavernScreen()),
                  ),

                  // 7. Emlak Bürosu (Sağ alttaki mavi cam gökdelenler ve modern iş merkezi)
                  ZoneData(
                    id: 'real_estate',
                    name: 'EMLAK BÜROSU',
                    subtitle: 'Gayrimenkul & Kira',
                    icon: Icons.apartment,
                    alignment: const Alignment(0.64, 0.22),
                    accentColor: const Color(0xFF00B0FF), // Gökdelen cam ve plaza mavisi
                    onTap: () => _navigateTo(const RealEstateScreen()),
                  ),

                  // 8. Zindan & Seferler (Sağ üstteki çöl kanyonu, antik sütunlar ve dağ tapınağı)
                  ZoneData(
                    id: 'dungeon',
                    name: 'ZİNDAN & SEFERLER',
                    subtitle: 'Ganimet & Tehlike',
                    icon: Icons.shield,
                    alignment: const Alignment(0.86, -0.52),
                    accentColor: const Color(0xFFD47333), // Çöl kanyonu ve antik taş rengi
                    badgeText: 'SEFER',
                    onTap: () => _navigateTo(const DungeonHubScreen()),
                  ),
                ],
                openBottomSheetOnTap: true,
                overlayChild: isAnyFTUE
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.42),
                              ),
                            ),
                          ),
                          if (isMapIntroFTUE)
                            Positioned(
                              left: 20,
                              right: 20,
                              top: 20,
                              child: const GuideArrowSpotlight(
                                text: 'Tebrikler! İlk deponu aldın. Şimdi eşyaları depolamak ve satmak için EVE tıkla! 👇',
                              ),
                            ),
                          if (isTavernHiringFTUE)
                            Positioned(
                              left: 20,
                              right: 20,
                              top: 20,
                              child: const GuideArrowSpotlight(
                                text: 'Satıştan paranı kazandın! Şimdi ilk paralı askerini kiralamak için KARA EJDER HANI\'na tıkla! 👇',
                              ),
                            ),
                        ],
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

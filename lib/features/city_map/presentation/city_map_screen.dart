import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/auction/presentation/live_auction_screen.dart';
import 'package:yeni_oyun_sablon/features/dealership/presentation/dealership_screen.dart';
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

class _CityMapScreenState extends ConsumerState<CityMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
    final isMapFTUE = ftueStep == FTUEStep.interactiveMapIntro;

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

            // 2. İnteraktif Harita Tuvali
            Expanded(
              child: Stack(
                children: [
                  // Arka Plan Taktik Masa Haritası İllüstrasyonu (veya Vektörel Çizim Fallback)
                  Positioned.fill(
                    child: Image.asset(
                      GameAssetPaths.bgCityMapTactical,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _StylizedCityMapPainter(pulse: _pulseAnimation.value),
                          );
                        },
                      ),
                    ),
                  ),

                  // Harita Üzerindeki İnteraktif Stilize Bölge Butonları
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;

                        return Stack(
                          children: [
                            // 🏠 1. EV & KARARGAH (Merkez)
                            _buildMapDistrictNode(
                              left: w * 0.30,
                              top: h * 0.44,
                              title: '🏠 EV & KARARGAH',
                              subtitle: 'Web Pazar • Zindan • Depo',
                              accentColor: GameColors.neonCyan,
                              isHighlighted: isMapFTUE,
                              onTap: () {
                                _navigateTo(
                                  const HomeScreen(),
                                  onBeforeNav: () {
                                    if (isMapFTUE) {
                                      ref.read(ftueProvider.notifier).setStep(FTUEStep.homeInventoryTransfer);
                                    }
                                  },
                                );
                              },
                            ),

                            // 🏪 2. TOPTANCI (Kuzeybatı)
                            _buildMapDistrictNode(
                              left: w * 0.15,
                              top: h * 0.18,
                              title: '🏪 TOPTANCI & HURDA',
                              subtitle: '%50 Peşin Hızlı Satış',
                              accentColor: GameColors.alertOrange,
                              onTap: () => _navigateTo(const WholesalerScreen()),
                            ),

                            // 🏢 3. EMLAK (Kuzeydoğu)
                            _buildMapDistrictNode(
                              left: w * 0.56,
                              top: h * 0.22,
                              title: '🏢 EMLAK BÜROSU',
                              subtitle: 'Ev Geliştirme & Alan',
                              accentColor: const Color(0xFF64B5F6),
                              onTap: () => _navigateTo(const RealEstateScreen()),
                            ),

                            // 🚗 4. OTO SANAYİ (Batı)
                            _buildMapDistrictNode(
                              left: w * 0.10,
                              top: h * 0.45,
                              title: '🚗 OTO SANAYİ',
                              subtitle: 'Bagaj & Araç Alımı',
                              accentColor: const Color(0xFFFFB74D),
                              onTap: () => _navigateTo(const DealershipScreen()),
                            ),

                            // 🛒 5. REHİN DÜKKANI (Güneybatı)
                            _buildMapDistrictNode(
                              left: w * 0.14,
                              top: h * 0.65,
                              title: '🛒 REHİN DÜKKANI',
                              subtitle: 'Vitrin & Pazarlık',
                              accentColor: GameColors.profitGreen,
                              onTap: () => _navigateTo(const PawnShopScreen()),
                            ),

                            // 🍺 6. KARA EJDER HANI (Güneydoğu)
                            _buildMapDistrictNode(
                              left: w * 0.54,
                              top: h * 0.65,
                              title: '🍺 KARA EJDER HANI',
                              subtitle: 'Paralı Askerler & Zindan',
                              accentColor: GameColors.gold,
                              onTap: () => _navigateTo(const TavernScreen()),
                            ),

                            // 🔨 7. DEPO MEZATI (Merkez-Güney)
                            _buildMapDistrictNode(
                              left: w * 0.32,
                              top: h * 0.81,
                              title: '🔨 CANLI DEPO MEZATI',
                              subtitle: 'Depo İhaleleri & Tetris',
                              accentColor: const Color(0xFFFF5252),
                              isImportant: true,
                              onTap: () => _navigateTo(const LiveAuctionScreen()),
                            ),

                            // FTUE Yönlendirme Kılavuzu (Eve Ok Gösterir)
                            if (isMapFTUE)
                              Positioned(
                                left: w * 0.15,
                                top: h * 0.06,
                                right: w * 0.15,
                                child: const GuideArrowSpotlight(
                                  text: 'Tebrikler! İlk deponu aldın. Şimdi eşyaları depolamak ve incelemek için EVE git!',
                                ),
                              ),
                          ],
                        );
                      },
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

  /// Harita üzerindeki stilize organik bölge düğümü
  Widget _buildMapDistrictNode({
    required double left,
    required double top,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
    bool isHighlighted = false,
    bool isImportant = false,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = isHighlighted ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: DiegeticMetalPanel(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                borderColor: isHighlighted ? GameColors.gold : accentColor,
                borderWidth: isHighlighted ? 2.5 : 1.5,
                glowColor: isHighlighted ? GameColors.gold : accentColor,
                borderRadius: 10,
                backgroundColor: const Color(0xFF141622).withValues(alpha: 0.94),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                            boxShadow: [
                              BoxShadow(color: accentColor, blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: GameTypography.display(
                            color: isHighlighted ? GameColors.goldLight : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GameTypography.body(
                        color: Colors.white60,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 🎨 Vektörel Şehir Haritası Arka Plan Çizicisi
class _StylizedCityMapPainter extends CustomPainter {
  final double pulse;

  _StylizedCityMapPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Zemin Koyu Izgara Deseni
    final gridPaint = Paint()
      ..color = const Color(0xFF181B28)
      ..strokeWidth = 1.0;

    const gridSize = 32.0;
    for (double x = 0; x < w; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Neon Siber Nehir / Kanal Çizgisi
    final riverPath = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(w * 0.3, h * 0.45, w * 0.6, h * 0.25, w, h * 0.40);

    final riverGlowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.12)
      ..strokeWidth = 24.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(riverPath, riverGlowPaint);

    final riverPaint = Paint()
      ..color = const Color(0xFF00B0FF).withValues(alpha: 0.40)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(riverPath, riverPaint);

    // 3. Bölge Bağlantı Yolları (Ana Arterler)
    final roadPaint = Paint()
      ..color = const Color(0xFF37474F).withValues(alpha: 0.70)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadGlow = Paint()
      ..color = GameColors.gold.withValues(alpha: 0.15 * pulse)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Yollar: Merkez (Ev) -> Toptancı, Oto Sanayi, Han, Mezat
    final pHome = Offset(w * 0.45, h * 0.32);
    final pWholesale = Offset(w * 0.15, h * 0.14);
    final pRealEstate = Offset(w * 0.72, h * 0.14);
    final pDealership = Offset(w * 0.15, h * 0.55);
    final pPawn = Offset(w * 0.22, h * 0.78);
    final pTavern = Offset(w * 0.70, h * 0.58);
    final pAuction = Offset(w * 0.55, h * 0.82);

    void drawSegment(Offset p1, Offset p2) {
      canvas.drawLine(p1, p2, roadPaint);
      canvas.drawLine(p1, p2, roadGlow);
    }

    drawSegment(pHome, pWholesale);
    drawSegment(pHome, pRealEstate);
    drawSegment(pHome, pDealership);
    drawSegment(pDealership, pPawn);
    drawSegment(pHome, pTavern);
    drawSegment(pHome, pAuction);
    drawSegment(pPawn, pAuction);
    drawSegment(pTavern, pAuction);

    // 4. Bölge Vektörel Daire Hub'ları
    final hubPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;
    final hubBorderPaint = Paint()
      ..color = GameColors.gold.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final hubs = [pHome, pWholesale, pRealEstate, pDealership, pPawn, pTavern, pAuction];
    for (final hub in hubs) {
      canvas.drawCircle(hub, 6.0, hubPaint);
      canvas.drawCircle(hub, 6.0, hubBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StylizedCityMapPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/auction/presentation/live_auction_screen.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';

/// Oyun Başlangıç Çizgi-Roman Hikaye ve Giriş Ekranı (Story Prologue)
class StoryIntroScreen extends ConsumerStatefulWidget {
  const StoryIntroScreen({super.key});

  @override
  ConsumerState<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends ConsumerState<StoryIntroScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _storySteps = [
    {
      'title': 'BÖLÜM 1: MİRAS KALAN HURDA',
      'subtitle': 'Tozlu bir garaj, eski bir pikap ve son 500 ₺ nakit...',
      'image': GameAssetPaths.trunkPickup,
      'speech': 'Amcanın eski hurdalığı kapandı. Elinde sadece bu 1978 model açık kasa pikap ve cebinde son 500 ₺ sermayen kaldı. Şehre yeni bir kiralık depo partisi geldi!',
      'badge': 'BAŞLANGIÇ SERMAYESİ: 500 ₺',
    },
    {
      'title': 'BÖLÜM 2: STORAGE WARS ARENASI',
      'subtitle': 'Hacizli depolar, kilitli kapılar ve 15 saniyelik gözlem kuralı!',
      'image': GameAssetPaths.bgAuctionYard,
      'speech': 'Kural basit: Kepenk 15 saniyeliğine yukarı kalkar. İçeri adım atmak, eşyalara dokunmak kesinlikle YASAKTIR! Sadece gözlerinle tartıp karar vereceksin.',
      'badge': 'KURAL: 15 SN İNCELEME',
    },
    {
      'title': 'BÖLÜM 3: ÇETİN RAKİPLER',
      'subtitle': 'Dave, Laura ve Gus... Bu tesiste kimse sana acımaz!',
      'image': GameAssetPaths.rivalDave,
      'speech': 'Dave gözü kapalı fiyat basar, Laura antikaların kokusunu alır, Gus ise ağır motor ve aletleri kaçırmaz. Teklif savaşında sakin kal ve bütçeni aşma!',
      'badge': '3 DİŞLİ RAKİP',
    },
    {
      'title': 'BÖLÜM 4: ŞİMDİ SENİN SIRAN!',
      'subtitle': 'Depoyu kazan, eşyaları bagaja istifle, restore et ve dükkanda sat!',
      'image': GameAssetPaths.auctioneerDan,
      'speech': 'Müzayedeci Dan tokmağı kaldırdı! Kepenkler açılıyor. İlk depoyu kazanıp içindeki hazineleri çıkarma vakti!',
      'badge': 'MÜZAYEDE BAŞLIYOR',
    },
  ];

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < _storySteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _startFirstAuction();
    }
  }

  void _startFirstAuction() {
    HapticFeedback.heavyImpact();
    ref.read(ftueProvider.notifier).setStep(FTUEStep.scriptedAuction);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const LiveAuctionScreen(
          isFirstAuction: true,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _storySteps[_currentStep];
    final isLastStep = _currentStep == _storySteps.length - 1;

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst İlerleme ve Başlık Barı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  DiegeticMetalPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 8,
                    showRivets: false,
                    child: Row(
                      children: [
                        const Icon(Icons.auto_stories, color: GameColors.gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'DEPO AVCILARI • HİKAYE',
                          style: GameTypography.display(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Atla Butonu
                  TextButton.icon(
                    onPressed: _startFirstAuction,
                    icon: const Icon(Icons.fast_forward, color: Colors.white60, size: 16),
                    label: Text(
                      'ATLA',
                      style: GameTypography.body(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: HazardStripeBanner(height: 5),
            ),
            const SizedBox(height: 8),

            // 2. Çift Elle Oynama Alanı: SOL %50 Çizgi-Roman Sahnesi, SAĞ %50 Hikaye & İlerleme
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // SOL %50: Çizgi-Roman Sahne Paneli
                    Expanded(
                      flex: 5,
                      child: DiegeticMetalPanel(
                        padding: const EdgeInsets.all(8),
                        borderColor: GameColors.gold,
                        borderWidth: 2,
                        showRivets: true,
                        glowColor: GameColors.gold,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Çizgi-Roman Görseli
                              Image.asset(
                                step['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF1E2028),
                                  child: const Center(
                                    child: Icon(Icons.image, size: 64, color: Colors.white24),
                                  ),
                                ),
                              ),

                              // Gradyan Gölge (Yazı okunurluğu için)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.2),
                                      Colors.black.withValues(alpha: 0.85),
                                    ],
                                    stops: const [0.5, 1.0],
                                  ),
                                ),
                              ),

                              // Üst Bölüm Başlığı
                              Positioned(
                                top: 10,
                                left: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: GameColors.gold, width: 1.5),
                                  ),
                                  child: Text(
                                    step['title'] as String,
                                    style: GameTypography.display(
                                      color: GameColors.goldLight,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              // Alt Rozet
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: RetroLedDisplay(
                                  value: step['badge'] as String,
                                  ledColor: GameColors.neonCyan,
                                  fontSize: 11,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // SAĞ %50: Hikaye Anlatımı & Arcade İlerleme Paneli
                    Expanded(
                      flex: 5,
                      child: DiegeticMetalPanel(
                        padding: const EdgeInsets.all(12),
                        showRivets: false,
                        backgroundColor: GameColors.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['subtitle'] as String,
                              style: GameTypography.display(
                                color: GameColors.hazardYellow,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Divider(color: GameColors.panelBorder, height: 1),
                            const SizedBox(height: 8),

                            // Hikaye Metni
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  step['speech'] as String,
                                  style: GameTypography.body(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Alt Adım Noktaları & Arcade İlerle Butonu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: List.generate(_storySteps.length, (idx) {
                                    final isActive = idx == _currentStep;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: isActive ? 20 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isActive ? GameColors.gold : Colors.white24,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }),
                                ),
                                ArcadeButton(
                                  text: isLastStep ? 'MÜZAYEDEYE GİR 🏁' : 'İLERİ ➡️',
                                  icon: isLastStep ? Icons.gavel : Icons.arrow_forward,
                                  onPressed: _nextStep,
                                  primaryColor: isLastStep ? GameColors.profitGreen : GameColors.gold,
                                  shadowColor: isLastStep ? const Color(0xFF00893E) : const Color(0xFF8C711C),
                                  height: 46,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/auction_stamp.dart';
import 'package:yeni_oyun_sablon/core/widgets/debug_console_sheet.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/game_screen_shake.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/city_map/presentation/city_map_screen.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
import 'package:yeni_oyun_sablon/features/onboarding/widgets/ftue_guide_overlay.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/presentation/storage_raid_screen.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/services/storage_generator_service.dart';

/// Müzayede Aşamaları
enum AuctionPhase {
  inspection, // 15 Saniyelik İnceleme & Gözlem Süresi (Kepenk tam açılır)
  bidding,    // 30 Saniyelik Hızlı Canlı Teklif Süreci
  finished,   // Tokmak vuruldu, sonuç ekranı
}

/// Rakip Müzayede Katılımcısı Modeli
class AuctionBidder {
  final String name;
  final String avatar;
  final String? imagePath;
  final Color color;
  int maxBudget;
  bool isDroppedOut;
  final String dropOutReason;

  AuctionBidder({
    required this.name,
    required this.avatar,
    this.imagePath,
    required this.color,
    required this.maxBudget,
    this.isDroppedOut = false,
    required this.dropOutReason,
  });
}

/// Canlı Amerikan Açık Artırma / Müzayede Ekranı (Storage Wars Deneyimi)
class LiveAuctionScreen extends ConsumerStatefulWidget {
  final bool isFirstAuction;

  const LiveAuctionScreen({
    super.key,
    this.isFirstAuction = false,
  });

  @override
  ConsumerState<LiveAuctionScreen> createState() => _LiveAuctionScreenState();
}

class _LiveAuctionScreenState extends ConsumerState<LiveAuctionScreen>
    with SingleTickerProviderStateMixin {
  AuctionPhase _phase = AuctionPhase.inspection;
  GeneratedStorageUnit? _currentUnit;

  // Zamanlayıcılar
  int _inspectionSeconds = 15;
  int _biddingSeconds = 30;

  // Açık artırma parametreleri
  int _currentBid = 150;
  String _highestBidderName = 'Açılış';
  bool _isPlayerHighest = false;
  bool _playerWon = false;

  // Scripted Tutorial Durumu
  int _scriptedStep = 0; // 0: 200 bas, 1: 350 bas, 2: 450 bas
  bool get _isScripted => widget.isFirstAuction || ref.read(ftueProvider) == FTUEStep.scriptedAuction;

  // Screen Shake Controller
  final GameScreenShakeController _shakeController = GameScreenShakeController();

  // Kepenk Animasyon Denetleyicisi
  late AnimationController _shutterController;
  late Animation<double> _shutterAnimation;

  // Müzayedeci hızlı konuşma sözleri
  final List<String> _inspectionChants = [
    'Sarı çizginin gerisinde kalın! İçeriye adım atmak veya eşyalara dokunmak yasaktır!',
    '15 saniyeniz var! Gözlerinizle tartın, içeriye iyi bakın!',
    'Arka taraftaki sandıklara ve raflara dikkat edin!',
    'Son 5 saniye inceleme! Teklif vermek için yerlerinizi alın!',
  ];

  final List<String> _biddingChants = [
    'Kim veriyor? Fiyat yükseliyor! Yirmi beş, elli, yetmiş beş!..',
    'Teklif geldi! Var mı arttıran, arıyorum, arıyorum!..',
    'Deponun değeri yüksek! Kaçırmayın bu depoyu!..',
    'Son teklifler! Bir!.. İki!.. Kimse yok mu?!..',
  ];

  String _currentChant = 'Kepenkler açılıyor! 15 saniye dışarıdan inceleme süreniz başladı!';

  // Rakipler
  late final List<AuctionBidder> _bidders = [
    AuctionBidder(
      name: 'Dave "Kral" Hester',
      avatar: '🤠',
      imagePath: GameAssetPaths.rivalDave,
      color: const Color(0xFFE53935),
      maxBudget: 650,
      dropOutReason: 'Bu fiyata değmez!',
    ),
    AuctionBidder(
      name: 'Laura "Şahin Göz" Dotson',
      avatar: '👒',
      imagePath: GameAssetPaths.rivalLaura,
      color: const Color(0xFF8E24AA),
      maxBudget: 750,
      dropOutReason: 'Koleksiyon parçası yok, pas!',
    ),
    AuctionBidder(
      name: 'Gus "Ağır Sanayi"',
      avatar: '🧢',
      imagePath: GameAssetPaths.rivalGus,
      color: const Color(0xFFFFB300),
      maxBudget: 550,
      dropOutReason: 'Ağır alet göremedim, çekiliyorum!',
    ),
  ];

  Timer? _countdownTimer;
  Timer? _botBidTimer;
  Timer? _chantTimer;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();

    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shutterAnimation = CurvedAnimation(
      parent: _shutterController,
      curve: Curves.easeInOutCubic,
    );

    _loadNewStorageUnit();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _botBidTimer?.cancel();
    _chantTimer?.cancel();
    _shutterController.dispose();
    super.dispose();
  }

  /// 276 eşya arasından yepyeni prosedürel bir depo üretir ve başlatır
  Future<void> _loadNewStorageUnit() async {
    final unlocked = ref.read(playerProfileProvider).unlockedDistricts;
    final unit = await StorageGeneratorService.instance.generateRandomUnit(
      isFirstAuction: _isScripted,
      unlockedDistricts: unlocked,
    );
    if (mounted) {
      setState(() {
        _currentUnit = unit;
        _currentBid = _isScripted ? 150 : unit.startingBid;
        _highestBidderName = 'Açılış';
        _isPlayerHighest = false;
        _scriptedStep = 0;
        _initBiddersForUnit(unit);
      });

      _shutterController.forward();
      _startInspectionPhase();
    }
  }

  void _initBiddersForUnit(GeneratedStorageUnit unit) {
    if (_isScripted) {
      _bidders[0].maxBudget = 400; // Dave
      _bidders[1].maxBudget = 300; // Laura
      _bidders[2].maxBudget = 300; // Gus
    } else {
      // Toplam değere oranla dinamik bütçe
      final est = unit.totalEstimatedValue;
      _bidders[0].maxBudget = (est * (0.65 + _rnd.nextDouble() * 0.25)).round(); // Dave
      _bidders[1].maxBudget = (est * (0.75 + _rnd.nextDouble() * 0.35)).round(); // Laura
      _bidders[2].maxBudget = (est * (0.55 + _rnd.nextDouble() * 0.25)).round(); // Gus
    }

    for (final b in _bidders) {
      b.isDroppedOut = false;
    }
  }

  /// 1. AŞAMA: 15 Saniyelik Gözlem Süresi
  void _startInspectionPhase() {
    _phase = AuctionPhase.inspection;
    _inspectionSeconds = 15;
    _currentChant = _inspectionChants[0];

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_inspectionSeconds > 1) {
        setState(() {
          _inspectionSeconds--;
          if (_inspectionSeconds == 10) _currentChant = _inspectionChants[1];
          if (_inspectionSeconds == 5) _currentChant = _inspectionChants[3];
        });
      } else {
        _countdownTimer?.cancel();
        _startBiddingPhase();
      }
    });
  }

  /// 2. AŞAMA: 30 Saniyelik Canlı Açık Artırma Süreci
  void _startBiddingPhase() {
    setState(() {
      _phase = AuctionPhase.bidding;
      _biddingSeconds = 30;
      _currentChant = 'Gözlem süresi bitti! Açık artırma başlıyor! Açılış $_currentBid ₺! Kim veriyor?!';
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_biddingSeconds > 1) {
        setState(() {
          _biddingSeconds--;
        });
        if (_biddingSeconds <= 5) {
          _shakeController.shake(intensity: 3.0);
          HapticFeedback.selectionClick();
        }
      } else {
        _finishAuction();
      }
    });

    _chantTimer?.cancel();
    _chantTimer = Timer.periodic(const Duration(milliseconds: 2200), (timer) {
      if (!mounted || _phase != AuctionPhase.bidding) return;
      if (!_currentChant.contains('çekiliyorum') && !_currentChant.contains('pas')) {
        setState(() {
          _currentChant = _biddingChants[_rnd.nextInt(_biddingChants.length)];
        });
      }
    });

    if (!_isScripted) {
      _scheduleNextBotBid();
    }
  }

  /// Normal Rastgele Bot Teklifleri
  void _scheduleNextBotBid() {
    if (_phase != AuctionPhase.bidding || _isScripted) return;

    final est = _currentUnit?.totalEstimatedValue ?? 1000;
    final ratio = (_currentBid / est).clamp(0.2, 1.6);
    final dynamicDelayMs = (1500 + (ratio * 1800)).round();
    final delay = Duration(milliseconds: dynamicDelayMs + _rnd.nextInt(1000));

    _botBidTimer = Timer(delay, () {
      if (!mounted || _phase != AuctionPhase.bidding) return;

      final activeBidders = _bidders.where((b) => !b.isDroppedOut && b.maxBudget > _currentBid).toList();

      if (activeBidders.isEmpty) {
        if (_highestBidderName != 'Açılış') {
          _finishAuctionEarlyDueToAllPass();
        }
        return;
      }

      final bidder = activeBidders[_rnd.nextInt(activeBidders.length)];
      final inc = 50;
      final newBid = _currentBid + inc;

      if (newBid <= bidder.maxBudget) {
        setState(() {
          _currentBid = newBid;
          _highestBidderName = '${bidder.avatar} ${bidder.name}';
          _isPlayerHighest = false;
          _currentChant = '${bidder.name} $newBid ₺ verdi! Kim geçiyor $newBid ₺’yi?!';
        });
        _shakeController.shake(intensity: 4.0);
        HapticFeedback.lightImpact();
      }

      _scheduleNextBotBid();
    });
  }

  /// Scripted Onboarding Adımı Bot Yanıtları
  void _handleScriptedBotResponses(int playerBid) {
    if (playerBid == 200) {
      // 1. Adım: Dave 250 verir, sonra Gus 300 verir
      Timer(const Duration(milliseconds: 900), () {
        if (!mounted || _phase != AuctionPhase.bidding) return;
        setState(() {
          _currentBid = 250;
          _highestBidderName = '${_bidders[0].avatar} ${_bidders[0].name}';
          _isPlayerHighest = false;
          _currentChant = 'Dave: "250 ₺! Bunu bana bırakın evlat!"';
        });
        _shakeController.shake(intensity: 4.0);
        HapticFeedback.lightImpact();

        Timer(const Duration(milliseconds: 1100), () {
          if (!mounted || _phase != AuctionPhase.bidding) return;
          setState(() {
            _currentBid = 300;
            _highestBidderName = '${_bidders[2].avatar} ${_bidders[2].name}';
            _isPlayerHighest = false;
            _currentChant = 'Gus: "300 ₺! Benim için çerez parası!"';
            _scriptedStep = 1; // Sıradaki oyuncu teklifi: 350
          });
          _shakeController.shake(intensity: 4.0);
          HapticFeedback.lightImpact();
        });
      });
    } else if (playerBid == 350) {
      // 2. Adım: Laura PAS geçer, Dave 400 basar, Gus PAS geçer
      Timer(const Duration(milliseconds: 900), () {
        if (!mounted || _phase != AuctionPhase.bidding) return;
        setState(() {
          _bidders[1].isDroppedOut = true; // Laura pas
          _currentChant = 'Laura: "350 ₺ mi? Bu fiyata değmez, ben çekiliyorum!"';
        });

        Timer(const Duration(milliseconds: 1100), () {
          if (!mounted || _phase != AuctionPhase.bidding) return;
          setState(() {
            _currentBid = 400;
            _highestBidderName = '${_bidders[0].avatar} ${_bidders[0].name}';
            _isPlayerHighest = false;
            _bidders[2].isDroppedOut = true; // Gus pas
            _currentChant = 'Dave: "400 ₺! Son şansın evlat!" Gus: "Ben de pas!"';
            _scriptedStep = 2; // Sıradaki oyuncu teklifi: 450
          });
          _shakeController.shake(intensity: 5.0);
          HapticFeedback.lightImpact();
        });
      });
    } else if (playerBid == 450) {
      // 3. Adım: Dave PAS geçer -> Depo 450 ₺'ye oyuncuya kalır
      Timer(const Duration(milliseconds: 900), () {
        if (!mounted || _phase != AuctionPhase.bidding) return;
        setState(() {
          _bidders[0].isDroppedOut = true; // Dave pas
          _currentChant = 'Dave: "Lanet olsun, 450 ₺ çok fazla! Depo senin olsun!"';
        });
        _shakeController.shake(intensity: 5.0);
        _finishAuctionEarlyDueToAllPass();
      });
    }
  }

  /// Tüm rakipler pas dediğinde süreyi beklemeden hemen tokmağı vurur
  void _finishAuctionEarlyDueToAllPass() {
    _countdownTimer?.cancel();
    _botBidTimer?.cancel();
    _chantTimer?.cancel();

    setState(() {
      _currentChant = 'TÜM RAKİPLER ÇEKİLDİ! BAŞKA TEKLİF YOK! SATTIIMM!..';
    });
    _shakeController.shake(intensity: 6.0);
    HapticFeedback.heavyImpact();

    // 800ms sonra resmi bitiş faturası ve tokmağı vur
    Timer(const Duration(milliseconds: 800), () {
      if (mounted && _phase == AuctionPhase.bidding) {
        _finishAuction();
      }
    });
  }

  void _playerBid(int increment) {
    if (_phase != AuctionPhase.bidding) return;

    final playerCash = ref.read(playerProfileProvider).cash;
    final newBid = _currentBid + increment;

    if (playerCash < newBid) {
      HapticFeedback.heavyImpact();
      _shakeController.shake(intensity: 8.0);
      return;
    }

    setState(() {
      _currentBid = newBid;
      _highestBidderName = '👤 Siz';
      _isPlayerHighest = true;
      _currentChant = 'Oyuncumuzdan $newBid ₺ geldi! Satıyorum! Bir!.. İki!..';
    });

    _shakeController.shake(intensity: 7.0);
    HapticFeedback.heavyImpact();

    if (_isScripted) {
      _handleScriptedBotResponses(newBid);
    } else {
      for (final b in _bidders) {
        if (!b.isDroppedOut && _currentBid >= b.maxBudget) {
          b.isDroppedOut = true;
        }
      }
      if (_bidders.every((b) => b.isDroppedOut)) {
        _finishAuctionEarlyDueToAllPass();
      }
    }
  }

  void _finishAuction() {
    _countdownTimer?.cancel();
    _botBidTimer?.cancel();
    _chantTimer?.cancel();

    setState(() {
      _phase = AuctionPhase.finished;
      _playerWon = _isPlayerHighest;
      _currentChant = _playerWon
          ? 'SATTIM! BİR, İKİ, ÜÇ! DEPO SİZİN OLDU! 🏆'
          : 'SATTIM! Depo $_highestBidderName\'e satıldı!';
    });

    _shakeController.shake(intensity: 10.0, duration: const Duration(milliseconds: 500));
    HapticFeedback.heavyImpact();

    if (_playerWon) {
      ref.read(playerProfileProvider.notifier).deductCash(_currentBid);
      if (_isScripted) {
        ref.read(ftueProvider.notifier).setStep(FTUEStep.tetrisTutorial);
      }

      // Kullanıcı seçimi: Tokmak vurulduktan 1.5 saniye sonra otomatik depoya geç
      Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  StorageRaidScreen(storageUnit: _currentUnit),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerCash = ref.watch(playerProfileProvider).cash;

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: GameScreenShake(
          controller: _shakeController,
          child: Column(
            children: [
              // 1. Üst Bar: Diegetik Skorbord & Süre Sayacı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Depo Bilgi Rozeti
                      DiegeticMetalPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        showRivets: false,
                        borderRadius: 8,
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
                                _currentUnit?.unitNumber ?? '#204',
                                style: GameTypography.display(
                                  color: GameColors.goldLight,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _phase == AuctionPhase.inspection
                                      ? 'GÖZLEM SÜRESİ'
                                      : 'CANLI TEKLİF',
                                  style: GameTypography.display(
                                    color: _phase == AuctionPhase.inspection
                                        ? GameColors.neonCyan
                                        : GameColors.hazardYellow,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  _currentUnit?.archetype.title ?? 'Açık Artırma',
                                  style: GameTypography.body(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 🛠️ Hızlı Debug Modu Butonu
                      IconButton(
                        tooltip: 'Geliştirici Test Modu',
                        icon: const Icon(Icons.bug_report, color: GameColors.neonCyan, size: 22),
                        onPressed: () => DebugConsoleSheet.show(context),
                      ),
                      const SizedBox(width: 4),

                      // 🗺️ Şehir Haritası Butonu
                      IconButton(
                        tooltip: 'Şehir Haritası',
                        icon: const Icon(Icons.map, color: GameColors.neonCyan, size: 24),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CityMapScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 4),

                      // Retro LED Süre Sayacı
                      RetroLedDisplay(
                        icon: _phase == AuctionPhase.inspection ? Icons.visibility : Icons.timer,
                        value: _phase == AuctionPhase.inspection
                            ? '$_inspectionSeconds SN'
                            : '$_biddingSeconds SN',
                        ledColor: _phase == AuctionPhase.inspection
                            ? GameColors.neonCyan
                            : _biddingSeconds <= 5
                                ? GameColors.lossRed
                                : GameColors.gold,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),

              // Sarı-Siyah Tehlike İkaz Şeridi
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: HazardStripeBanner(height: 6),
              ),
              const SizedBox(height: 6),

                   // 2. Çift Elle Oynama Alanı: SOL %50 Depo Vitrini, SAĞ %50 Pazarlık Konsolu
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SOL %50: DEPO VİTRİNİ (Kepenk, Perspektif Zemin, Eşyalar & Kaşe) ---
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 4, bottom: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141418),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: GameColors.panelBorder, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // Depo İçi: Gerçekçi Duvar, Beton Zemin ve Doğrudan Yerde Duran Eşyalar
                              if (_currentUnit != null)
                                Positioned.fill(
                                  child: Stack(
                                    children: [
                                      // 1. Arka Plan Duvar & Tavan & Zemin 3D Perspektif Çizimi
                                      CustomPaint(
                                        size: Size.infinite,
                                        painter: _StoragePreviewEnvironmentPainter(),
                                      ),

                                      // 2. EŞYALAR — GERÇEKÇİ BOYUT, DERİNLİK VE TAM ZEMİNE BASAN DÜZEN
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        right: 8,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            // KATMAN 3: En Arka Zemin Sırası
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: _currentUnit!.layer3Items.map((item) {
                                                return Opacity(
                                                  opacity: 0.75,
                                                  child: Container(
                                                    margin: const EdgeInsets.only(bottom: 6),
                                                    child: Image.asset(
                                                      item.spritePath,
                                                      width: 36,
                                                      height: 36,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration: BoxDecoration(
                                                          color: Colors.amber.withValues(alpha: 0.2),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: Colors.amber, width: 1),
                                                        ),
                                                        child: const Icon(Icons.diamond, color: Colors.amber, size: 18),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),

                                            // KATMAN 2: Orta Zemin Sırası
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: _currentUnit!.layer2Items.map((item) {
                                                final itemW = item.width >= 3 ? 75.0 : (item.width >= 2 ? 60.0 : 48.0);
                                                final itemH = item.height >= 3 ? 70.0 : (item.height >= 2 ? 55.0 : 44.0);

                                                return Opacity(
                                                  opacity: 0.90,
                                                  child: Container(
                                                    margin: const EdgeInsets.only(bottom: 3),
                                                    child: Image.asset(
                                                      item.spritePath,
                                                      width: itemW,
                                                      height: itemH,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        width: itemW,
                                                        height: itemH,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white10,
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: Colors.white24),
                                                        ),
                                                        child: const Icon(Icons.inventory_2, color: Colors.white38, size: 24),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),

                                            // KATMAN 1: En Ön Zemin Sırası (Büyük Mobilya / Kasa / Sandık)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: _currentUnit!.layer1Items.map((item) {
                                                final itemW = item.width >= 4 ? 120.0 : (item.width >= 3 ? 95.0 : 75.0);
                                                final itemH = item.height >= 3 ? 95.0 : (item.height >= 2 ? 80.0 : 60.0);

                                                return Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                                  child: Image.asset(
                                                    item.spritePath,
                                                    width: itemW,
                                                    height: itemH,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      width: itemW,
                                                      height: itemH,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF221F1B),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: const Color(0xFF5A4D3B), width: 1.5),
                                                      ),
                                                      child: const Icon(Icons.archive, color: Colors.amber, size: 30),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // 3. Animasyonlu Metal Kepenk (Roller Shutter)
                              AnimatedBuilder(
                                animation: _shutterAnimation,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: Size.infinite,
                                    painter: _RollerShutterPainter(
                                      progress: _shutterAnimation.value,
                                    ),
                                  );
                                },
                              ),

                              // Bitiş Kaşesi (SATILDI / DEPO KAZANILDI)
                              if (_phase == AuctionPhase.finished)
                                Center(
                                  child: AuctionStamp(
                                    text: _playerWon ? 'DEPO KAZANILDI' : 'SATILDI',
                                    color: _playerWon ? GameColors.profitGreen : GameColors.lossRed,
                                    fontSize: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- SAĞ %50: PAZARLIK KONSOLU (Solunda Spiker/Rakipler, Sağında Butonlar) ---
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(left: 4, right: 10, bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // KONSOLUN SOLU: Müzayedeci Spiker & 3 Rakip Kartı (Yukarıdan Aşağıya)
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  // Spiker & Müzayedeci Dan Anons Kutusu
                                  DiegeticMetalPanel(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: GameColors.gold, width: 2),
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              GameAssetPaths.auctioneerDan,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => const Text('🎙️', style: TextStyle(fontSize: 20)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'MÜZAYEDECİ DAN',
                                                style: GameTypography.display(color: GameColors.gold, fontSize: 9),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _currentChant,
                                                style: GameTypography.body(color: Colors.white, fontSize: 11),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // 3 Rakip Dikey Liste Kartları (Dave, Laura, Gus)
                                  Expanded(
                                    child: Column(
                                      children: _bidders.map((b) {
                                        final isLeader = _highestBidderName.contains(b.name);
                                        final isOut = b.isDroppedOut;

                                        return Expanded(
                                          child: Opacity(
                                            opacity: isOut ? 0.40 : 1.0,
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isOut
                                                    ? Colors.black54
                                                    : (isLeader ? b.color.withValues(alpha: 0.25) : GameColors.panelDark),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isOut
                                                      ? GameColors.lossRed
                                                      : (isLeader ? b.color : GameColors.panelBorder),
                                                  width: isLeader ? 2 : 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  if (b.imagePath != null)
                                                    Container(
                                                      width: 26,
                                                      height: 26,
                                                      margin: const EdgeInsets.only(right: 6),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: isOut ? GameColors.lossRed : b.color),
                                                      ),
                                                      child: ClipOval(
                                                        child: Image.asset(
                                                          b.imagePath!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, _, _) => Text(b.avatar, style: const TextStyle(fontSize: 14)),
                                                        ),
                                                      ),
                                                    )
                                                  else
                                                    Text(b.avatar, style: const TextStyle(fontSize: 16)),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          b.name,
                                                          style: GameTypography.display(
                                                            color: isOut ? Colors.white38 : (isLeader ? b.color : Colors.white),
                                                            fontSize: 10,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                          isOut ? 'PAS GEÇTİ' : (isLeader ? 'LİDER TEKLİF' : 'BEKLEMEDE'),
                                                          style: GameTypography.body(
                                                            color: isOut ? GameColors.lossRed : (isLeader ? GameColors.profitGreen : Colors.white54),
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (isOut)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: GameColors.lossRed,
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                      child: const Text('PAS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // KONSOLUN SAĞI: Sayaçlar & Teklif Butonları (Yukarıdan Aşağıya)
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Canlı Sayaç & Cüzdan Paneli
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RetroLedDisplay(
                                          label: 'CÜZDAN',
                                          value: '$playerCash ₺',
                                          ledColor: GameColors.profitGreen,
                                          fontSize: 12,
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: RetroLedDisplay(
                                          label: 'SÜRE',
                                          value: _phase == AuctionPhase.inspection ? '$_inspectionSeconds SN' : '$_biddingSeconds SN',
                                          ledColor: _biddingSeconds <= 5 ? GameColors.lossRed : GameColors.neonCyan,
                                          fontSize: 12,
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Mevcut Teklif & Lider Rozeti
                                  DiegeticMetalPanel(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    borderColor: _isPlayerHighest ? GameColors.profitGreen : GameColors.gold,
                                    borderWidth: 1.5,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'EN YÜKSEK TEKLİF',
                                              style: GameTypography.body(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _highestBidderName,
                                              style: GameTypography.display(
                                                fontSize: 11,
                                                color: _isPlayerHighest ? GameColors.profitGreen : GameColors.goldLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                        RetroLedDisplay(
                                          value: '$_currentBid ₺',
                                          ledColor: _isPlayerHighest ? GameColors.profitGreen : GameColors.gold,
                                          fontSize: 14,
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),

                                  // Hızlı Butonlar (Gözlem, Teklif veya Bitiş)
                                  if (_phase == AuctionPhase.inspection) ...[
                                    ArcadeButton(
                                      text: 'TEKLİFE GEÇ ⏩',
                                      icon: Icons.play_arrow,
                                      onPressed: () {
                                        _countdownTimer?.cancel();
                                        _startBiddingPhase();
                                      },
                                      primaryColor: GameColors.gold,
                                      shadowColor: const Color(0xFF8C711C),
                                      height: 48,
                                      fontSize: 11,
                                    ),
                                  ] else if (_phase == AuctionPhase.finished) ...[
                                    ArcadeButton(
                                      text: _playerWon ? 'DEPOYA GİRİLİYOR... 🔓' : 'YENİ İHALE 🔄',
                                      icon: _playerWon ? Icons.door_front_door : Icons.refresh,
                                      onPressed: () {
                                        if (_playerWon) {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) => StorageRaidScreen(storageUnit: _currentUnit),
                                            ),
                                          );
                                        } else {
                                          setState(() {
                                            _isPlayerHighest = false;
                                            _shutterController.reset();
                                            _loadNewStorageUnit();
                                          });
                                        }
                                      },
                                      primaryColor: _playerWon ? GameColors.profitGreen : Colors.white24,
                                      shadowColor: _playerWon ? const Color(0xFF00893E) : Colors.black45,
                                      height: 48,
                                      fontSize: 11,
                                    ),
                                  ] else ...[
                                    // +50 ₺ Standart Teklif Pedalı
                                    ArcadeButton(
                                      text: '+50 ₺ BAS (${_currentBid + 50} ₺)',
                                      icon: Icons.gavel,
                                      onPressed: () => _playerBid(50),
                                      primaryColor: GameColors.profitGreen,
                                      shadowColor: const Color(0xFF00893E),
                                      height: 44,
                                      fontSize: 11,
                                    ),
                                    if (!_isScripted) ...[
                                      const SizedBox(height: 6),
                                      ArcadeButton(
                                        text: '+150 ₺ BÜYÜK BAS',
                                        icon: Icons.trending_up,
                                        onPressed: () => _playerBid(150),
                                        primaryColor: GameColors.alertOrange,
                                        shadowColor: const Color(0xFFB24800),
                                        height: 40,
                                        fontSize: 10,
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gerçekçi 3D Perspektif Depo İç Ortamı (Tavan, Yan Duvarlar, Arka Duvar, Beton Zemin ve Işık Huzmesi)
class _StoragePreviewEnvironmentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Tavan Bölgesi (Y: 0 -> h * 0.18)
    final ceilingRect = Rect.fromLTWH(0, 0, w, h * 0.20);
    final ceilingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1B1917), Color(0xFF282420)],
      ).createShader(ceilingRect);
    canvas.drawRect(ceilingRect, ceilingPaint);

    // Tavan çelik kirişleri
    final girderPaint = Paint()
      ..color = const Color(0xFF141210)
      ..strokeWidth = 3.0;
    canvas.drawLine(Offset(0, h * 0.08), Offset(w, h * 0.08), girderPaint);
    canvas.drawLine(Offset(0, h * 0.16), Offset(w, h * 0.16), girderPaint);

    // 2. Arka Tuğla / Sac Duvar (Y: h * 0.18 -> h * 0.62)
    final backWallRect = Rect.fromLTWH(w * 0.10, h * 0.18, w * 0.80, h * 0.44);
    final backWallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2A241F), Color(0xFF1C1814)],
      ).createShader(backWallRect);
    canvas.drawRect(backWallRect, backWallPaint);

    // Arka duvar tuğla/derz çizgileri
    final brickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    for (double y = h * 0.20; y < h * 0.62; y += 14) {
      canvas.drawLine(Offset(w * 0.10, y), Offset(w * 0.90, y), brickPaint);
    }

    // 3. Sol Yan Duvar (Perspektif)
    final leftWallPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.10, h * 0.18)
      ..lineTo(w * 0.10, h * 0.62)
      ..lineTo(0, h)
      ..close();
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [const Color(0xFF12100E), const Color(0xFF231E19)],
      ).createShader(Rect.fromLTWH(0, 0, w * 0.10, h));
    canvas.drawPath(leftWallPath, leftWallPaint);

    // Sol Kepenk Rayı & Panelleri
    final railPaint = Paint()
      ..color = const Color(0xFF38322B)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(w * 0.09, h * 0.18), Offset(w * 0.09, h * 0.62), railPaint);

    // 4. Sağ Yan Duvar (Perspektif)
    final rightWallPath = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.90, h * 0.18)
      ..lineTo(w * 0.90, h * 0.62)
      ..lineTo(w, h)
      ..close();
    final rightWallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [const Color(0xFF12100E), const Color(0xFF231E19)],
      ).createShader(Rect.fromLTWH(w * 0.90, 0, w * 0.10, h));
    canvas.drawPath(rightWallPath, rightWallPaint);

    // Sağ Kepenk Rayı
    canvas.drawLine(Offset(w * 0.91, h * 0.18), Offset(w * 0.91, h * 0.62), railPaint);

    // 5. Beton Zemin (Y: h * 0.62 -> h)
    final floorPath = Path()
      ..moveTo(0, h)
      ..lineTo(w * 0.10, h * 0.62)
      ..lineTo(w * 0.90, h * 0.62)
      ..lineTo(w, h)
      ..close();
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF24201C), Color(0xFF110F0D)],
      ).createShader(Rect.fromLTWH(0, h * 0.62, w, h * 0.38));
    canvas.drawPath(floorPath, floorPaint);

    // Zemin perspektif kılavuz çizgileri
    final floorGridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.30, h * 0.62), Offset(w * 0.20, h), floorGridPaint);
    canvas.drawLine(Offset(w * 0.50, h * 0.62), Offset(w * 0.50, h), floorGridPaint);
    canvas.drawLine(Offset(w * 0.70, h * 0.62), Offset(w * 0.80, h), floorGridPaint);

    // 6. Tavandan Sarkan Endüstriyel Lamba & Sıcak Işık Konisi
    final lightConePath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.95, h)
      ..lineTo(w * 0.05, h)
      ..close();
    final lightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -1),
        radius: 1.15,
        colors: [
          Colors.amber.withValues(alpha: 0.20),
          Colors.amber.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(lightConePath, lightPaint);

    // Lamba kablosu ve ampul
    final lampCordPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, 18), lampCordPaint);
    final bulbGlowPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(Offset(w * 0.5, 20), 4.5, bulbGlowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Endüstriyel Çelik / Alüminyum Sarmal Kepenk (Roller Shutter) Animasyon Çizicisi
class _RollerShutterPainter extends CustomPainter {
  final double progress; // 0.0 (tam kapalı) -> 1.0 (tam açık)

  const _RollerShutterPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return; // Tamamen açıldıysa çizmeye gerek yok

    final w = size.width;
    final h = size.height;
    final shutterHeight = (1.0 - progress) * h;

    if (shutterHeight <= 0) return;

    final shutterRect = Rect.fromLTWH(0, 0, w, shutterHeight);

    // 1. Kepenk Metalik Gövde Gradyanı (Endüstriyel gri / paslanmaz çelik)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF2E3036),
          Color(0xFF424650),
          Color(0xFF2A2C32),
          Color(0xFF383B44),
          Color(0xFF222428),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(shutterRect);
    canvas.drawRect(shutterRect, bodyPaint);

    // 2. Yatay Sarmal Dilimleri / Kepenk Kanatları (Slat Lines)
    const slatHeight = 12.0;
    final slatDarkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..strokeWidth = 2.0;
    final slatLightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    for (double y = 0; y < shutterHeight; y += slatHeight) {
      canvas.drawLine(Offset(0, y), Offset(w, y), slatDarkPaint);
      if (y + 1 < shutterHeight) {
        canvas.drawLine(Offset(0, y + 1.5), Offset(w, y + 1.5), slatLightPaint);
      }
    }

    // 3. Alt Etek / Kilit Çelik Laması (Heavy Bottom Bar)
    const bottomBarHeight = 14.0;
    final bottomBarY = shutterHeight - bottomBarHeight;
    if (bottomBarY > 0) {
      final barRect = Rect.fromLTWH(0, bottomBarY, w, bottomBarHeight);
      final barPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF555B66), Color(0xFF1E2024)],
        ).createShader(barRect);
      canvas.drawRect(barRect, barPaint);

      // Kilit tutamağı / sarı ikaz çizgisi
      final cautionPaint = Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.8)
        ..strokeWidth = 3.0;
      canvas.drawLine(
        Offset(w * 0.35, bottomBarY + bottomBarHeight / 2),
        Offset(w * 0.65, bottomBarY + bottomBarHeight / 2),
        cautionPaint,
      );
    }

    // 4. Sol ve Sağ Yan Kılavuz Rayları (Side Guides)
    const railWidth = 8.0;
    final railPaint = Paint()..color = const Color(0xFF1B1C20);
    canvas.drawRect(Rect.fromLTWH(0, 0, railWidth, shutterHeight), railPaint);
    canvas.drawRect(Rect.fromLTWH(w - railWidth, 0, railWidth, shutterHeight), railPaint);
  }

  @override
  bool shouldRepaint(covariant _RollerShutterPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}


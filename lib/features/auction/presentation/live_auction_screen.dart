import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/auction_stamp.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/game_screen_shake.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/dungeon/presentation/dungeon_hub_screen.dart';
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
  final int maxBudget;

  AuctionBidder({
    required this.name,
    required this.avatar,
    this.imagePath,
    required this.color,
    required this.maxBudget,
  });
}

/// Canlı Amerikan Açık Artırma / Müzayede Ekranı (Storage Wars Deneyimi)
class LiveAuctionScreen extends ConsumerStatefulWidget {
  const LiveAuctionScreen({super.key});

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
  int _currentBid = 250;
  String _highestBidderName = 'Açılış';
  bool _isPlayerHighest = false;
  bool _playerWon = false;

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
    'Kim veriyor 300? 300 var mı 300! Yirmi beş, elli, yetmiş beş!..',
    '350 geldi Dave’den! 400 kimde, 400 arıyorum, 400, 400!..',
    '450 dedi Laura! Dört yüz, dört yüz elli var mı arkada!..',
    '550 geldi Gus’tan! Beş yüz elli, altı yüz! Kaçırmayın bu depoyu!..',
    'Altı yüz elli geldi! Altı yüz bir, altı yüz iki! Kim arttırıyor!..',
    'Yedi yüz elli! Bıdıbıdı yedi yüz, sekiz yüz arıyorum!..',
    'Sekiz yüz geldi oyuncumuzdan! Sekiz yüz bir! Sekiz yüz iki!..',
    'Dokuz yüz elli var mı! Son teklifler!..',
  ];

  String _currentChant = 'Kepenkler açılıyor! 15 saniye dışarıdan inceleme süreniz başladı!';

  // Rakipler
  final List<AuctionBidder> _bidders = [
    AuctionBidder(
      name: 'Dave "Kurnaz"',
      avatar: '🤠',
      imagePath: GameAssetPaths.rivalDave,
      color: Colors.orange,
      maxBudget: 1200,
    ),
    AuctionBidder(
      name: 'Laura "Antikacı"',
      avatar: '🕶️',
      imagePath: GameAssetPaths.rivalLaura,
      color: Colors.purpleAccent,
      maxBudget: 1600,
    ),
    AuctionBidder(
      name: 'Gus "Tırcı"',
      avatar: '🧢',
      imagePath: GameAssetPaths.rivalGus,
      color: Colors.blueAccent,
      maxBudget: 950,
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
      duration: const Duration(milliseconds: 1800),
    );
    _shutterAnimation = CurvedAnimation(
      parent: _shutterController,
      curve: Curves.easeInOutCubic,
    );

    _loadNewStorageUnit();
  }

  /// 276 eşya arasından yepyeni prosedürel bir depo üretir ve başlatır
  Future<void> _loadNewStorageUnit() async {
    final unit = await StorageGeneratorService.instance.generateRandomUnit();
    if (mounted) {
      setState(() {
        _currentUnit = unit;
        _currentBid = unit.startingBid;
      });

      _shutterController.forward();
      _startInspectionPhase();
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
    _chantTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted || _phase != AuctionPhase.bidding) return;
      setState(() {
        _currentChant = _biddingChants[_rnd.nextInt(_biddingChants.length)];
      });
    });

    _scheduleNextBotBid();
  }

  void _scheduleNextBotBid() {
    if (_phase != AuctionPhase.bidding) return;

    final delay = Duration(milliseconds: 1600 + _rnd.nextInt(1800));
    _botBidTimer = Timer(delay, () {
      if (!mounted || _phase != AuctionPhase.bidding) return;

      final candidateBidders = _bidders.where((b) => b.maxBudget > _currentBid).toList();

      if (candidateBidders.isNotEmpty && _biddingSeconds > 2) {
        final bidder = candidateBidders[_rnd.nextInt(candidateBidders.length)];
        final increment = (_rnd.nextBool() ? 50 : 100);
        final newBid = _currentBid + increment;

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
      }

      _scheduleNextBotBid();
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
    }
  }

  @override
  void dispose() {
    _shutterController.dispose();
    _countdownTimer?.cancel();
    _botBidTimer?.cancel();
    _chantTimer?.cancel();
    super.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

                    const Spacer(),

                    // 🏰 Zindan & Kışla Karargahı Butonu
                    IconButton(
                      tooltip: 'Zindan & Kışla Karargahı',
                      icon: const Icon(Icons.castle, color: GameColors.goldLight, size: 24),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DungeonHubScreen()),
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
                      fontSize: 16,
                    ),
                  ],
                ),
              ),

              // Sarı-Siyah Tehlike İkaz Şeridi
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: HazardStripeBanner(height: 6),
              ),
              const SizedBox(height: 6),

              // 2. Depo Sahnesi & Animasyonla Açılan Kepenk (Diegetik Görünüm)
              Expanded(
                flex: 48,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
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
                        // Depo İçindeki Eşyaların Gerçekçi Görünümü
                        if (_currentUnit != null)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(0, -0.2),
                                  radius: 1.2,
                                  colors: [
                                    Color(0xFF28231C),
                                    Color(0xFF13110E),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  // Arka Raflar (Katman 3)
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.white.withValues(alpha: 0.12),
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: _currentUnit!.layer3Items.map((item) {
                                          return Image.asset(
                                            item.spritePath,
                                            width: 52,
                                            height: 52,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, _, _) => const Icon(
                                              Icons.inventory_2,
                                              color: Colors.amber,
                                              size: 36,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),

                                  // Ön Zemin (Büyük Hacimli Parçalar - Katman 1)
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: _currentUnit!.layer1Items.map((item) {
                                        return Image.asset(
                                          item.spritePath,
                                          width: 82,
                                          height: 82,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.weekend,
                                            color: Colors.amber,
                                            size: 55,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Animasyonla Açılan Kepenk
                        AnimatedBuilder(
                          animation: _shutterAnimation,
                          builder: (context, child) {
                            final shutterHeightRatio = 1.0 - _shutterAnimation.value;
                            return FractionallySizedBox(
                              alignment: Alignment.topCenter,
                              heightFactor: shutterHeightRatio,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF242220),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: GameColors.hazardYellow,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.lock, color: GameColors.hazardYellow, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'HACİZLİ DEPO AÇILIYOR...',
                                        style: GameTypography.display(
                                          color: Colors.white,
                                          fontSize: 13,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // İhale Canlı Liderlik Rozeti
                        if (_phase == AuctionPhase.bidding || _phase == AuctionPhase.finished)
                          Positioned(
                            bottom: 10,
                            left: 14,
                            right: 14,
                            child: DiegeticMetalPanel(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              backgroundColor: Colors.black.withValues(alpha: 0.9),
                              borderColor: _isPlayerHighest
                                  ? GameColors.profitGreen
                                  : GameColors.gold,
                              borderWidth: 2,
                              glowColor: _isPlayerHighest ? GameColors.profitGreen : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'EN YÜKSEK TEKLİF SAHİBİ',
                                        style: GameTypography.body(
                                          fontSize: 9,
                                          color: Colors.white60,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _highestBidderName,
                                        style: GameTypography.display(
                                          fontSize: 14,
                                          color: _isPlayerHighest
                                              ? GameColors.profitGreen
                                              : GameColors.goldLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  RetroLedDisplay(
                                    value: '$_currentBid ₺',
                                    ledColor: _isPlayerHighest
                                        ? GameColors.profitGreen
                                        : GameColors.gold,
                                    fontSize: 18,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Bitiş Kaşesi (SATILDI)
                        if (_phase == AuctionPhase.finished)
                          Center(
                            child: AuctionStamp(
                              text: _playerWon ? 'DEPO KAZANILDI' : 'SATILDI',
                              color: _playerWon ? GameColors.profitGreen : GameColors.lossRed,
                              fontSize: 26,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),
              // Alt Sarı-Siyah Şerit
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: HazardStripeBanner(height: 6),
              ),

              // 3. Spiker & Müzayedeci Anons Paneli
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: DiegeticMetalPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: GameColors.gold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.gold.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            GameAssetPaths.auctioneerDan,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: GameColors.gold,
                              child: const Center(
                                child: Text('🎙️', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _phase == AuctionPhase.inspection
                                  ? 'MÜZAYEDE YÖNETİCİSİ • İNCELEME DİREKTİFİ'
                                  : 'MÜZAYEDE YÖNETİCİSİ • CANLI ANONS',
                              style: GameTypography.display(
                                color: _phase == AuctionPhase.inspection
                                    ? GameColors.neonCyan
                                    : GameColors.gold,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentChant,
                              style: GameTypography.body(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Rakiplerin Canlı Katılım Çubuğu
              if (_phase == AuctionPhase.bidding || _phase == AuctionPhase.finished)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _bidders.map((b) {
                      final isLeader = _highestBidderName.contains(b.name);
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLeader ? b.color.withValues(alpha: 0.25) : GameColors.panelDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLeader ? b.color : GameColors.panelBorder,
                              width: isLeader ? 2 : 1,
                            ),
                            boxShadow: isLeader
                                ? [
                                    BoxShadow(
                                      color: b.color.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (b.imagePath != null)
                                Container(
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: b.color, width: 1),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      b.imagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text(b.avatar, style: const TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                )
                              else
                                Text(b.avatar, style: const TextStyle(fontSize: 16)),
                              Flexible(
                                child: Text(
                                  b.name.split(' ').first,
                                  style: GameTypography.body(
                                    color: isLeader ? b.color : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const Spacer(),

              // 5. Alt Aksiyon Paneli (Diegetik Teklif Konsolu)
              if (_phase == AuctionPhase.inspection)
                _buildInspectionActionPanel(playerCash)
              else if (_phase == AuctionPhase.finished)
                _buildAuctionResultPanel()
              else
                _buildPlayerBiddingControls(playerCash),
            ],
          ),
        ),
      ),
    );
  }

  /// Gözlem Süresi Alt Kontrol Paneli
  Widget _buildInspectionActionPanel(int playerCash) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: GameColors.surface,
        border: Border(top: BorderSide(color: GameColors.panelBorder, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RetroLedDisplay(
            label: 'CÜZDAN',
            value: '$playerCash ₺',
            ledColor: GameColors.profitGreen,
            fontSize: 15,
          ),
          ArcadeButton(
            text: 'HEMEN BAŞLAT ⚡',
            icon: Icons.fast_forward,
            onPressed: () {
              _countdownTimer?.cancel();
              _startBiddingPhase();
            },
            primaryColor: GameColors.gold,
            shadowColor: const Color(0xFF8C711C),
            height: 44,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  /// 3D Arcade Oyuncu Teklif Pedalları & Konsolu
  Widget _buildPlayerBiddingControls(int playerCash) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          top: BorderSide(color: GameColors.panelBorder, width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 14, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RetroLedDisplay(
                label: 'CÜZDAN',
                value: '$playerCash ₺',
                ledColor: GameColors.profitGreen,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              RetroLedDisplay(
                label: 'SIRADAKİ',
                value: '${_currentBid + 50} ₺',
                ledColor: GameColors.neonCyan,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // +50 ₺ Standart Teklif Pedalı
              Expanded(
                flex: 2,
                child: ArcadeButton(
                  text: '+50 ₺ BAS (${_currentBid + 50} ₺)',
                  icon: Icons.gavel,
                  onPressed: () => _playerBid(50),
                  primaryColor: GameColors.profitGreen,
                  shadowColor: const Color(0xFF00893E),
                  height: 50,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),

              // +150 ₺ Agresif Teklif Pedalı
              Expanded(
                flex: 2,
                child: ArcadeButton(
                  text: '+150 ₺ BÜYÜK BAS',
                  icon: Icons.trending_up,
                  onPressed: () => _playerBid(150),
                  primaryColor: GameColors.alertOrange,
                  shadowColor: const Color(0xFFB24800),
                  height: 50,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Müzayede Bitiş & Sonuç Paneli
  Widget _buildAuctionResultPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _playerWon ? const Color(0xFF132A18) : const Color(0xFF2C1414),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: _playerWon ? GameColors.profitGreen : GameColors.lossRed,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _playerWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: _playerWon ? GameColors.gold : GameColors.lossRed,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                _playerWon ? 'DEPOYU KAZANDINIZ! 🏆' : 'İHALE KAYBEDİLDİ!',
                style: GameTypography.display(
                  color: _playerWon ? GameColors.profitGreen : GameColors.lossRed,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _playerWon
                ? 'Son Teklif: $_currentBid ₺ ödendi. İçeri girip yağmaya başla!'
                : 'Depo $_highestBidderName tarafından alındı. Şansını yeni depoda dene.',
            style: GameTypography.body(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ArcadeButton(
            text: _playerWon ? 'İÇERİ GİR VE YAĞMALA 🔓' : 'YENİ İHALEYE GİR 🔄',
            icon: _playerWon ? Icons.door_front_door : Icons.refresh,
            onPressed: () {
              if (_playerWon) {
                // Kazanılan AYNI depoya gir
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
            primaryColor: _playerWon ? GameColors.gold : Colors.white24,
            shadowColor: _playerWon ? const Color(0xFF8C711C) : Colors.black45,
            height: 50,
            fontSize: 13,
          ),
        ],
      ),
    );
  }
}

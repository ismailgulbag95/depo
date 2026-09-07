import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/dungeon/presentation/dungeon_hub_screen.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/home/presentation/home_screen.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
import 'package:yeni_oyun_sablon/features/onboarding/widgets/ftue_guide_overlay.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/real_estate/presentation/real_estate_screen.dart';
import 'package:yeni_oyun_sablon/features/tavern/models/tavern_mercenary_model.dart';
import 'package:yeni_oyun_sablon/features/tavern/providers/tavern_provider.dart';

/// 🍺 Han & Paralı Asker Loncası Ekranı (TavernScreen - %100 Görsel & Konuşma Balonlu)
class TavernScreen extends ConsumerStatefulWidget {
  const TavernScreen({super.key});

  @override
  ConsumerState<TavernScreen> createState() => _TavernScreenState();
}

class _TavernScreenState extends ConsumerState<TavernScreen> {
  TavernMercenaryModel? _selectedMerc;
  String? _dialogueQuote;
  final ScrollController _tavernScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pool = ref.read(tavernProvider).availablePool;
      if (pool.isNotEmpty) {
        _inspectMercenary(pool.first, autoScroll: false);
      }
    });
  }

  @override
  void dispose() {
    _tavernScrollController.dispose();
    super.dispose();
  }

  final Map<String, String> _quotes = {
    'Savaşçı': 'Kılıcım keskin, zırhım sağlam! Ne zaman sefere çıkıyoruz patron? Boş boş oturmaktan paslandım!',
    'Okçu': 'Gölgelerden vururum, hedefim asla şaşmaz. Zindan haritalarını ve yayımı hazırla!',
    'Büyücü': 'Kadim parşömenlerin kudreti benimle. O canavarları tek hamlede küle çevirebilirim!',
    'Şövalye': 'Onurum ve kalkanım emrinde! Ekibini ve topladığın ganimetleri canım pahasına korurum.',
    'Hırsız': 'Tuzakları etkisiz hale getirir, kilitli hazine sandıklarını tereyağından kıl çeker gibi açarım.',
  };

  void _inspectMercenary(TavernMercenaryModel merc, {bool autoScroll = true}) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMerc = merc;
      _dialogueQuote = _quotes[merc.role] ?? 'Hazine kokusu alıyorum patron, beni ekibine al pişman olmazsın!';
    });

    if (autoScroll) {
      double targetOffset = 0;
      final r = merc.role.toLowerCase();
      if (r.contains('savaşçı') || r.contains('tank')) {
        targetOffset = 0;
      } else if (r.contains('suikastçı') || r.contains('hırsız') || r.contains('asas')) {
        targetOffset = 180;
      } else if (r.contains('okçu') || r.contains('avcı')) {
        targetOffset = 380;
      } else if (r.contains('büyücü')) {
        targetOffset = 580;
      } else {
        targetOffset = 780;
      }

      if (_tavernScrollController.hasClients) {
        _tavernScrollController.animateTo(
          targetOffset.clamp(0.0, 900.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Future<void> _hireMercenary(TavernMercenaryModel merc) async {
    HapticFeedback.mediumImpact();
    final result = await ref.read(tavernProvider.notifier).hireMercenary(merc);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? GameColors.profitGreen : GameColors.alertOrange,
        duration: const Duration(seconds: 2),
      ),
    );

    if (result.success && ref.read(ftueProvider) == FTUEStep.tavernHiring) {
      ref.read(ftueProvider.notifier).setStep(FTUEStep.restRoomEquip);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen(initialTabIndex: 1)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tavernState = ref.watch(tavernProvider);
    final profile = ref.watch(playerProfileProvider);
    final dungeonState = ref.watch(dungeonProvider);
    final ftueStep = ref.watch(ftueProvider);
    final isTavernFTUE = ftueStep == FTUEStep.tavernHiring;

    final currentMercsCount = dungeonState.mercenaries.length;
    final maxCapacity = profile.maxMercenaryCapacity;
    final isHouseFull = currentMercsCount >= maxCapacity;

    final minutes = (tavernState.nextRefreshSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (tavernState.nextRefreshSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        title: Text(
          '🍺 KARA EJDER HANI',
          style: GameTypography.display(color: GameColors.goldLight, fontSize: 13),
        ),
        centerTitle: true,
        actions: [
          // Ev Kapasitesi Rozeti
          GestureDetector(
            onTap: isHouseFull
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RealEstateScreen()),
                    );
                  }
                : null,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHouseFull ? GameColors.lossRed : GameColors.profitGreen,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hotel, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Ev: $currentMercsCount/$maxCapacity',
                    style: TextStyle(
                      color: isHouseFull ? GameColors.lossRed : GameColors.profitGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isHouseFull) ...[
                    const SizedBox(width: 4),
                    const Text('🏢+', style: TextStyle(color: GameColors.neonCyan, fontSize: 10)),
                  ],
                ],
              ),
            ),
          ),
          // Havuz Yenileme
          TextButton.icon(
            icon: const Icon(Icons.refresh, color: GameColors.neonCyan, size: 15),
            label: Text('$minutes:$seconds', style: const TextStyle(color: GameColors.neonCyan, fontSize: 10)),
            onPressed: () async {
              final success = await ref.read(tavernProvider.notifier).manualRefresh(payFee: true);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yetersiz bakiye! 100 ₺ gerekli.')),
                );
              }
            },
          ),
          // Zindan Hub Kısayolu
          IconButton(
            tooltip: 'Zindan Karargahı',
            icon: const Icon(Icons.castle, color: GameColors.gold, size: 20),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DungeonHubScreen()),
              );
            },
          ),
          // Cüzdan LED
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          const panoramaWidth = 1150.0;

          return Stack(
            children: [
              // 1. PANORAMİK İNTERAKTİF HAN GÖRSELİ (Yatay Kaydırılabilir Sahne)
              Positioned.fill(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: SingleChildScrollView(
                    controller: _tavernScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      width: panoramaWidth,
                      height: totalHeight,
                      child: Stack(
                        children: [
                          // Arka plan illüstrasyonu
                          Positioned.fill(
                            child: Image.asset(
                              GameAssetPaths.bgTavernPanoramic,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF221610),
                                child: const Center(
                                  child: Text('🍺 KARA EJDER HANI PANORAMASI', style: TextStyle(color: GameColors.gold)),
                                ),
                              ),
                            ),
                          ),

                          // Sahne Karartma & Işıklandırma Vinyeti
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.35),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. HAN MASALARINDAKİ SAVAŞÇILAR (İNTERAKTİF MASALAR & KONUŞMA BALONLARI)
                          ...tavernState.availablePool.map((merc) {
                            double leftPos;
                            final r = merc.role.toLowerCase();
                            if (r.contains('savaşçı') || r.contains('tank')) {
                              leftPos = 40;
                            } else if (r.contains('suikastçı') || r.contains('hırsız') || r.contains('asas')) {
                              leftPos = 250;
                            } else if (r.contains('okçu') || r.contains('avcı')) {
                              leftPos = 470;
                            } else if (r.contains('büyücü')) {
                              leftPos = 690;
                            } else {
                              leftPos = 900;
                            }

                            final isSelected = _selectedMerc?.id == merc.id;

                            return Positioned(
                              left: leftPos,
                              top: 20,
                              width: 220,
                              bottom: 60,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Masaya Dokunma Alanı (Karakter Tıklama Hotspot'u)
                                  Positioned(
                                    bottom: 10,
                                    left: 20,
                                    right: 20,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _inspectMercenary(merc),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: isSelected ? 0.92 : 0.8),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? GameColors.profitGreen : GameColors.gold.withValues(alpha: 0.6),
                                            width: isSelected ? 2.5 : 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected
                                                  ? GameColors.profitGreen.withValues(alpha: 0.4)
                                                  : Colors.black87,
                                              blurRadius: isSelected ? 12 : 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(merc.avatar, style: const TextStyle(fontSize: 22)),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    merc.name.split(' ').first,
                                                    style: GameTypography.display(
                                                      color: isSelected ? GameColors.profitGreen : Colors.white,
                                                      fontSize: 11,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${merc.role} • ${merc.baseCombatPower} CP',
                                              style: TextStyle(
                                                color: isSelected ? GameColors.goldLight : Colors.white60,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: GameColors.gold.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                isSelected ? 'KONUŞULUYOR 💬' : 'DOKUN VE KONUŞ 👆',
                                                style: TextStyle(
                                                  color: isSelected ? GameColors.profitGreen : GameColors.goldLight,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 3. SEÇİLİ KARAKTERİN KONUŞMA BALONU (Diegetic Speech Bubble)
                                  if (isSelected && _dialogueQuote != null)
                                    Positioned(
                                      top: 10,
                                      left: 0,
                                      right: 0,
                                      child: _buildSpeechBubble(
                                        merc: merc,
                                        quote: _dialogueQuote!,
                                        isHouseFull: isHouseFull,
                                        playerCash: profile.cash,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 4. SOL & SAĞ PANORAMA KAYDIRMA OKLARI
              Positioned(
                left: 10,
                top: totalHeight * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                    border: Border.all(color: GameColors.goldLight, width: 1.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: GameColors.goldLight, size: 24),
                    tooltip: 'Sola Kaydır',
                    onPressed: () {
                      _tavernScrollController.animateTo(
                        (_tavernScrollController.offset - 250).clamp(0.0, 900.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: totalHeight * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                    border: Border.all(color: GameColors.goldLight, width: 1.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, color: GameColors.goldLight, size: 24),
                    tooltip: 'Sağa Kaydır',
                    onPressed: () {
                      _tavernScrollController.animateTo(
                        (_tavernScrollController.offset + 250).clamp(0.0, 900.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              ),

              // 5. ALT ŞERİT: MASADAKİ KARAKTERLER HIZLI SEÇİM ÇUBUĞU
              Positioned(
                left: 16,
                right: 16,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141418).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GameColors.gold.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'MASALAR: ',
                        style: TextStyle(color: GameColors.goldLight, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: tavernState.availablePool.map((merc) {
                              final isSelected = _selectedMerc?.id == merc.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () => _inspectMercenary(merc),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? GameColors.gold.withValues(alpha: 0.25) : Colors.black45,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? GameColors.profitGreen : Colors.white12,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(merc.avatar, style: const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Text(
                                          merc.role,
                                          style: TextStyle(
                                            color: isSelected ? GameColors.goldLight : Colors.white70,
                                            fontSize: 10,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. FTUE REHBER SPOTLIGHT
              if (isTavernFTUE)
                Positioned(
                  left: 30,
                  top: 70,
                  child: const GuideArrowSpotlight(
                    text: 'Han masasında oturan savaşçıya dokun, onunla konuş ve ekibine kirala!',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Diegetik Konuşma Balonu & Kiralama Paneli
  Widget _buildSpeechBubble({
    required TavernMercenaryModel merc,
    required String quote,
    required bool isHouseFull,
    required int playerCash,
  }) {
    final canAfford = playerCash >= merc.hireDeposit;
    final canHire = !isHouseFull && canAfford;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF181A24).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.gold, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Konuşma Başlığı & Rol
          Row(
            children: [
              Text(merc.avatar, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${merc.name} (${merc.role})',
                      style: GameTypography.display(color: GameColors.goldLight, fontSize: 11),
                    ),
                    Text(
                      '"${merc.title}" • ${merc.baseCombatPower} CP',
                      style: const TextStyle(color: GameColors.profitGreen, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.white38, size: 16),
                onPressed: () {
                  setState(() {
                    _selectedMerc = null;
                    _dialogueQuote = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Karakter Replik Balonu (Quote)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              '"$quote"',
              style: GameTypography.body(color: Colors.white, fontSize: 10).copyWith(
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Uzmanlık Açıklaması
          Text(
            merc.specialtyDescription,
            style: const TextStyle(color: Colors.white60, fontSize: 9),
          ),
          const SizedBox(height: 8),

          // Ücret Bilgisi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Depozito: ${merc.hireDeposit} ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 10)),
              Text('Saatlik: ${merc.hourlyWage} ₺', style: const TextStyle(color: Colors.white38, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 8),

          // Kiralama Butonu veya Uyarı
          if (isHouseFull) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                '⚠️ Ev Asker Kapasitesi Dolu! Evi Yükseltin.',
                style: TextStyle(color: GameColors.lossRed, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ] else if (!canAfford) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                '⚠️ Yetersiz Bakiye! Daha fazla para gerekli.',
                style: TextStyle(color: GameColors.alertOrange, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          ArcadeButton(
            text: 'KİRALA 🤝 (${merc.hireDeposit} ₺)',
            icon: Icons.person_add,
            onPressed: canHire ? () => _hireMercenary(merc) : null,
            primaryColor: canHire ? GameColors.gold : Colors.grey,
            shadowColor: canHire ? const Color(0xFF8C711C) : Colors.black26,
            textColor: Colors.black,
            height: 36,
            fontSize: 10,
          ),
        ],
      ),
    );
  }
}

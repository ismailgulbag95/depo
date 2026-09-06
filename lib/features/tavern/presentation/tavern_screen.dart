import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/home/presentation/home_screen.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
import 'package:yeni_oyun_sablon/features/onboarding/widgets/ftue_guide_overlay.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/real_estate/presentation/real_estate_screen.dart';
import 'package:yeni_oyun_sablon/features/tavern/models/tavern_mercenary_model.dart';
import 'package:yeni_oyun_sablon/features/tavern/providers/tavern_provider.dart';

/// 🍺 Han & Paralı Asker Loncası Ekranı (TavernScreen)
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
  void dispose() {
    _tavernScrollController.dispose();
    super.dispose();
  }

  final Map<String, String> _quotes = {
    'Savaşçı': 'Kılıcım keskin, zırhım sağlam! Ne zaman sefere çıkıyoruz patron?',
    'Okçu': 'Gölgelerden vururum, hedefim asla şaşmaz. Zindan haritalarını hazırla!',
    'Büyücü': 'Kadim parşömenlerin gücü benimle. O canavarları tek hamlede küle çevirebilirim!',
    'Şövalye': 'Onurum ve kalkanım emrinde! Ekibini her türlü tehlikeden korurum.',
    'Hırsız': 'Tuzakları etkisiz hale getirir, kilitli sandıkları tereyağından kıl çeker gibi açarım.',
  };

  void _inspectMercenary(TavernMercenaryModel merc) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMerc = merc;
      _dialogueQuote = _quotes[merc.role] ?? 'Hazine kokusu alıyorum patron, beni ekibine al pişman olmazsın!';
    });
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
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        title: Text(
          '🍺 HAN & PARALI ASKER LONCASI',
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
        child: Column(
          children: [
            const HazardStripeBanner(height: 5),

            // FTUE Kılavuz Oku
            if (isTavernFTUE)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: GuideArrowSpotlight(
                  text: 'Kara Ejder Hanı\'na hoş geldin! İlk paralı askerini seçip "KİRALA" butonuna bas.',
                ),
              ),

            // Seçili NPC Replik ve Stat İnceleme Paneli
            if (_selectedMerc != null && _dialogueQuote != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: DiegeticMetalPanel(
                  padding: const EdgeInsets.all(12),
                  borderColor: GameColors.neonCyan,
                  borderWidth: 1.5,
                  glowColor: GameColors.neonCyan,
                  borderRadius: 12,
                  child: Row(
                    children: [
                      Text(_selectedMerc!.avatar, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedMerc!.name} (${_selectedMerc!.role})',
                              style: GameTypography.display(color: GameColors.neonCyan, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '"$_dialogueQuote"',
                              style: GameTypography.body(color: Colors.white, fontSize: 11).copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Panoramik İnteraktif Han İçi Görseli
            _buildPanoramicTavernBanner(tavernState),

            // Han Başlık ve Kapasite Bilgi Paneli
            Container(
              margin: const EdgeInsets.all(12),
              child: DiegeticMetalPanel(
                padding: const EdgeInsets.all(12),
                borderColor: GameColors.gold,
                borderWidth: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('🍺', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kara Ejder Hanı', style: GameTypography.display(color: GameColors.gold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                'Zindan seferleri için maceracılar kiralayın. Kiraladığınız askerler evinizin Dinlenme Odasında hazır bekler.',
                                style: GameTypography.body(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Ev Asker Kapasitesi: ', style: GameTypography.body(color: Colors.white60, fontSize: 11)),
                            Text(
                              '$currentMercsCount / $maxCapacity',
                              style: GameTypography.display(
                                color: isHouseFull ? GameColors.lossRed : GameColors.profitGreen,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (isHouseFull)
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RealEstateScreen()),
                              );
                            },
                            child: Text(
                              'Evi Yükselt 🏢',
                              style: GameTypography.body(
                                color: GameColors.neonCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ).copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Havuz Yenileme ve Durum Çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, color: GameColors.hazardYellow, size: 16),
                      const SizedBox(width: 4),
                      Text('Havuz Yenileniyor: $minutes:$seconds', style: GameTypography.body(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, color: GameColors.neonCyan, size: 16),
                    label: const Text('Yenile (100 ₺)', style: TextStyle(color: GameColors.neonCyan, fontSize: 10)),
                    onPressed: () async {
                      final success = await ref.read(tavernProvider.notifier).manualRefresh(payFee: true);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Yetersiz bakiye! 100 ₺ gerekli.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Paralı Asker İlan Kartları Listesi
            Expanded(
              child: tavernState.availablePool.isEmpty
                  ? const Center(child: Text('Şu an handa uygun maceracı yok.', style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: tavernState.availablePool.length,
                      itemBuilder: (context, index) {
                        final merc = tavernState.availablePool[index];
                        final isFirst = index == 0;
                        return GestureDetector(
                          onTap: () => _inspectMercenary(merc),
                          child: _buildTavernMercenaryCard(
                            context,
                            ref,
                            merc,
                            isHouseFull,
                            isFirst && isTavernFTUE,
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

  Widget _buildPanoramicTavernBanner(TavernState tavernState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.gold, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Panoramik Görsel Alanı
          SizedBox(
            height: 190,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  ScrollConfiguration(
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
                        width: 900,
                        height: 190,
                        child: Stack(
                          children: [
                            // Panoramik Han Arka Planı
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

                            // Karakter Masası İnteraktif Dokunma Alanları
                            ...tavernState.availablePool.map((merc) {
                              double leftPos;
                              double widthBox = 130;
                              final r = merc.role.toLowerCase();
                              if (r.contains('savaşçı') || r.contains('tank')) {
                                leftPos = 30;
                              } else if (r.contains('suikastçı') || r.contains('hırsız') || r.contains('asas')) {
                                leftPos = 200;
                              } else if (r.contains('okçu') || r.contains('avcı')) {
                                leftPos = 370;
                              } else if (r.contains('büyücü')) {
                                leftPos = 550;
                              } else {
                                leftPos = 720;
                              }
                              final isSelected = _selectedMerc?.id == merc.id;

                              return Positioned(
                                left: leftPos,
                                top: 20,
                                width: widthBox,
                                bottom: 16,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _inspectMercenary(merc),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? GameColors.profitGreen : Colors.transparent,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? GameColors.profitGreen.withValues(alpha: 0.15)
                                          : null,
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected ? GameColors.profitGreen : GameColors.gold,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(merc.avatar, style: const TextStyle(fontSize: 13)),
                                            const SizedBox(width: 4),
                                            Text(
                                              merc.name.split(' ').first,
                                              style: GameTypography.display(
                                                color: isSelected ? GameColors.profitGreen : Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sol Kaydırma Oku
                  Positioned(
                    left: 4,
                    top: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(color: GameColors.goldLight, width: 1),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left, color: GameColors.goldLight, size: 22),
                        tooltip: 'Sola Kaydır',
                        onPressed: () {
                          _tavernScrollController.animateTo(
                            (_tavernScrollController.offset - 200).clamp(0.0, 900.0),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                  ),

                  // Sağ Kaydırma Oku
                  Positioned(
                    right: 4,
                    top: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(color: GameColors.goldLight, width: 1),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_right, color: GameColors.goldLight, size: 22),
                        tooltip: 'Sağa Kaydır',
                        onPressed: () {
                          _tavernScrollController.animateTo(
                            (_tavernScrollController.offset + 200).clamp(0.0, 900.0),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                  ),

                  // Kaydırma / Dokunma İpucu
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pan_tool_alt, color: GameColors.goldLight, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Sürükle veya Oklara Bas',
                            style: GameTypography.body(color: GameColors.goldLight, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Karakter Hızlı Geçiş Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF16141D),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tavernState.availablePool.map((merc) {
                  final isSelected = _selectedMerc?.id == merc.id;
                  double targetOffset = 0;
                  final r = merc.role.toLowerCase();
                  if (r.contains('savaşçı') || r.contains('tank')) {
                    targetOffset = 0;
                  } else if (r.contains('suikastçı') || r.contains('hırsız') || r.contains('asas')) {
                    targetOffset = 140;
                  } else if (r.contains('okçu') || r.contains('avcı')) {
                    targetOffset = 300;
                  } else if (r.contains('büyücü')) {
                    targetOffset = 450;
                  } else {
                    targetOffset = 600;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        _inspectMercenary(merc);
                        _tavernScrollController.animateTo(
                          targetOffset,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? GameColors.gold.withValues(alpha: 0.25) : Colors.black38,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? GameColors.gold : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(merc.avatar, style: const TextStyle(fontSize: 12)),
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
    );
  }

  Widget _buildTavernMercenaryCard(
    BuildContext context,
    WidgetRef ref,
    TavernMercenaryModel merc,
    bool isHouseFull,
    bool isFTUEHighlight,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: DiegeticMetalPanel(
        padding: const EdgeInsets.all(10),
        borderColor: isFTUEHighlight ? GameColors.gold : GameColors.panelBorder,
        borderWidth: isFTUEHighlight ? 2.5 : 1.5,
        glowColor: isFTUEHighlight ? GameColors.gold : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(merc.avatar, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(merc.name, style: GameTypography.display(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 4),
                      Text('"${merc.title}"', style: GameTypography.body(color: GameColors.goldLight, fontSize: 10).copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${merc.role} • Taban Güç: ${merc.baseCombatPower} CP', style: GameTypography.body(color: GameColors.gold, fontSize: 10)),
                  Text(merc.specialtyDescription, style: GameTypography.body(color: Colors.white54, fontSize: 9)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Depozito: ${merc.hireDeposit} ₺', style: GameTypography.led(color: GameColors.profitGreen, fontSize: 10)),
                      const SizedBox(width: 10),
                      Text('Saatlik: ${merc.hourlyWage} ₺', style: GameTypography.body(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            ArcadeButton(
              text: 'KİRALA 🤝',
              icon: Icons.person_add,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final result = await ref.read(tavernProvider.notifier).hireMercenary(merc);
                if (!context.mounted) return;

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
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen(initialTabIndex: 1)),
                      );
                    }
                  });
                }
              },
              primaryColor: isHouseFull ? Colors.grey : (isFTUEHighlight ? GameColors.profitGreen : GameColors.gold),
              shadowColor: isHouseFull ? Colors.black38 : (isFTUEHighlight ? const Color(0xFF00893E) : const Color(0xFF8C711C)),
              textColor: Colors.black,
              height: 40,
              fontSize: 11,
            ),
          ],
        ),
      ),
    );
  }
}

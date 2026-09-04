import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/auction_stamp.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/game_screen_shake.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/dungeon/models/mercenary_model.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// Zindan Seferleri & Kışla Dinlenme Odası Ana Ekranı (ADR-030)
class DungeonHubScreen extends ConsumerStatefulWidget {
  const DungeonHubScreen({super.key});

  @override
  ConsumerState<DungeonHubScreen> createState() => _DungeonHubScreenState();
}

class _DungeonHubScreenState extends ConsumerState<DungeonHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GameScreenShakeController _shakeController = GameScreenShakeController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dungeonState = ref.watch(dungeonProvider);
    final playerProfile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: GameScreenShake(
          controller: _shakeController,
          child: Column(
            children: [
              // 1. Üst Bar: Kasa & İtibar HUD
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
                          const Icon(Icons.castle, color: GameColors.gold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'ZİNDAN & KIŞLA KARARGAHI',
                            style: GameTypography.display(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    RetroLedDisplay(
                      label: 'İTİBAR',
                      value: '${playerProfile.reputation} XP',
                      ledColor: GameColors.goldLight,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),

              // Sekmeler (Tabs)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: GameColors.panelDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GameColors.panelBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: GameColors.gold,
                  labelColor: GameColors.goldLight,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: GameTypography.display(fontSize: 11),
                  tabs: const [
                    Tab(icon: Icon(Icons.explore, size: 18), text: 'SEFERLER'),
                    Tab(icon: Icon(Icons.weekend, size: 18), text: 'DİNLENME ODASI'),
                    Tab(icon: Icon(Icons.shield, size: 18), text: 'BİRLİKLER'),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: HazardStripeBanner(height: 5),
              ),
              const SizedBox(height: 6),

              // Sekme İçerikleri
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. Zindan Seferleri Sekmesi
                    _buildExpeditionsTab(dungeonState),

                    // 2. Kışla Dinlenme Odası Sekmesi
                    _buildLoungeRoomTab(dungeonState),

                    // 3. Paralı Asker & Ekipman Sekmesi
                    _buildMercenariesTab(dungeonState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Sekme: Zindan Seferleri
  Widget _buildExpeditionsTab(DungeonState state) {
    if (state.activeExpedition != null) {
      final exp = state.activeExpedition!;
      return Padding(
        padding: const EdgeInsets.all(14),
        child: DiegeticMetalPanel(
          padding: const EdgeInsets.all(16),
          showRivets: true,
          borderColor: GameColors.gold,
          glowColor: GameColors.gold,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '⚔️ SEFER DEVAM EDİYOR...',
                style: GameTypography.display(color: GameColors.goldLight, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                exp.dungeonName.toUpperCase(),
                style: GameTypography.display(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 16),
              RetroLedDisplay(
                icon: Icons.timer,
                value: '${exp.remainingSeconds} SN KALDI',
                ledColor: GameColors.neonCyan,
                fontSize: 20,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (exp.durationSeconds - exp.remainingSeconds) / exp.durationSeconds,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(GameColors.neonCyan),
                minHeight: 8,
              ),
              const SizedBox(height: 14),
              Text(
                'Birlikleriniz zindandaki canavarlarla savaşıyor. Sonuç raporu bekleniyor...',
                style: GameTypography.body(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final dungeons = [
      (name: 'Terk Edilmiş Mahzen', diff: 60, time: 20, icon: Icons.door_sliding),
      (name: 'Eski Maden Ocağı', diff: 120, time: 30, icon: Icons.terrain),
      (name: 'Antik Kript & Mezarlık', diff: 220, time: 45, icon: Icons.account_balance),
    ];

    final readyMercs = state.mercenaries.where((m) => m.status == MercenaryStatus.ready).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      children: [
        if (state.lastResult != null) _buildResultReportCard(state.lastResult!),
        ...dungeons.map((d) {
          final canStart = readyMercs.isNotEmpty;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: DiegeticMetalPanel(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: GameColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GameColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Icon(d.icon, color: GameColors.gold, size: 26),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: GameTypography.display(color: Colors.white, fontSize: 12)),
                        Text(
                          'Zorluk: ${d.diff} Güç • Süre: ${d.time} sn',
                          style: GameTypography.body(color: Colors.white60, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  ArcadeButton(
                    text: canStart ? 'SEFERE ÇIK ⚔️' : 'DİNLENİYOR ⏳',
                    onPressed: canStart
                        ? () {
                            ref.read(dungeonProvider.notifier).startExpedition(
                                  mercenaryId: readyMercs.first.id,
                                  dungeonName: d.name,
                                  dungeonDifficulty: d.diff,
                                  durationSeconds: d.time,
                                );
                            HapticFeedback.heavyImpact();
                          }
                        : null,
                    primaryColor: canStart ? GameColors.gold : Colors.white24,
                    shadowColor: canStart ? const Color(0xFF8C711C) : Colors.black45,
                    height: 38,
                    fontSize: 9,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Sonuç Rapor Kartı
  Widget _buildResultReportCard(ExpeditionResult res) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DiegeticMetalPanel(
        padding: const EdgeInsets.all(14),
        borderColor: res.isVictory ? GameColors.profitGreen : GameColors.lossRed,
        glowColor: res.isVictory ? GameColors.profitGreen : GameColors.lossRed,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuctionStamp(
                  text: res.isVictory ? 'ZAFER VE GANİMET' : 'YENİLGİ (3X DİNLENME)',
                  color: res.isVictory ? GameColors.profitGreen : GameColors.lossRed,
                  fontSize: 16,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              res.isVictory
                  ? 'Zindandan zaferle dönüldü! +${res.goldEarned} ₺ Altın ve +${res.xpEarned} XP İtibar kazanıldı.'
                  : 'Savaşçılar mağlup oldu. Eşyalar hasar görmedi ancak iyileşmek için ${res.cooldownAppliedSeconds} sn dinlenecekler.',
              style: GameTypography.body(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Sekme: Kışla Dinlenme Odası & Konfor Sistemi (ADR-030)
  Widget _buildLoungeRoomTab(DungeonState state) {
    final comfort = state.lounge.totalComfortScore;
    final discountPercent = ((1.0 - state.lounge.restSpeedMultiplier) * 100).toInt();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      children: [
        // Konfor Skoru & İndirim Paneli
        DiegeticMetalPanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ODA KONFOR SKORU',
                    style: GameTypography.display(color: Colors.white, fontSize: 12),
                  ),
                  RetroLedDisplay(
                    icon: Icons.hotel,
                    value: '$comfort PUAN',
                    ledColor: GameColors.gold,
                    fontSize: 14,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DİNLENME HIZI ARTIŞI:',
                    style: GameTypography.body(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '+%$discountPercent Daha Hızlı Dinlenme ⚡',
                    style: GameTypography.body(color: GameColors.profitGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '💡 Depolardan ve atölyeden topladığınız koltuk, radyo, tablo ve antika mobilyaları kışlaya yerleştirerek savaşçıların bekleme süresini kısaltabilirsiniz.',
                style: GameTypography.body(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Text(
          'DİNLENEN SAVAŞÇILARIN DURUMU',
          style: GameTypography.display(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 8),

        ...state.mercenaries.map((m) {
          final isResting = m.status == MercenaryStatus.resting;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: DiegeticMetalPanel(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(m.avatar, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: GameTypography.display(color: Colors.white, fontSize: 12)),
                        Text(
                          isResting ? '🛌 Dinleniyor (Kalan: ${m.restTimeRemainingSeconds} sn)' : '✅ Sefer İçin Hazır',
                          style: GameTypography.body(
                            color: isResting ? GameColors.alertOrange : GameColors.profitGreen,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 3. Sekme: Paralı Askerler & Kuşanma
  Widget _buildMercenariesTab(DungeonState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      children: state.mercenaries.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: DiegeticMetalPanel(
            padding: const EdgeInsets.all(12),
            showRivets: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(m.avatar, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: GameTypography.display(color: Colors.white, fontSize: 13)),
                        Text(m.role, style: GameTypography.body(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                    const Spacer(),
                    RetroLedDisplay(
                      label: 'GÜÇ',
                      value: '${m.totalCombatPower}',
                      ledColor: GameColors.neonCyan,
                      fontSize: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Kuşanılan Ekipmanlar: ${m.equippedItems.isEmpty ? "Henüz donatılmadı" : m.equippedItems.map((e) => e.name).join(", ")}',
                  style: GameTypography.body(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

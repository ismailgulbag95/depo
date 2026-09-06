import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

class RealEstateProperty {
  final int tier;
  final String name;
  final String description;
  final int maxMercenaries;
  final int comfortBonus;
  final int price;
  final int requiredReputation;
  final String icon;

  const RealEstateProperty({
    required this.tier,
    required this.name,
    required this.description,
    required this.maxMercenaries,
    required this.comfortBonus,
    required this.price,
    required this.requiredReputation,
    required this.icon,
  });
}

/// 🏢 Emlakçı & Mülk Yönetimi (RealEstateScreen)
class RealEstateScreen extends ConsumerWidget {
  const RealEstateScreen({super.key});

  static const List<RealEstateProperty> properties = [
    RealEstateProperty(
      tier: 1,
      name: 'Garajlı Şehir Dairesi',
      description: 'Temel yaşam alanı. Maksimum 2 paralı asker barındırabilir.',
      maxMercenaries: 2,
      comfortBonus: 50,
      price: 0,
      requiredReputation: 0,
      icon: '🏢',
    ),
    RealEstateProperty(
      tier: 2,
      name: 'Müstakil Banliyö Evi',
      description: 'Bahçeli geniş ev. 4 paralı asker kışlası ve daha hızlı dinlenme süresi.',
      maxMercenaries: 4,
      comfortBonus: 120,
      price: 5000,
      requiredReputation: 150,
      icon: '🏡',
    ),
    RealEstateProperty(
      tier: 3,
      name: 'Geniş Çiftlik Evi & Atölye',
      description: 'Büyük arazi, 6 paralı asker kapasitesi ve zanaat atölyesi bonusları.',
      maxMercenaries: 6,
      comfortBonus: 250,
      price: 18000,
      requiredReputation: 500,
      icon: '🌾',
    ),
    RealEstateProperty(
      tier: 4,
      name: 'Lüks Malikane & Karargah',
      description: 'Şehrin zirvesi. 10 paralı asker ordusu, devasa kışla ve maksimum konfor.',
      maxMercenaries: 10,
      comfortBonus: 600,
      price: 60000,
      requiredReputation: 1200,
      icon: '🏰',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        title: Text(
          '🏢 PRESTİJ EMLAK & KONUT OFİSİ',
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

            // Emlakçı Başlık
            Container(
              margin: const EdgeInsets.all(12),
              child: DiegeticMetalPanel(
                padding: const EdgeInsets.all(12),
                borderColor: GameColors.gold,
                borderWidth: 2,
                child: Row(
                  children: [
                    const Text('🏢', style: TextStyle(fontSize: 34)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prestij Emlak & Karargah Ofisi', style: GameTypography.display(color: GameColors.gold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            'Ev seviyenizi yükselterek Han\'dan kiralayabileceğiniz maksimum paralı asker sayısını ve kışla konforunu artırın.',
                            style: GameTypography.body(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  final isOwned = profile.ownedHomeTier >= prop.tier;
                  final isCurrent = profile.ownedHomeTier == prop.tier;
                  final hasRep = profile.reputation >= prop.requiredReputation;
                  final hasCash = profile.cash >= prop.price;
                  final canBuy = !isOwned && hasRep && hasCash && profile.ownedHomeTier == (prop.tier - 1);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: DiegeticMetalPanel(
                      padding: const EdgeInsets.all(10),
                      borderColor: isCurrent ? GameColors.gold : (isOwned ? GameColors.profitGreen : GameColors.panelBorder),
                      borderWidth: isCurrent ? 2 : 1.5,
                      glowColor: isCurrent ? GameColors.gold : null,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(prop.icon, style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(prop.name, style: GameTypography.display(color: Colors.white, fontSize: 12)),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(color: GameColors.gold, borderRadius: BorderRadius.circular(3)),
                                        child: const Text('MEVCUT EV', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(prop.description, style: GameTypography.body(color: Colors.white60, fontSize: 9)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('Maks ${prop.maxMercenaries} Asker', style: GameTypography.body(color: GameColors.goldLight, fontSize: 9, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Text('+${prop.comfortBonus} Konfor', style: GameTypography.body(color: GameColors.neonCyan, fontSize: 9)),
                                    if (!isOwned) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${prop.requiredReputation} İtibar)',
                                        style: TextStyle(color: hasRep ? GameColors.profitGreen : GameColors.lossRed, fontSize: 9),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isOwned)
                            const Icon(Icons.check_circle, color: GameColors.profitGreen, size: 26)
                          else
                            ArcadeButton(
                              text: '${prop.price} ₺ SATIN AL',
                              icon: Icons.home,
                              onPressed: canBuy
                                  ? () async {
                                      HapticFeedback.heavyImpact();
                                      final success = await ref.read(playerProfileProvider.notifier).upgradeHomeTier(prop.tier, prop.price);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${prop.name} satın alındı! Yeni asker kapasitesi: ${prop.maxMercenaries}'),
                                            backgroundColor: GameColors.profitGreen,
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              primaryColor: canBuy ? GameColors.gold : Colors.grey,
                              shadowColor: const Color(0xFF8C711C),
                              textColor: Colors.black,
                              height: 36,
                              fontSize: 9,
                            ),
                        ],
                      ),
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

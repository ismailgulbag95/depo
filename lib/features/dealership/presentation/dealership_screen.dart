import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/vehicle_model.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/trunk_tetris/providers/trunk_inventory_provider.dart';

class VehicleDealItem {
  final int id;
  final String name;
  final String subtitle;
  final int gridWidth;
  final int gridHeight;
  final double maxWeightKg;
  final int price;
  final String imagePath;

  const VehicleDealItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.gridWidth,
    required this.gridHeight,
    required this.maxWeightKg,
    required this.price,
    required this.imagePath,
  });
}

/// 🚗 Galeri & Araç Bayisi (DealershipScreen)
class DealershipScreen extends ConsumerWidget {
  const DealershipScreen({super.key});

  static const List<VehicleDealItem> vehicles = [
    VehicleDealItem(
      id: 1,
      name: 'Eski Model Pikap',
      subtitle: 'Başlangıç aracı. Şehir içi depolar için ideal.',
      gridWidth: 8,
      gridHeight: 12,
      maxWeightKg: 500,
      price: 0,
      imagePath: 'assets/vehicles/trunk_pickup.jpg',
    ),
    VehicleDealItem(
      id: 2,
      name: 'Geniş Panel Van',
      subtitle: 'Daha büyük kasa ve %80 daha fazla taşıma kapasitesi.',
      gridWidth: 10,
      gridHeight: 14,
      maxWeightKg: 900,
      price: 2500,
      imagePath: 'assets/vehicles/trunk_van.jpg',
    ),
    VehicleDealItem(
      id: 3,
      name: 'Ağır Kamyonet',
      subtitle: 'Mobilya ve sanayi depolarını tek seferde boşaltın.',
      gridWidth: 12,
      gridHeight: 16,
      maxWeightKg: 1500,
      price: 7500,
      imagePath: 'assets/vehicles/trunk_truck.jpg',
    ),
    VehicleDealItem(
      id: 4,
      name: 'Ticari Çekici & Tır',
      subtitle: 'Maksimum bagaj ızgarası ve 3 tonluk devasa taşıma gücü.',
      gridWidth: 14,
      gridHeight: 20,
      maxWeightKg: 3000,
      price: 25000,
      imagePath: 'assets/vehicles/vehicle_emergency_tow.jpg',
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
          '🚗 OTO GALERİ & ARAÇ FİLOSU',
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

            // Galeri Başlık
            Container(
              margin: const EdgeInsets.all(12),
              child: DiegeticMetalPanel(
                padding: const EdgeInsets.all(12),
                borderColor: GameColors.neonCyan,
                borderWidth: 2,
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: GameColors.neonCyan, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enis Usta Galeri & Modifiye', style: GameTypography.display(color: Colors.white, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            'Daha büyük bagaj ızgarası ve daha yüksek yük kapasitesi için araçlarınızı yükseltin.',
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
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final v = vehicles[index];
                  final isOwned = profile.ownedVehicleIds.contains(v.id);
                  final isActive = profile.activeVehicleId == v.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: DiegeticMetalPanel(
                      padding: const EdgeInsets.all(10),
                      borderColor: isActive ? GameColors.gold : (isOwned ? GameColors.profitGreen : GameColors.panelBorder),
                      borderWidth: isActive ? 2 : 1.5,
                      glowColor: isActive ? GameColors.gold : null,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              v.imagePath,
                              width: 70,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 70,
                                height: 60,
                                color: Colors.black45,
                                child: const Icon(Icons.local_shipping, color: Colors.amber),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(v.name, style: GameTypography.display(color: Colors.white, fontSize: 12)),
                                    if (isActive) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(color: GameColors.gold, borderRadius: BorderRadius.circular(3)),
                                        child: const Text('AKTİF', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(v.subtitle, style: GameTypography.body(color: Colors.white60, fontSize: 9)),
                                const SizedBox(height: 4),
                                Text(
                                  'Izgara: ${v.gridWidth}x${v.gridHeight} (${v.gridWidth * v.gridHeight} Hücre) • Kapasite: ${v.maxWeightKg.toInt()} kg',
                                  style: GameTypography.body(color: GameColors.neonCyan, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            const Icon(Icons.check_circle, color: GameColors.gold, size: 28)
                          else if (isOwned)
                            ArcadeButton(
                              text: 'KULLAN 🔑',
                              icon: Icons.vpn_key,
                              onPressed: () async {
                                HapticFeedback.mediumImpact();
                                await ref.read(playerProfileProvider.notifier).switchActiveVehicle(v.id);
                                await ref.read(trunkInventoryProvider.notifier).loadActiveVehicle();
                              },
                              primaryColor: GameColors.profitGreen,
                              shadowColor: const Color(0xFF006622),
                              textColor: Colors.black,
                              height: 36,
                              fontSize: 9,
                            )
                          else
                            ArcadeButton(
                              text: '${v.price} ₺ SATIN AL',
                              icon: Icons.shopping_cart,
                              onPressed: profile.cash >= v.price
                                  ? () async {
                                      HapticFeedback.heavyImpact();
                                      final success = await ref.read(playerProfileProvider.notifier).buyVehicle(v.id, v.price);
                                      if (success) {
                                        // Araç modelini DB'ye de kaydet
                                        final newVeh = VehicleModel(
                                          id: v.id,
                                          name: v.name,
                                          gridWidth: v.gridWidth,
                                          gridHeight: v.gridHeight,
                                          maxWeightKg: v.maxWeightKg,
                                        );
                                        await DatabaseService.instance.saveVehicle(newVeh);
                                        await ref.read(trunkInventoryProvider.notifier).loadActiveVehicle();
                                      }
                                    }
                                  : null,
                              primaryColor: profile.cash >= v.price ? GameColors.gold : Colors.grey,
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

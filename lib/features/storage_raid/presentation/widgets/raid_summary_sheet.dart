import 'package:flutter/material.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/auction_stamp.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';

/// Raid Sonu Resmî Tasfiye ve Temizlik Faturası Rapor Kartı (ADR-015, ADR-023, ADR-025)
class RaidSummarySheet extends StatelessWidget {
  final int loadedItemsCount;
  final int totalScrapIncome;
  final int transportCosts;
  final int cleanupPenalty;
  final bool isMasterPacker;
  final VoidCallback onContinue;

  const RaidSummarySheet({
    super.key,
    required this.loadedItemsCount,
    required this.totalScrapIncome,
    required this.transportCosts,
    required this.cleanupPenalty,
    this.isMasterPacker = false,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final netProfit = totalScrapIncome - transportCosts - cleanupPenalty;
    final isProfit = netProfit >= 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: DiegeticMetalPanel(
        padding: const EdgeInsets.all(18),
        borderColor: isProfit ? GameColors.gold : GameColors.lossRed,
        borderWidth: 2,
        showRivets: true,
        glowColor: isProfit ? GameColors.gold : GameColors.lossRed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Tehlike İkaz Şeridi
            const HazardStripeBanner(height: 8),
            const SizedBox(height: 12),

            // Resmî İhale Mührü ve Başlık
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: GameColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: GameColors.gold, width: 1.5),
                    ),
                    child: Text(
                      'RESMÎ İHALE TASFİYE FATURASI',
                      style: GameTypography.display(
                        color: GameColors.goldLight,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Depo Boşaltma & Sefer Hesap Özeti',
                    style: GameTypography.body(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: GameColors.panelBorder, thickness: 1.5),
            const SizedBox(height: 10),

            // Satırlar: Yüklenen Eşyalar (Değer gizli, satışta keşfedilecek)
            _buildRow(
              icon: Icons.inventory_2_outlined,
              iconColor: GameColors.profitGreen,
              label: 'Araca Yüklenen Ganimetler',
              value: '$loadedItemsCount Adet Eşya',
              valueColor: Colors.white,
            ),
            const SizedBox(height: 8),

            // Usta İstifçi Başarı Bonusu (%80+ Doluluk)
            if (isMasterPacker) ...[
              _buildRow(
                icon: Icons.workspace_premium,
                iconColor: GameColors.gold,
                label: '🏆 Usta İstifçi Bonusu (%80+ Doluluk)',
                value: '+150 İtibar (XP)',
                valueColor: GameColors.goldLight,
              ),
              const SizedBox(height: 8),
            ],

            // Hurda Toplam Geliri (+)
            _buildRow(
              icon: Icons.recycling_outlined,
              iconColor: GameColors.profitGreen,
              label: 'Hurda Tasfiye Geliri',
              value: '+$totalScrapIncome ₺',
              valueColor: GameColors.profitGreen,
            ),
            const SizedBox(height: 8),

            // Ek Nakliye Masrafı (-)
            if (transportCosts > 0) ...[
              _buildRow(
                icon: Icons.local_shipping_outlined,
                iconColor: GameColors.alertOrange,
                label: 'Acil Nakliye Bedeli',
                value: '-$transportCosts ₺',
                valueColor: GameColors.alertOrange,
              ),
              const SizedBox(height: 8),
            ],

            // Temizlik Cezası (-)
            if (cleanupPenalty > 0) ...[
              _buildRow(
                icon: Icons.warning_amber_rounded,
                iconColor: GameColors.lossRed,
                label: 'Kalan Eşya Temizlik Cezası',
                value: '-$cleanupPenalty ₺',
                valueColor: GameColors.lossRed,
              ),
              const SizedBox(height: 8),
            ],

            const Divider(color: GameColors.panelBorder, thickness: 1.5),
            const SizedBox(height: 10),

            // Net Kâr / Zarar LED Skorbordu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NET SEFER BİLANÇOSU',
                  style: GameTypography.display(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                RetroLedDisplay(
                  value: '${isProfit ? "+" : ""}$netProfit ₺',
                  ledColor: isProfit
                      ? GameColors.profitGreen
                      : GameColors.lossRed,
                  fontSize: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Mühür / Damga Görünümü (SATILDI / KÂRLI)
            Center(
              child: AuctionStamp(
                text: isProfit ? 'KÂRLI SEFER' : 'ZARAR EDİLDİ',
                color: isProfit ? GameColors.profitGreen : GameColors.lossRed,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Onay Arcade Butonu
            ArcadeButton(
              text: 'FATURAYI ONAYLA VE DEVAM ET 📋',
              icon: Icons.check_circle_outline,
              onPressed: onContinue,
              primaryColor: isProfit ? GameColors.gold : GameColors.alertOrange,
              shadowColor: isProfit
                  ? const Color(0xFF8C711C)
                  : const Color(0xFFB24800),
              textColor: Colors.black,
              height: 48,
              fontSize: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GameTypography.body(color: Colors.white70, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: GameTypography.led(color: valueColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

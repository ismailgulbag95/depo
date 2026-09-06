import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/features/dungeon/presentation/dungeon_hub_screen.dart';

/// Zindan Savaşçı Ekipmanı ve Karargah Tanıtım Rehberi (ADR-030 & Tutorial)
class DungeonEquipmentGuideSheet extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onDismiss;

  const DungeonEquipmentGuideSheet({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  /// Diyaloğu zengin ses & titreşim eşliğinde ekranda gösterir
  static void show(BuildContext context, {required ItemModel item, required VoidCallback onDismiss}) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DungeonEquipmentGuideSheet(
        item: item,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Eşyanın zindan savaşçılarına giydirilebilir bir donanım olup olmadığını kontrol eder
  static bool isEquipableDungeonGear(ItemModel item) {
    final lower = '${item.code} ${item.category} ${item.nameTr}'.toLowerCase();
    return lower.contains('yelek') ||
        lower.contains('migfer') ||
        lower.contains('gogusluk') ||
        lower.contains('zirh') ||
        lower.contains('bicak') ||
        lower.contains('silah') ||
        lower.contains('eldiven') ||
        lower.contains('dizlik') ||
        lower.contains('taktik') ||
        lower.contains('kalkan') ||
        lower.contains('bot') ||
        lower.contains('kask');
  }

  @override
  Widget build(BuildContext context) {
    final combatPower = (item.baseValue * 0.5).round();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16171E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GameColors.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: GameColors.gold.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Üst Başlık & Rozet
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF22201C),
                  border: Border(bottom: BorderSide(color: GameColors.panelBorder, width: 2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: GameColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GameColors.gold, width: 1.5),
                      ),
                      child: const Icon(Icons.shield, color: GameColors.gold, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REHBER • ZİNDAN SAVAŞÇI EKİPMANI',
                            style: GameTypography.display(
                              color: GameColors.neonCyan,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Paralı Asker Zırh & Silah Sistemi',
                            style: GameTypography.display(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Eşya Önizleme & Stat Kartı
              Padding(
                padding: const EdgeInsets.all(14),
                child: DiegeticMetalPanel(
                  padding: const EdgeInsets.all(12),
                  borderColor: GameColors.gold,
                  borderWidth: 1.5,
                  showRivets: false,
                  backgroundColor: const Color(0xFF1E202B),
                  child: Row(
                    children: [
                      // Eşya Görseli
                      Container(
                        width: 70,
                        height: 70,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GameColors.goldLight, width: 1.5),
                        ),
                        child: Image.asset(
                          item.spritePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.shield,
                            color: GameColors.gold,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Eşya Bilgileri & Savaş Gücü
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nameTr,
                              style: GameTypography.display(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: GameColors.profitGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: GameColors.profitGreen, width: 1),
                                  ),
                                  child: Text(
                                    '+$combatPower SAVAŞ GÜCÜ (CP)',
                                    style: GameTypography.display(
                                      color: GameColors.profitGreen,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Değer: ${item.baseValue} ₺ • Ağırlık: ${item.weight} kg',
                              style: GameTypography.body(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Rehber Anlatım Metni (Dungeon Rehberi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13141A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.panelBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_stories, color: GameColors.hazardYellow, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'NASIL KULLANILIR?',
                            style: GameTypography.display(
                              color: GameColors.hazardYellow,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1. Bu eşya sıradan bir hurda değildir! Kışlandaki paralı askerlerine (Savaşçı, Avcı, Şövalye) kuşandırabileceğin taktiksel bir zırhtır.\n'
                        '2. Askerlerinin savaş gücünü (CP) artırarak onları tehlikeli Zindan Seferlerine gönder.\n'
                        '3. Canavarları yenen askerlerin sana yüzbinlerce liralık efsanevi ganimetler ve yüksek itibar getirir!\n'
                        '4. Şimdi bu eşyayı aracına istifle ve karargaha götür.',
                        style: GameTypography.body(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 4. Aksiyon Butonları
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    ArcadeButton(
                      text: 'ANLADIM, BAGAJA İSTİFLE 📦',
                      icon: Icons.check_circle,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDismiss();
                      },
                      primaryColor: GameColors.profitGreen,
                      shadowColor: const Color(0xFF00893E),
                      height: 44,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 8),
                    ArcadeButton(
                      text: '🏰 ZİNDAN & KIŞLA KARARGAHINI İNCELE',
                      icon: Icons.castle,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDismiss();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DungeonHubScreen()),
                        );
                      },
                      primaryColor: GameColors.gold,
                      shadowColor: const Color(0xFF8C711C),
                      textColor: Colors.black,
                      height: 40,
                      fontSize: 11,
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

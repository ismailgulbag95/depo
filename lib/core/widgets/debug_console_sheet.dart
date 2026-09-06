import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/presentation/storage_raid_screen.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/services/storage_generator_service.dart';

/// Hızlı Geliştirici & Test Konsolu (Debug Paneli)
class DebugConsoleSheet extends ConsumerWidget {
  final VoidCallback? onAddTime;
  final VoidCallback? onAutoPackAll;
  final VoidCallback? onScrapAll;
  final VoidCallback? onToggleGrid;
  final bool isGridVisible;

  const DebugConsoleSheet({
    super.key,
    this.onAddTime,
    this.onAutoPackAll,
    this.onScrapAll,
    this.onToggleGrid,
    this.isGridVisible = false,
  });

  static void show(
    BuildContext context, {
    VoidCallback? onAddTime,
    VoidCallback? onAutoPackAll,
    VoidCallback? onScrapAll,
    VoidCallback? onToggleGrid,
    bool isGridVisible = false,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DebugConsoleSheet(
        onAddTime: onAddTime,
        onAutoPackAll: onAutoPackAll,
        onScrapAll: onScrapAll,
        onToggleGrid: onToggleGrid,
        isGridVisible: isGridVisible,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProfileProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF14151B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: GameColors.neonCyan, width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık Barı
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: GameColors.neonCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: GameColors.neonCyan),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report, color: GameColors.neonCyan, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'GELİŞTİRİCİ TEST MODU (DEBUG)',
                          style: GameTypography.display(color: GameColors.neonCyan, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Durum Özeti
              DiegeticMetalPanel(
                padding: const EdgeInsets.all(10),
                showRivets: false,
                backgroundColor: const Color(0xFF1B1D26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RetroLedDisplay(
                      label: 'MEVCUT NAKİT',
                      value: '${playerState.cash} ₺',
                      ledColor: GameColors.profitGreen,
                      fontSize: 13,
                    ),
                    RetroLedDisplay(
                      label: 'İTİBAR',
                      value: '${playerState.reputation} XP',
                      ledColor: GameColors.goldLight,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                '⚡ HIZLI TEST İŞLEMLERİ',
                style: GameTypography.display(color: GameColors.hazardYellow, fontSize: 12),
              ),
              const SizedBox(height: 8),

              // 1. Depoyu Anında Satın Al & Yağmaya Gir
              ArcadeButton(
                text: '⚡ DEPOYU ANINDA KAZAN VE GİR',
                icon: Icons.door_front_door,
                onPressed: () async {
                  Navigator.of(context).pop();
                  final unit = await StorageGeneratorService.instance.generateRandomUnit();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => StorageRaidScreen(storageUnit: unit),
                      ),
                    );
                  }
                },
                primaryColor: GameColors.gold,
                shadowColor: const Color(0xFF8C711C),
                textColor: Colors.black,
                height: 44,
                fontSize: 11,
              ),
              const SizedBox(height: 8),

              // 2. Para Ekle (+10.000 ₺)
              Row(
                children: [
                  Expanded(
                    child: ArcadeButton(
                      text: '+10.000 ₺ NAKİT',
                      icon: Icons.add_card,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ref.read(playerProfileProvider.notifier).addCash(10000);
                      },
                      primaryColor: GameColors.profitGreen,
                      shadowColor: const Color(0xFF00893E),
                      height: 42,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ArcadeButton(
                      text: '+500 İTİBAR (XP)',
                      icon: Icons.military_tech,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ref.read(playerProfileProvider.notifier).addReputation(500);
                      },
                      primaryColor: GameColors.neonCyan,
                      shadowColor: const Color(0xFF00838F),
                      textColor: Colors.black,
                      height: 42,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3. Zindanı Hızlı Bitir / Kazan
              ArcadeButton(
                text: '🏰 ZİNDANI ANINDA BİTİR (+750 XP & ÖDÜL)',
                icon: Icons.castle,
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  ref.read(playerProfileProvider.notifier).addReputation(750);
                  ref.read(playerProfileProvider.notifier).addCash(2500);
                  ref.read(dungeonProvider.notifier).startExpedition(
                    mercenaryId: 1,
                    dungeonName: 'Karanlık Madenler (Debug)',
                    dungeonDifficulty: 50,
                    durationSeconds: 1,
                  );
                  Navigator.of(context).pop();
                },
                primaryColor: const Color(0xFFAB47BC),
                shadowColor: const Color(0xFF6A1B9A),
                height: 42,
                fontSize: 11,
              ),
              const SizedBox(height: 8),

              // 4. Raid İçi Hızlı Aksiyonlar (Süre uzat / Otomatik Yükle / Hurda / Grid Çizgileri)
              if (onAddTime != null || onAutoPackAll != null || onScrapAll != null || onToggleGrid != null) ...[
                const Divider(color: GameColors.panelBorder, height: 20),
                Text(
                  '📦 YAĞMA & BAGAJ TESTLERİ',
                  style: GameTypography.display(color: GameColors.neonCyan, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (onToggleGrid != null) ...[
                  ArcadeButton(
                    text: isGridVisible ? '📐 DEPO GRIDİNİ GİZLE (12x3)' : '📐 DEPO GRIDİNİ GÖSTER (12x3)',
                    icon: Icons.grid_4x4,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onToggleGrid!();
                      Navigator.of(context).pop();
                    },
                    primaryColor: isGridVisible ? GameColors.lossRed : GameColors.neonCyan,
                    shadowColor: isGridVisible ? const Color(0xFF8B0000) : const Color(0xFF00838F),
                    textColor: isGridVisible ? Colors.white : Colors.black,
                    height: 40,
                    fontSize: 11,
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    if (onAddTime != null)
                      Expanded(
                        child: ArcadeButton(
                          text: '+60 SN SÜRE',
                          icon: Icons.timer,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            onAddTime!();
                          },
                          primaryColor: GameColors.gold,
                          shadowColor: const Color(0xFF8C711C),
                          textColor: Colors.black,
                          height: 40,
                          fontSize: 10,
                        ),
                      ),
                    if (onAddTime != null && onScrapAll != null) const SizedBox(width: 8),
                    if (onScrapAll != null)
                      Expanded(
                        child: ArcadeButton(
                          text: 'HEPSİNİ HURDALA',
                          icon: Icons.delete_sweep,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            onScrapAll!();
                          },
                          primaryColor: GameColors.lossRed,
                          shadowColor: const Color(0xFF8B0000),
                          height: 40,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (onAutoPackAll != null)
                  ArcadeButton(
                    text: '⚡ TÜM EŞYALARI OTOMATİK İSTİFLE',
                    icon: Icons.auto_fix_high,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      onAutoPackAll!();
                    },
                    primaryColor: GameColors.profitGreen,
                    shadowColor: const Color(0xFF00893E),
                    height: 42,
                    fontSize: 11,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

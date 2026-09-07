import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/hazard_stripe_banner.dart';
import 'package:yeni_oyun_sablon/features/city_map/models/zone_data.dart';

/// 🗺️ ETKİLEŞİMLİ ŞEHİR HARİTASI GÖRÜNÜMÜ (CityMapView)
/// Arka planda 16:9 şehir haritası illüstrasyonunu en-boy oranını koruyarak (`AspectRatio` & `FittedBox`)
/// render eder ve normalize Alignment(x, y) koordinatlarıyla binaların üzerine dokunma pinleri (Action Node) sabitler.
class CityMapView extends StatefulWidget {
  final List<ZoneData> zones;
  final String backgroundAssetPath;
  final bool openBottomSheetOnTap;
  final Widget? overlayChild;

  const CityMapView({
    super.key,
    required this.zones,
    this.backgroundAssetPath = 'assets/images/city_map.png',
    this.openBottomSheetOnTap = true,
    this.overlayChild,
  });

  @override
  State<CityMapView> createState() => _CityMapViewState();

  /// 📋 Bölge Detay / Keşif Alt Paneli (Diegetic Bottom Sheet)
  static void showZoneBottomSheet({
    required BuildContext context,
    required ZoneData zone,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ZoneDetailBottomSheet(zone: zone),
    );
  }
}

class _CityMapViewState extends State<CityMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.90, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFF090D14),
          child: Center(
            // Harita en-boy oranını (16:9) koruyarak ekrana sığdırır
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  // 1. Arka Plan Harita Görseli
                  Positioned.fill(
                    child: Image.asset(
                      widget.backgroundAssetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Eğer assets/images/city_map.png henüz kopyalanmadıysa fallback arka plana bakar
                        return Image.asset(
                          GameAssetPaths.bgCityMapTactical,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF141926),
                            child: const Center(
                              child: Icon(Icons.map, size: 64, color: Colors.white24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 2. Harita Üzerindeki 8 Bölge Dokunmatik Pini (Action Nodes)
                  ...widget.zones.map((zone) => _buildActionNodePin(zone)),

                  // 3. İsteğe Bağlı Üst Katman (FTUE Spotlight vb.)
                  if (widget.overlayChild != null) widget.overlayChild!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📍 Mimari Binalara Hizalanmış Dokunmatik Action Node Pini (En az 48x48 dp)
  Widget _buildActionNodePin(ZoneData zone) {
    return Align(
      alignment: zone.alignment,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.mediumImpact();
          if (widget.openBottomSheetOnTap) {
            CityMapView.showZoneBottomSheet(context: context, zone: zone);
          } else {
            zone.onTap();
          }
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final isPulsing = zone.isHighlighted || zone.isImportant;
            final scale = isPulsing ? _pulseAnimation.value : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                // 48x48 dp minimum dokunma erişim alanı
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dinamik Rozet Metni (Varsa: "Mezat Açık", "Seferde")
                    if (zone.badgeText != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: zone.accentColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: zone.accentColor.withValues(alpha: 0.65),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          zone.badgeText!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                    // Ana Dairesel Pin Rozeti
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xEE090D18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: zone.isHighlighted
                              ? GameColors.gold
                              : zone.accentColor,
                          width: zone.isHighlighted ? 2.2 : 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (zone.isHighlighted ? GameColors.gold : zone.accentColor).withValues(alpha: 0.55),
                            blurRadius: zone.isHighlighted ? 14 : 8,
                            spreadRadius: zone.isHighlighted ? 2 : 1,
                          ),
                          const BoxShadow(
                            color: Colors.black87,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: zone.accentColor.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: zone.iconPath != null
                              ? Image.asset(
                                  zone.iconPath!,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Center(
                                    child: Icon(zone.icon, size: 15, color: zone.accentColor),
                                  ),
                                )
                              : Center(
                                  child: Icon(zone.icon, size: 15, color: zone.accentColor),
                                ),
                        ),
                      ),
                    ),

                    // Kompakt Bölge Başlık Etiketi (Bölgenin rengiyle uyumlu)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xF0080B12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: zone.isHighlighted
                              ? GameColors.gold
                              : zone.accentColor.withValues(alpha: 0.75),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: zone.accentColor.withValues(alpha: 0.20),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        zone.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: zone.isHighlighted ? GameColors.goldLight : Colors.white,
                          fontSize: 8.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 📋 Diegetik Bölge Detay Bottom Sheet Modalı
class _ZoneDetailBottomSheet extends StatelessWidget {
  final ZoneData zone;

  const _ZoneDetailBottomSheet({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1420),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: zone.accentColor.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: zone.accentColor.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Sürükleme Tutamacı
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Bölge Başlık ve İkon Satırı
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: zone.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: zone.accentColor, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(zone.icon, color: zone.accentColor, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: GameTypography.display(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (zone.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          zone.subtitle,
                          style: GameTypography.body(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (zone.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: zone.isImportant ? const Color(0xFFFF334B) : const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      zone.badgeText!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const HazardStripeBanner(height: 3),
            const SizedBox(height: 16),

            // Giriş / Eylem Butonu
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: zone.accentColor,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 6,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                zone.onTap();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward, size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    'BÖLGEYE GİRİŞ YAP',
                    style: GameTypography.display(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeni_oyun_sablon/core/constants/game_item_sets.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_set_model.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';

/// Koleksiyoncu Saha Günlüğü & Pasaportu (Papers Please / Antikacı Defteri)
/// Dokunsal sararmış parşömen, gerçek eşya sprite'lı polaroid fotoğraflar,
/// eksikler için hayalet şematikler ve tok arşiv damga vuruşu.
class CollectorFieldJournalView extends StatefulWidget {
  final List<ItemModel> userInventory;
  final void Function(ItemSetModel set)? onClaimBonus;

  const CollectorFieldJournalView({
    super.key,
    required this.userInventory,
    this.onClaimBonus,
  });

  @override
  State<CollectorFieldJournalView> createState() => _CollectorFieldJournalViewState();
}

class _CollectorFieldJournalViewState extends State<CollectorFieldJournalView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  final Set<String> _claimedSetIds = {};

  late AnimationController _stampController;
  late Animation<double> _stampScaleAnimation;
  late Animation<double> _stampRotationAnimation;
  late Animation<double> _stampOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Antika Kaşe Mühür Damga Animasyonu
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _stampScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 3.0, end: 0.95).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_stampController);

    _stampRotationAnimation = Tween<double>(begin: -0.25, end: -0.10).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeOut),
    );

    _stampOpacityAnimation = Tween<double>(begin: 0.0, end: 0.95).animate(
      CurvedAnimation(parent: _stampController, curve: const Interval(0.2, 0.9)),
    );

    _stampController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stampController.dispose();
    super.dispose();
  }

  String _resolveItemSprite(String code) {
    // 1. Envanterde ara
    for (final it in widget.userInventory) {
      if (it.code.toLowerCase() == code.toLowerCase() ||
          it.spritePath.toLowerCase().contains(code.toLowerCase())) {
        return it.spritePath;
      }
    }

    // 2. Kategori bazlı sezgisel tahmin
    final lower = code.toLowerCase();
    if (lower.contains('muzik') || lower.contains('gitar') || lower.contains('saksafon') || lower.contains('keman') || lower.contains('tef')) {
      return 'assets/items/muzik_aletleri/01_elektro_gitar.webp';
    } else if (lower.contains('altin') || lower.contains('maden') || lower.contains('elmas') || lower.contains('yakut')) {
      return 'assets/items/maden_ve_taslar/01_kulce_altin.webp';
    } else if (lower.contains('motor') || lower.contains('araba') || lower.contains('buji') || lower.contains('jant')) {
      return 'assets/items/araba_parcalari/01_v8_motor_blogu.webp';
    } else if (lower.contains('kilit') || lower.contains('maymuncuk') || lower.contains('stetoskop') || lower.contains('fener')) {
      return 'assets/items/kilit_ve_hirsizlik/01_deri_kilifli_maymuncuk_seti.webp';
    } else if (lower.contains('tava') || lower.contains('tencere') || lower.contains('semaver') || lower.contains('bicak')) {
      return 'assets/items/mutfak_gastronomi/01_dokum_demir_tava.webp';
    } else if (lower.contains('firavun') || lower.contains('amfora') || lower.contains('tablet') || lower.contains('fosil')) {
      return 'assets/items/arkeoloji_ve_antik_kalintilar/01_altin_firavun_maski.webp';
    } else if (lower.contains('dumen') || lower.contains('cipa') || lower.contains('sekstant') || lower.contains('pusula')) {
      return 'assets/items/denizcilik_ve_balikcilik/01_gemi_dumeni.webp';
    } else if (lower.contains('tirpan') || lower.contains('kurek') || lower.contains('pompa')) {
      return 'assets/items/tarim_ve_bahce_ekipmanlari/02_motorlu_tirpan.webp';
    }
    return 'assets/items/sanat_antikalar/01_antika_kolsaati.webp';
  }

  bool _isSetCompleted(ItemSetModel set) {
    for (final reqCode in set.requiredItemCodes) {
      final has = widget.userInventory.any((item) =>
          item.code.toLowerCase() == reqCode.toLowerCase() ||
          item.spritePath.toLowerCase().contains(reqCode.toLowerCase()));
      if (!has) return false;
    }
    return true;
  }

  int _matchingItemCount(ItemSetModel set) {
    int count = 0;
    for (final reqCode in set.requiredItemCodes) {
      final has = widget.userInventory.any((item) =>
          item.code.toLowerCase() == reqCode.toLowerCase() ||
          item.spritePath.toLowerCase().contains(reqCode.toLowerCase()));
      if (has) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final sets = GameItemSets.all;

    return Column(
      children: [
        // 1. Günlük Üst Bilgi ve Sayfa Çevirici HUD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories, color: GameColors.goldLight, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ANTİKACI SAHA GÜNLÜĞÜ',
                    style: GameTypography.display(
                      color: GameColors.goldLight,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  'SAYFA ${_currentPage + 1} / ${sets.length}',
                  style: GameTypography.body(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        // 2. Defter Sayfaları (PageView)
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: sets.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (idx) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentPage = idx;
              });
              _stampController.forward(from: 0.0);
            },
            itemBuilder: (ctx, index) {
              final set = sets[index];
              final isCompleted = _isSetCompleted(set);
              final matchCount = _matchingItemCount(set);
              final isClaimed = _claimedSetIds.contains(set.id);

              return _buildJournalPage(set, isCompleted, matchCount, isClaimed);
            },
          ),
        ),

        // 3. Sayfa Navigasyon Çubuğu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                onPressed: _currentPage > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: GameColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sayfaları çevirerek koleksiyon sinerjilerini keşfedin',
                      style: GameTypography.body(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                onPressed: _currentPage < sets.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJournalPage(ItemSetModel set, bool isCompleted, int matchCount, bool isClaimed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        // Sararmış Antika Parşömen Dokusu
        color: const Color(0xFFF3E8CE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B6B48), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 16, offset: Offset(0, 8)),
          BoxShadow(color: Color(0xFF2C1E14), blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Stack(
        children: [
          // Sol Cilt Dikiş Çizgisi
          Positioned(
            left: 18,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: const BoxDecoration(
                color: Color(0xFFC7B299),
                boxShadow: [
                  BoxShadow(color: Color(0xFF947B60), offset: Offset(-1, 0), blurRadius: 2),
                ],
              ),
            ),
          ),

          // Sayfa İçeriği
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 32, right: 18, top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Set Başlığı ve Sayfa No
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ARŞİV KODU: #${set.id.toUpperCase()}',
                            style: GameTypography.body(
                              color: const Color(0xFF7D5836),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            set.nameTr,
                            style: GameTypography.display(
                              color: const Color(0xFF2B1B0E),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF2E6337) : const Color(0xFF8D6E63),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                        ],
                      ),
                      child: Text(
                        '$matchCount / ${set.requiredItemCodes.length} PARÇA',
                        style: GameTypography.display(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Set Lore / Hikaye Metni
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADBC0).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD4C1A5)),
                  ),
                  child: Text(
                    '"${set.loreTr.isNotEmpty ? set.loreTr : set.descriptionTr}"',
                    style: GameTypography.body(
                      color: const Color(0xFF4A3525),
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Polaroid & Pul Tarzında Gerçek Eşya Galerisi
                Text(
                  'ARŞİV KALINTILARI & GEREKLİ EŞYALAR:',
                  style: GameTypography.body(
                    color: const Color(0xFF5A402A),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _buildPolaroidGallery(set),

                const SizedBox(height: 14),

                // Set Sinerji Bonusları
                _buildBonusScroll(set),

                const SizedBox(height: 12),

                // Ödülü Al / Damgayı Tasdikle Butonu
                if (isCompleted && !isClaimed) ...[
                  ArcadeButton(
                    text: 'KOLEKSİYON ÖDÜLÜNÜ AL (+${set.cashReward} ₺) 🏆',
                    icon: Icons.workspace_premium,
                    primaryColor: const Color(0xFF8E2800),
                    textColor: Colors.white,
                    shadowColor: const Color(0xFF4A1000),
                    height: 42,
                    fontSize: 11,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        _claimedSetIds.add(set.id);
                      });
                      widget.onClaimBonus?.call(set);
                    },
                  ),
                ],
              ],
            ),
          ),

          // Tamamlanmış Set Kaşesi (Official Archival Stamp)
          if (isCompleted) ...[
            Positioned(
              right: 14,
              top: 50,
              child: AnimatedBuilder(
                animation: _stampController,
                builder: (ctx, child) {
                  return Transform.rotate(
                    angle: _stampRotationAnimation.value,
                    child: Transform.scale(
                      scale: _stampScaleAnimation.value,
                      child: Opacity(
                        opacity: _stampOpacityAnimation.value,
                        child: _buildOfficialArchiveStamp(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPolaroidGallery(ItemSetModel set) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: set.requiredItemCodes.map((code) {
        final hasItem = widget.userInventory.any((i) =>
            i.code.toLowerCase() == code.toLowerCase() ||
            i.spritePath.toLowerCase().contains(code.toLowerCase()));

        return _buildPolaroidStampCard(code, hasItem);
      }).toList(),
    );
  }

  Widget _buildPolaroidStampCard(String code, bool hasItem) {
    final spritePath = _resolveItemSprite(code);

    return Container(
      width: 84,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white, // Polaroid beyaz kenarlığı
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFC7B299), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(1, 3), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          // Fotoğraf Alanı (Gerçek Eşya Görseli)
          Container(
            width: 74,
            height: 64,
            decoration: BoxDecoration(
              color: hasItem ? const Color(0xFFF7F8F9) : const Color(0xFFE5DFD7),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: hasItem
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        spritePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.check_circle, color: Color(0xFF2E6337), size: 28),
                        ),
                      ),
                    )
                  : Opacity(
                      opacity: 0.35,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.brown,
                          BlendMode.srcATop,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            spritePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.help_outline, color: Color(0xFF5A402A), size: 26),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            code.replaceAll('_', ' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GameTypography.body(
              color: hasItem ? const Color(0xFF2E6337) : const Color(0xFF8D6E63),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            hasItem ? '✓ ARŞİVDE' : '✗ EKSİK',
            style: GameTypography.display(
              color: hasItem ? const Color(0xFF2E6337) : const Color(0xFFB71C1C),
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusScroll(ItemSetModel set) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEADBC0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBCAAA4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Color(0xFFB71C1C), size: 16),
              const SizedBox(width: 6),
              Text(
                'AKTİF SİNERJİ AVANTAJLARI:',
                style: GameTypography.display(
                  color: const Color(0xFF3E2723),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '• Satış Değer Artışı: +%${((set.bonusMultiplier - 1.0) * 100).toInt().clamp(10, 100)}',
            style: GameTypography.body(color: const Color(0xFF2E7D32), fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          Text(
            '• Kalıcı Nakit Ödülü: +${set.cashReward} ₺  |  İtibar: +${set.reputationReward}',
            style: GameTypography.body(color: const Color(0xFF4E342E), fontSize: 10),
          ),
          if (set.passivePerkCode.isNotEmpty) ...[
            Text(
              '• Özel Yetki / Perk: ${set.passivePerkCode.replaceAll('_', ' ').toUpperCase()}',
              style: GameTypography.body(color: const Color(0xFF6A1B9A), fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfficialArchiveStamp() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB71C1C), width: 2.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MÜHÜRLENDİ',
            style: GameTypography.display(
              color: const Color(0xFFB71C1C),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          Text(
            'OFFICIAL ARCHIVE APPROVED',
            style: GameTypography.body(
              color: const Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
              fontSize: 6.5,
            ),
          ),
        ],
      ),
    );
  }
}

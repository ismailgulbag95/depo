import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeni_oyun_sablon/core/constants/crafting_recipes.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/models/crafting_recipe_model.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/services/game_audio_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';

/// Dokunsal Hidrolik Montaj ve Pres Tezgahı (Game Feel & Diegetic UI)
/// Resident Evil Merchant / Escape from Tarkov atölye hissiyatı:
/// Girintili çelik soketler, aşağı inen hidrolik piston, kıvılcım parçacıkları ve yaylı pop efekti.
class TactileHydraulicPress extends StatefulWidget {
  final List<ItemModel> userInventory;
  final int userMasteryLevel;
  final VoidCallback? onScreenShake;
  final void Function(CraftingRecipeModel recipe, ItemModel outputItem)? onCraftSuccess;

  const TactileHydraulicPress({
    super.key,
    required this.userInventory,
    this.userMasteryLevel = 1,
    this.onScreenShake,
    this.onCraftSuccess,
  });

  @override
  State<TactileHydraulicPress> createState() => _TactileHydraulicPressState();
}

class _TactileHydraulicPressState extends State<TactileHydraulicPress>
    with TickerProviderStateMixin {
  int _selectedRecipeIndex = 0;
  RecipeType? _filterType;

  late AnimationController _pressController;
  late Animation<double> _pistonOffsetAnimation;
  late Animation<double> _sparkBurstAnimation;

  late AnimationController _popController;
  late Animation<double> _popScaleAnimation;

  bool _isCrafting = false;
  ItemModel? _lastCraftedItem;

  @override
  void initState() {
    super.initState();

    // Hidrolik Pres Piston İniş ve Kıvılcım Patlama Animasyonu
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pistonOffsetAnimation = TweenSequence<double>([
      // Hızlı iniş (Vuruş anı)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 45.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 40,
      ),
      // Sarsıntı ve pres sıkışması
      TweenSequenceItem(
        tween: Tween<double>(begin: 45.0, end: 42.0)
            .chain(CurveTween(curve: Curves.elasticIn)),
        weight: 20,
      ),
      // Ağır geri kalkış
      TweenSequenceItem(
        tween: Tween<double>(begin: 42.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_pressController);

    _sparkBurstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    // Çıktı Eşyasının Yaylı 'Pop' ve Overshoot Animasyonu
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _popScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _popController.dispose();
    super.dispose();
  }

  String _resolveItemSprite(String code) {
    for (final it in widget.userInventory) {
      if (it.code.toLowerCase() == code.toLowerCase() ||
          it.spritePath.toLowerCase().contains(code.toLowerCase())) {
        return it.spritePath;
      }
    }
    final lower = code.toLowerCase();
    if (lower.contains('motor') || lower.contains('dinamo') || lower.contains('jenerator')) {
      return 'assets/items/agir_sanayi/01_dinamo.webp';
    } else if (lower.contains('buji') || lower.contains('jant') || lower.contains('manifolt')) {
      return 'assets/items/araba_parcalari/01_v8_motor_blogu.webp';
    } else if (lower.contains('matkap') || lower.contains('batarya') || lower.contains('lehim')) {
      return 'assets/items/elektronik_aletler/01_darbeli_matkap.webp';
    } else if (lower.contains('altin') || lower.contains('gumus') || lower.contains('titanyum') || lower.contains('elmas')) {
      return 'assets/items/maden_ve_taslar/01_kulce_altin.webp';
    } else if (lower.contains('maymuncuk') || lower.contains('stetoskop') || lower.contains('kasa') || lower.contains('dekoder')) {
      return 'assets/items/kilit_ve_hirsizlik/01_deri_kilifli_maymuncuk_seti.webp';
    } else if (lower.contains('tava') || lower.contains('tencere') || lower.contains('bicak') || lower.contains('semaver')) {
      return 'assets/items/mutfak_gastronomi/01_dokum_demir_tava.webp';
    } else if (lower.contains('defibrilator') || lower.contains('nester') || lower.contains('turnike') || lower.contains('tansiyon')) {
      return 'assets/items/tip_ve_saglik/01_tasinabilir_defibrilator.webp';
    } else if (lower.contains('dumen') || lower.contains('cipa') || lower.contains('sekstant') || lower.contains('zipkin')) {
      return 'assets/items/denizcilik_ve_balikcilik/01_gemi_dumeni.webp';
    } else if (lower.contains('firavun') || lower.contains('amfora') || lower.contains('tablet') || lower.contains('fosil')) {
      return 'assets/items/arkeoloji_ve_antik_kalintilar/01_altin_firavun_maski.webp';
    } else if (lower.contains('tirpan') || lower.contains('cim_bicme') || lower.contains('kurek') || lower.contains('pompa')) {
      return 'assets/items/tarim_ve_bahce_ekipmanlari/02_motorlu_tirpan.webp';
    } else if (lower.contains('plazma') || lower.contains('katanasi') || lower.contains('reaktor')) {
      return 'assets/items/melez_arcane_tech/01_plazma_tufek.webp';
    }
    return 'assets/items/manuel_el_aletleri/01_kirmizi_alet_cantasi.webp';
  }

  List<CraftingRecipeModel> get _filteredRecipes {
    if (_filterType == null) return GameCraftingRecipes.all;
    return GameCraftingRecipes.all
        .where((r) => r.type == _filterType)
        .toList();
  }

  CraftingRecipeModel? get _currentRecipe {
    final list = _filteredRecipes;
    if (list.isEmpty) return null;
    return list[_selectedRecipeIndex.clamp(0, list.length - 1)];
  }

  bool _canCraft(CraftingRecipeModel recipe) {
    if (widget.userMasteryLevel < recipe.requiredMasteryLevel) return false;
    for (final req in recipe.inputs) {
      final hasCount = widget.userInventory
          .where((item) =>
              item.code.toLowerCase() == req.itemCode.toLowerCase() ||
              item.spritePath.toLowerCase().contains(req.itemCode.toLowerCase()))
          .length;
      if (hasCount < req.count) return false;
    }
    return true;
  }

  Future<void> _executeHydraulicPress(CraftingRecipeModel recipe) async {
    if (_isCrafting || !_canCraft(recipe)) return;

    setState(() {
      _isCrafting = true;
      _lastCraftedItem = null;
    });

    HapticFeedback.heavyImpact();

    // 1. Piston inerken ilk sarsıntı ve ezilme sesi
    _pressController.forward(from: 0.0);
    GameAudioService.instance.playCrush();

    await Future.delayed(const Duration(milliseconds: 280));
    widget.onScreenShake?.call();
    HapticFeedback.vibrate();

    await Future.delayed(const Duration(milliseconds: 420));

    // 2. Üretim tamamlandı, yeni eşya üret
    final primaryOutput = recipe.outputs.isNotEmpty ? recipe.outputs.first.itemCode : 'crafting_output';
    final outputItem = ItemModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      code: primaryOutput,
      nameTr: recipe.titleTr,
      nameEn: recipe.titleEn,
      nameRu: recipe.titleTr,
      nameEs: recipe.titleTr,
      category: 'crafting_output',
      baseValue: (recipe.cashCost * 3.5).toInt().clamp(250, 10000),
      width: 2,
      height: 2,
      bitmask: [3, 3],
      weight: 4.5,
      spritePath: _resolveItemSprite(primaryOutput),
      condition: ItemCondition.pristine,
      dirtPercentage: 0.0,
    );

    setState(() {
      _lastCraftedItem = outputItem;
      _isCrafting = false;
    });

    _popController.forward(from: 0.0);
    HapticFeedback.lightImpact();
    GameAudioService.instance.playVictory();

    widget.onCraftSuccess?.call(recipe, outputItem);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _currentRecipe;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Endüstriyel Tip Seçici Düğmeler (Tümü / Montaj / Demontaj)
          _buildFilterToggleBar(),

          const SizedBox(height: 12),

          // 2. Reçete Seçici Selector Bar
          _buildRecipeSelector(recipe),

          const SizedBox(height: 14),

          if (recipe != null) ...[
            // 3. Dokunsal Hidrolik Pres Haznesi & Piston
            _buildHydraulicPressChamber(recipe),

            const SizedBox(height: 14),

            // 4. Girintili Çelik Soketler (Milled Steel Inset Slots)
            _buildMilledMaterialSockets(recipe),

            const SizedBox(height: 14),

            // 5. Pres Çalıştırma Kolu / Butonu
            _buildPressActivationLever(recipe),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Bu filtreye uygun reçete bulunamadı.',
                    style: TextStyle(color: Colors.white54)),
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterToggleBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 3), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          _buildFilterBtn(null, 'TÜMÜ ⚙️', GameColors.gold),
          _buildFilterBtn(RecipeType.assembly, 'MONTAJ 🔨', GameColors.profitGreen),
          _buildFilterBtn(RecipeType.salvage, 'DEMONTAJ 🪓', GameColors.alertOrange),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(RecipeType? type, String label, Color accentColor) {
    final isSelected = _filterType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _filterType = type;
            _selectedRecipeIndex = 0;
            _lastCraftedItem = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GameTypography.display(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeSelector(CraftingRecipeModel? currentRecipe) {
    final list = _filteredRecipes;
    return DiegeticMetalPanel(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, color: GameColors.goldLight, size: 28),
            onPressed: _selectedRecipeIndex > 0
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedRecipeIndex--;
                      _lastCraftedItem = null;
                    });
                  }
                : null,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (currentRecipe?.type == RecipeType.assembly
                                ? GameColors.profitGreen
                                : GameColors.alertOrange)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: currentRecipe?.type == RecipeType.assembly
                              ? GameColors.profitGreen
                              : GameColors.alertOrange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        currentRecipe?.type == RecipeType.assembly
                            ? 'BİRLEŞTİRME & MONTAJ'
                            : 'DEMONTAJ & GERİ KAZANIM',
                        style: GameTypography.display(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${_selectedRecipeIndex + 1}/${list.length})',
                      style: GameTypography.body(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currentRecipe?.titleTr ?? '',
                  textAlign: TextAlign.center,
                  style: GameTypography.display(
                    color: GameColors.goldLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right, color: GameColors.goldLight, size: 28),
            onPressed: _selectedRecipeIndex < list.length - 1
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedRecipeIndex++;
                      _lastCraftedItem = null;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHydraulicPressChamber(CraftingRecipeModel recipe) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF32384D), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Izgara zemin dokusu
            Positioned.fill(
              child: CustomPaint(
                painter: _GridBackgroundPainter(),
              ),
            ),

            // Piston ve Basınç Kafası (Yukarıdan aşağı inen animasyon)
            AnimatedBuilder(
              animation: _pistonOffsetAnimation,
              builder: (ctx, child) {
                return Positioned(
                  top: -20 + _pistonOffsetAnimation.value,
                  child: Column(
                    children: [
                      Container(
                        width: 130,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF555F73), Color(0xFF282D38), Color(0xFF1B1E26)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                          border: Border.all(color: const Color(0xFF7A869E), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'HYDRAULIC-PRESS 40T',
                            style: GameTypography.body(color: Colors.white70, fontSize: 8),
                          ),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 24,
                        color: const Color(0xFF9AA4B8),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Kıvılcım Patlaması CustomPainter
            AnimatedBuilder(
              animation: _sparkBurstAnimation,
              builder: (ctx, child) {
                if (_sparkBurstAnimation.value <= 0.01) return const SizedBox.shrink();
                return CustomPaint(
                  size: const Size(200, 160),
                  painter: _SparkBurstPainter(progress: _sparkBurstAnimation.value),
                );
              },
            ),

            // Orta Alan: Çıktı Eşyası veya Şematik Hedef
            Positioned(
              bottom: 20,
              child: _lastCraftedItem != null
                  ? ScaleTransition(
                      scale: _popScaleAnimation,
                      child: _buildOutputDisplay(_lastCraftedItem!),
                    )
                  : _buildBlueprintGhost(recipe),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueprintGhost(CraftingRecipeModel recipe) {
    final outCode = recipe.outputs.isNotEmpty ? recipe.outputs.first.itemCode : '';
    final spritePath = _resolveItemSprite(outCode);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: GameColors.neonCyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: GameColors.neonCyan.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Opacity(
              opacity: 0.65,
              child: Image.asset(
                spritePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.build_circle, color: GameColors.neonCyan, size: 36),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          outCode.replaceAll('_', ' ').toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GameTypography.body(color: GameColors.neonCyan, fontSize: 8.5),
        ),
      ],
    );
  }

  Widget _buildOutputDisplay(ItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B221E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.profitGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: GameColors.profitGreen.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(
              item.spritePath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, color: GameColors.profitGreen, size: 32),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'İŞLEM BAŞARILI! 🎉',
                style: GameTypography.display(color: GameColors.profitGreen, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                item.nameTr,
                style: GameTypography.display(color: Colors.white, fontSize: 11),
              ),
              Text(
                'Tahmini Değer: ~${item.baseValue} ₺',
                style: GameTypography.body(color: GameColors.goldLight, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilledMaterialSockets(CraftingRecipeModel recipe) {
    return DiegeticMetalPanel(
      borderRadius: 12,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GEREKLİ BİLEŞENLER (MALZEME SOKETLERİ)',
                style: GameTypography.display(color: Colors.white70, fontSize: 10),
              ),
              Text(
                'İşçilik: ${recipe.cashCost} ₺  •  +${recipe.rewardXp} XP',
                style: GameTypography.body(color: GameColors.goldLight, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recipe.inputs.map((mat) {
              final userHas = widget.userInventory
                  .where((i) =>
                      i.code.toLowerCase() == mat.itemCode.toLowerCase() ||
                      i.spritePath.toLowerCase().contains(mat.itemCode.toLowerCase()))
                  .length;
              final isReady = userHas >= mat.count;

              return _buildMilledSocket(mat.itemCode, mat.count, userHas, isReady);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMilledSocket(String itemCode, int requiredQty, int userHas, bool isReady) {
    final spritePath = _resolveItemSprite(itemCode);

    return Container(
      width: 100,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0D13), // Girintili koyu soket rengi
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReady ? GameColors.profitGreen : Colors.redAccent.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isReady
                  ? GameColors.profitGreen.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                spritePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  isReady ? Icons.check_circle_outline : Icons.extension_off_outlined,
                  color: isReady ? GameColors.profitGreen : Colors.redAccent,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            itemCode.replaceAll('_', ' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GameTypography.body(color: Colors.white, fontSize: 8.5),
          ),
          Text(
            '$userHas / $requiredQty Adet',
            style: GameTypography.body(
              color: isReady ? GameColors.profitGreen : Colors.redAccent,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPressActivationLever(CraftingRecipeModel recipe) {
    final canExecute = _canCraft(recipe);
    final levelOk = widget.userMasteryLevel >= recipe.requiredMasteryLevel;

    if (!levelOk) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.redAccent, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.redAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bu reçete için ATÖLYE USTALIĞI LVL ${recipe.requiredMasteryLevel} gereklidir!',
                style: GameTypography.display(color: Colors.redAccent, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    return ArcadeButton(
      text: _isCrafting ? 'HİDROLİK BASINÇ UYGULANIYOR...' : 'HİDROLİK PRESİ BAŞLAT ⚡',
      icon: Icons.compress,
      primaryColor: canExecute ? GameColors.gold : const Color(0xFF353A47),
      textColor: canExecute ? Colors.black : Colors.white38,
      shadowColor: Colors.black,
      height: 48,
      fontSize: 12,
      onPressed: canExecute && !_isCrafting ? () => _executeHydraulicPress(recipe) : null,
    );
  }
}

/// Izgara Şematik Zemin Çizici
class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C2230)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kaynak / Montaj Kıvılcım Patlaması CustomPainter
class _SparkBurstPainter extends CustomPainter {
  final double progress;

  _SparkBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final center = Offset(size.width / 2, size.height - 35);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const count = 22;
    for (int i = 0; i < count; i++) {
      final angle = -math.pi + (i / count) * math.pi + (rand.nextDouble() * 0.2 - 0.1);
      final dist = (40 + rand.nextDouble() * 55) * progress;
      final startDist = dist * 0.4;

      final start = center + Offset(math.cos(angle) * startDist, math.sin(angle) * startDist);
      final end = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      final alpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);
      paint.color = i % 2 == 0
          ? Color.fromARGB(alpha, 255, 200, 50)
          : Color.fromARGB(alpha, 255, 100, 20);
      paint.strokeWidth = (2.5 * (1.0 - progress)).clamp(0.5, 3.0);

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

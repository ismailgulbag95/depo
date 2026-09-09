import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/core/services/game_audio_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/core/widgets/arcade_button.dart';
import 'package:yeni_oyun_sablon/core/widgets/diegetic_metal_panel.dart';
import 'package:yeni_oyun_sablon/core/widgets/game_screen_shake.dart';
import 'package:yeni_oyun_sablon/core/widgets/retro_led_display.dart';
import 'package:yeni_oyun_sablon/features/dungeon/models/mercenary_model.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// Zindan Canavarı Şablonu
class DungeonEnemy {
  final String name;
  final String avatar;
  final int maxHp;
  int currentHp;
  final int attackPower;
  final int floor;

  DungeonEnemy({
    required this.name,
    required this.avatar,
    required this.maxHp,
    required this.currentHp,
    required this.attackPower,
    required this.floor,
  });

  factory DungeonEnemy.createForFloor(int floor) {
    final names = [
      'Gölge Yağmacısı',
      'Zırhlı Mezar Bekçisi',
      'Demir Golem',
      'Yeraltı Yılanı',
      'Antik Şövalye Hayaleti',
      'Magma Canavarı',
      'Karanlık Büyücü',
      'Kadim Zindan Lordu',
    ];
    final avatars = ['🧟', '💀', '🗿', '🐍', '👻', '👹', '🧙', '🐉'];

    final idx = (floor - 1) % names.length;
    final hp = 80 + (floor * 35);
    final atk = 12 + (floor * 6);

    return DungeonEnemy(
      name: names[idx],
      avatar: avatars[idx],
      maxHp: hp,
      currentHp: hp,
      attackPower: atk,
      floor: floor,
    );
  }
}

/// Aktif Rogue-lite Zindan Savaşı Ekranı
class ActiveDungeonBattleScreen extends ConsumerStatefulWidget {
  final MercenaryModel mercenary;

  const ActiveDungeonBattleScreen({
    super.key,
    required this.mercenary,
  });

  @override
  ConsumerState<ActiveDungeonBattleScreen> createState() =>
      _ActiveDungeonBattleScreenState();
}

class _ActiveDungeonBattleScreenState
    extends ConsumerState<ActiveDungeonBattleScreen> {
  final GameScreenShakeController _shakeController =
      GameScreenShakeController();
  final Random _rnd = Random();

  int _currentFloor = 1;
  late int _playerMaxHp;
  late int _playerCurrentHp;
  late int _playerAttack;
  late int _playerDefense;

  late DungeonEnemy _currentEnemy;
  bool _isPlayerTurn = true;
  bool _isBattleOngoing = true;
  bool _isFloorCleared = false;
  bool _isGameOver = false;

  final List<ItemModel> _lootedItems = [];
  ItemModel? _lastFloorLoot;
  String _combatLog = 'Zindanın 1. Katına giriş yapıldı!';
  String? _enemyDamagePopup;
  bool _isEnemyCrit = false;
  String? _playerDamagePopup;

  @override
  void initState() {
    super.initState();
    _initHeroStats();
    _startFloor(_currentFloor);
  }

  void _initHeroStats() {
    // Savaşçı kuşanılan eşyalarına göre statlar
    int bonusHp = 0;
    int bonusAtk = 0;
    int bonusDef = 0;

    for (final item in widget.mercenary.equippedItems) {
      if (item.category.contains('zirh') || item.category.contains('taktik')) {
        bonusHp += (item.baseValue * 0.15).round();
        bonusDef += (item.baseValue * 0.05).round();
      } else if (item.category.contains('silah')) {
        bonusAtk += (item.baseValue * 0.12).round();
      } else {
        bonusAtk += (item.baseValue * 0.05).round();
        bonusDef += (item.baseValue * 0.03).round();
      }
    }

    _playerMaxHp = 150 + bonusHp;
    _playerCurrentHp = _playerMaxHp;
    _playerAttack = 25 + bonusAtk;
    _playerDefense = 8 + bonusDef;
  }

  void _startFloor(int floor) {
    setState(() {
      _currentFloor = floor;
      _currentEnemy = DungeonEnemy.createForFloor(floor);
      _isBattleOngoing = true;
      _isFloorCleared = false;
      _isPlayerTurn = true;
      _lastFloorLoot = null;
      _combatLog =
          'Kat $floor: ${_currentEnemy.avatar} ${_currentEnemy.name} belirdi!';
    });
  }

  /// Oyuncu Saldırısı
  void _playerAttackAction({bool isHeavy = false}) {
    if (!_isBattleOngoing || !_isPlayerTurn) return;

    setState(() {
      _isPlayerTurn = false;
    });

    int damage = _playerAttack;
    bool isCrit = false;

    if (isHeavy) {
      // Ağır Saldırı: Iskalama riski var, vurursa %160 hasar
      if (_rnd.nextDouble() < 0.25) {
        _combatLog = 'Ağır saldırınız boşa gitti!';
        _shakeController.shake(intensity: 2.0);
        HapticFeedback.lightImpact();
        _enemyTurnTimer();
        return;
      }
      damage = (damage * 1.6).round();
      isCrit = true;
    } else {
      // Normal Saldırı: %15 şansla kritik
      if (_rnd.nextDouble() < 0.15) {
        damage = (damage * 1.5).round();
        isCrit = true;
      }
    }

    _currentEnemy.currentHp =
        max(0, _currentEnemy.currentHp - damage);

    _shakeController.shake(intensity: isCrit ? 7.0 : 4.0);
    HapticFeedback.mediumImpact();
    GameAudioService.instance.playHit();

    setState(() {
      _enemyDamagePopup = '-$damage';
      _isEnemyCrit = isCrit;
      _combatLog = isCrit
          ? '💥 KRİTİK VURUŞ! ${_currentEnemy.name} düşmanına $damage hasar verdiniz!'
          : '⚔️ ${_currentEnemy.name} düşmanına $damage hasar verdiniz.';
    });

    Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _enemyDamagePopup = null);
    });

    if (_currentEnemy.currentHp <= 0) {
      _onFloorVictory();
    } else {
      _enemyTurnTimer();
    }
  }

  /// Düşman Karşı Saldırısı
  void _enemyTurnTimer() {
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted || !_isBattleOngoing) return;

      final rawDamage = _currentEnemy.attackPower + _rnd.nextInt(6);
      final netDamage = max(4, rawDamage - (_playerDefense ~/ 2));

      _playerCurrentHp = max(0, _playerCurrentHp - netDamage);

      _shakeController.shake(intensity: 5.0);
      HapticFeedback.heavyImpact();
      GameAudioService.instance.playHit();

      setState(() {
        _playerDamagePopup = '-$netDamage';
        _combatLog =
            '🛡️ ${_currentEnemy.name} size saldırdı! -$netDamage HP';
        _isPlayerTurn = true;
      });

      Timer(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _playerDamagePopup = null);
      });

      if (_playerCurrentHp <= 0) {
        _onPlayerDefeat();
      }
    });
  }

  /// Kat Zaferi & Sandık Açılışı
  Future<void> _onFloorVictory() async {
    _isBattleOngoing = false;
    _isFloorCleared = true;

    _shakeController.shake(intensity: 8.0);
    HapticFeedback.heavyImpact();
    GameAudioService.instance.playVictory();

    // Veritabanından rastgele zırh/silah/takı ganimeti çek
    final allItems = await DatabaseService.instance.getAllItems();
    final lootCandidates = allItems.where((i) {
      final cat = i.category.toLowerCase();
      return cat.contains('zirh') ||
          cat.contains('silah') ||
          cat.contains('taki') ||
          cat.contains('maden') ||
          cat.contains('sanat');
    }).toList();

    ItemModel loot;
    if (lootCandidates.isNotEmpty) {
      loot = lootCandidates[_rnd.nextInt(lootCandidates.length)];
    } else {
      loot = allItems.first;
    }

    _lootedItems.add(loot);
    _lastFloorLoot = loot;

    setState(() {
      _combatLog =
          '🏆 ${_currentEnemy.name} yenildi! Kat $_currentFloor temizlendi!\n🎁 Ganimet: ${loot.nameTr} (${loot.baseValue} ₺)';
    });
  }

  /// Oyuncu Yenilgisi (Ganimet Kaybı)
  void _onPlayerDefeat() {
    setState(() {
      _isBattleOngoing = false;
      _isGameOver = true;
      _combatLog =
          '☠️ Savaşçınız zindanda düştü! Toplanan ${_lootedItems.length} ganimet zindanda kayboldu!';
    });
    // Savaşçıyı toparlanması için 45 saniye dinlenmeye al
    ref.read(dungeonProvider.notifier).setMercenaryResting(widget.mercenary.id, 45);
    _shakeController.shake(intensity: 12.0);
    HapticFeedback.heavyImpact();
    GameAudioService.instance.playWarning();
  }

  /// Ganimetle Güvenli Çekilme
  void _retreatWithLoot() {
    // Toplanan eşyaları doğrudan Ev Deposuna teslim et
    ref.read(playerProfileProvider.notifier).transferAllToHomeStorage(
          _lootedItems.map((e) => e.id).toList(),
        );
    ref
        .read(playerProfileProvider.notifier)
        .addReputation(_currentFloor * 30);

    // Savaşçıyı 20 saniye nefeslenme molasına al
    ref.read(dungeonProvider.notifier).setMercenaryResting(widget.mercenary.id, 20);
    GameAudioService.instance.playCoin();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GameColors.emeraldGreen,
        content: Text(
          'Tebrikler! ${_lootedItems.length} adet ganimet Ev Deponuza aktarıldı!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  /// Bir Sonraki Kata Devam Etme
  void _continueNextFloor() {
    // Küçük can yenilenmesi (+%20 HP)
    final heal = (_playerMaxHp * 0.20).round();
    _playerCurrentHp = min(_playerMaxHp, _playerCurrentHp + heal);
    _startFloor(_currentFloor + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: GameScreenShake(
          controller: _shakeController,
          child: Column(
            children: [
              // Üst HUD: Zindan Katı ve Ganimet Sayacı
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white70, size: 22),
                      onPressed: () {
                        if (_lootedItems.isNotEmpty && !_isGameOver) {
                          _showExitConfirmDialog();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    DiegeticMetalPanel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      borderRadius: 8,
                      showRivets: false,
                      child: Row(
                        children: [
                          const Icon(Icons.castle,
                              color: GameColors.hazardYellow, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'KAT $_currentFloor',
                            style: GameTypography.display(
                                color: GameColors.goldLight, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    RetroLedDisplay(
                      label: 'HEYBEDEKİ GANİMET',
                      value: '${_lootedItems.length} EŞYA',
                      ledColor: GameColors.emeraldGreen,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),

              // Savaş Arenası
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      // 1. Düşman Paneli
                      DiegeticMetalPanel(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Text(
                                      _currentEnemy.avatar,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                    if (_enemyDamagePopup != null)
                                      Positioned(
                                        top: -16,
                                        right: -12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (_isEnemyCrit ? GameColors.gold : GameColors.lossRed).withValues(alpha: 0.95),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.white, width: 1.5),
                                            boxShadow: const [
                                              BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                                            ],
                                          ),
                                          child: Text(
                                            _enemyDamagePopup!,
                                            style: GameTypography.display(
                                              color: Colors.white,
                                              fontSize: _isEnemyCrit ? 15 : 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentEnemy.name,
                                      style: GameTypography.display(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    Text(
                                      'Saldırı Gücü: ${_currentEnemy.attackPower}',
                                      style: GameTypography.body(
                                          color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Düşman Can Barı
                            LinearProgressIndicator(
                              value: (_currentEnemy.currentHp /
                                      _currentEnemy.maxHp)
                                  .clamp(0.0, 1.0),
                              backgroundColor: Colors.white10,
                              color: GameColors.crimsonRed,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_currentEnemy.currentHp} / ${_currentEnemy.maxHp} HP',
                              style: GameTypography.display(
                                  color: Colors.white60, fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Savaş Logu ve Mesajlar
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: GameColors.panelDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: GameColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _combatLog,
                          textAlign: TextAlign.center,
                          style: GameTypography.body(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // 2. Oyuncu / Savaşçı Paneli
                      DiegeticMetalPanel(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Text(
                                      widget.mercenary.avatar,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    if (_playerDamagePopup != null)
                                      Positioned(
                                        top: -14,
                                        right: -10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: GameColors.lossRed.withValues(alpha: 0.95),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.white, width: 1.5),
                                            boxShadow: const [
                                              BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                                            ],
                                          ),
                                          child: Text(
                                            _playerDamagePopup!,
                                            style: GameTypography.display(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.mercenary.name,
                                      style: GameTypography.display(
                                          color: GameColors.goldLight,
                                          fontSize: 13),
                                    ),
                                    Text(
                                      'Saldırı: $_playerAttack | Savunma: $_playerDefense',
                                      style: GameTypography.body(
                                          color: Colors.white60, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Oyuncu Can Barı
                            LinearProgressIndicator(
                              value: (_playerCurrentHp / _playerMaxHp)
                                  .clamp(0.0, 1.0),
                              backgroundColor: Colors.white10,
                              color: GameColors.emeraldGreen,
                              minHeight: 14,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_playerCurrentHp / $_playerMaxHp HP',
                              style: GameTypography.display(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Aksiyon Butonları (Savaş Durumuna Göre)
                      if (_isFloorCleared) ...[
                        if (_lastFloorLoot != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: GameColors.emeraldGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GameColors.emeraldGreen),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.card_giftcard, color: GameColors.gold, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Kazanılan Ganimet: ${_lastFloorLoot!.nameTr} (${_lastFloorLoot!.baseValue} ₺)',
                                    style: GameTypography.body(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Kat Temizlendi: Push-Your-Luck Kararı
                        Row(
                          children: [
                            Expanded(
                              child: ArcadeButton(
                                text: 'GANİMETLE ÇEKİL 🏃',
                                color: GameColors.gold,
                                onPressed: _retreatWithLoot,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ArcadeButton(
                                text: 'SONRAKİ KAT ⚔️',
                                color: GameColors.emeraldGreen,
                                onPressed: _continueNextFloor,
                              ),
                            ),
                          ],
                        ),
                      ] else if (_isGameOver) ...[
                        ArcadeButton(
                          text: 'KARARGAHA DÖN 💀',
                          color: GameColors.crimsonRed,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ] else ...[
                        // Aktif Dövüş Aksiyonları
                        Row(
                          children: [
                            Expanded(
                              child: ArcadeButton(
                                text: 'HIZLI SALDIRI ⚔️',
                                color: GameColors.hazardYellow,
                                onPressed: _isPlayerTurn
                                    ? () => _playerAttackAction(isHeavy: false)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ArcadeButton(
                                text: 'AĞIR SALDIRI 💥',
                                color: GameColors.crimsonRed,
                                onPressed: _isPlayerTurn
                                    ? () => _playerAttackAction(isHeavy: true)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameColors.panelDark,
        title: const Text('Zindandan Çıkış',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Şimdi çıkarsanız mevcut kattaki ganimeti alıp güvenle ayrılacaksınız. Emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: GameColors.gold),
            onPressed: () {
              Navigator.of(ctx).pop();
              _retreatWithLoot();
            },
            child: const Text('Ganimetle Çık',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/features/dungeon/models/mercenary_model.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// Zindan Sefer Bilgisi
class ActiveExpedition {
  final int mercenaryId;
  final String dungeonName;
  final int dungeonDifficulty; // Zorluk gücü (örn. 80, 150, 300)
  final int durationSeconds;
  final int remainingSeconds;
  final int combatPower;

  ActiveExpedition({
    required this.mercenaryId,
    required this.dungeonName,
    required this.dungeonDifficulty,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.combatPower,
  });

  ActiveExpedition copyWith({int? remainingSeconds}) {
    return ActiveExpedition(
      mercenaryId: mercenaryId,
      dungeonName: dungeonName,
      dungeonDifficulty: dungeonDifficulty,
      durationSeconds: durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      combatPower: combatPower,
    );
  }
}

/// Sefer Sonuç Raporu
class ExpeditionResult {
  final bool isVictory;
  final String dungeonName;
  final int goldEarned;
  final int xpEarned;
  final List<ItemModel> lootItems;
  final int cooldownAppliedSeconds;
  final String? unlockedDistrictTitle;

  ExpeditionResult({
    required this.isVictory,
    required this.dungeonName,
    required this.goldEarned,
    required this.xpEarned,
    required this.lootItems,
    required this.cooldownAppliedSeconds,
    this.unlockedDistrictTitle,
  });
}

/// Zindan & Kışla Durumu
class DungeonState {
  final List<MercenaryModel> mercenaries;
  final RestingLoungeModel lounge;
  final ActiveExpedition? activeExpedition;
  final ExpeditionResult? lastResult;

  const DungeonState({
    required this.mercenaries,
    required this.lounge,
    this.activeExpedition,
    this.lastResult,
  });

  factory DungeonState.initial() {
    return const DungeonState(
      mercenaries: [],
      lounge: RestingLoungeModel(),
    );
  }

  DungeonState copyWith({
    List<MercenaryModel>? mercenaries,
    RestingLoungeModel? lounge,
    ActiveExpedition? activeExpedition,
    bool clearExpedition = false,
    ExpeditionResult? lastResult,
    bool clearResult = false,
  }) {
    return DungeonState(
      mercenaries: mercenaries ?? this.mercenaries,
      lounge: lounge ?? this.lounge,
      activeExpedition: clearExpedition ? null : (activeExpedition ?? this.activeExpedition),
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
    );
  }
}

/// Zindan ve RPG Yöneticisi
class DungeonExpeditionNotifier extends StateNotifier<DungeonState> {
  final Ref ref;
  Timer? _tickerTimer;
  final Random _rnd = Random();

  DungeonExpeditionNotifier(this.ref) : super(DungeonState.initial()) {
    _startTicker();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    if (!mounted) return;

    var updatedMercs = List<MercenaryModel>.from(state.mercenaries);
    bool mercsChanged = false;

    // 1. Dinlenen Savaşçıların Geri Sayımı
    for (int i = 0; i < updatedMercs.length; i++) {
      final merc = updatedMercs[i];
      if (merc.status == MercenaryStatus.resting && merc.restTimeRemainingSeconds > 0) {
        final newRemaining = merc.restTimeRemainingSeconds - 1;
        if (newRemaining <= 0) {
          updatedMercs[i] = merc.copyWith(
            status: MercenaryStatus.ready,
            restTimeRemainingSeconds: 0,
          );
        } else {
          updatedMercs[i] = merc.copyWith(restTimeRemainingSeconds: newRemaining);
        }
        mercsChanged = true;
      }
    }

    // 2. Aktif Sefer Geri Sayımı
    if (state.activeExpedition != null) {
      final exp = state.activeExpedition!;
      final newRemaining = exp.remainingSeconds - 1;

      if (newRemaining <= 0) {
        _finishExpedition(exp);
      } else {
        state = state.copyWith(
          activeExpedition: exp.copyWith(remainingSeconds: newRemaining),
          mercenaries: mercsChanged ? updatedMercs : null,
        );
      }
      return;
    }

    if (mercsChanged) {
      state = state.copyWith(mercenaries: updatedMercs);
    }
  }

  /// Yeni Paralı Asker İşe Al ve Kışlaya Ekle
  void recruitMercenary(MercenaryModel merc) {
    final updated = List<MercenaryModel>.from(state.mercenaries)..add(merc);
    state = state.copyWith(mercenaries: updated);
  }

  /// Savaşçıya Silah/Zırh Kuşandır
  void equipItemToMercenary(int mercenaryId, ItemModel item) {
    final updated = state.mercenaries.map((m) {
      if (m.id == mercenaryId) {
        final newItems = List<ItemModel>.from(m.equippedItems)..add(item);
        return m.copyWith(equippedItems: newItems);
      }
      return m;
    }).toList();

    state = state.copyWith(mercenaries: updated);
  }

  /// Dinlenme Odasına Mobilya/Dekor Yerleştir (Konforu artırır)
  void addDecorationToLounge(ItemModel item) {
    final updatedDecors = List<ItemModel>.from(state.lounge.placedDecorations)..add(item);
    state = state.copyWith(
      lounge: RestingLoungeModel(placedDecorations: updatedDecors),
    );
  }

  /// Seferi Başlat
  void startExpedition({
    required int mercenaryId,
    required String dungeonName,
    required int dungeonDifficulty,
    int durationSeconds = 30,
  }) {
    final mercIndex = state.mercenaries.indexWhere((m) => m.id == mercenaryId);
    if (mercIndex == -1) return;

    final merc = state.mercenaries[mercIndex];
    if (merc.status != MercenaryStatus.ready) return;

    final updatedMercs = List<MercenaryModel>.from(state.mercenaries);
    updatedMercs[mercIndex] = merc.copyWith(status: MercenaryStatus.onExpedition);

    state = state.copyWith(
      mercenaries: updatedMercs,
      activeExpedition: ActiveExpedition(
        mercenaryId: mercenaryId,
        dungeonName: dungeonName,
        dungeonDifficulty: dungeonDifficulty,
        durationSeconds: durationSeconds,
        remainingSeconds: durationSeconds,
        combatPower: merc.totalCombatPower,
      ),
      clearResult: true,
    );
  }

  /// Sefer Bittiğinde Çözümleme (Kullanıcı Kuralı: Altın YOK, sadece EŞYA ganimeti doğrudan Ev Deposuna gider)
  Future<void> _finishExpedition(ActiveExpedition exp) async {
    final mercIndex = state.mercenaries.indexWhere((m) => m.id == exp.mercenaryId);
    final merc = mercIndex != -1 ? state.mercenaries[mercIndex] : null;

    final winRate = (exp.combatPower / (exp.dungeonDifficulty * 1.2)).clamp(0.20, 0.95);
    final isVictory = _rnd.nextDouble() <= winRate;

    final discount = state.lounge.restSpeedMultiplier;
    final baseDuration = merc?.baseRestDurationSeconds ?? 60;

    final cooldownSeconds = isVictory
        ? (baseDuration * discount).round()
        : (baseDuration * 2.5 * discount).round();

    final xpEarned = isVictory ? 120 : 30;
    String? unlockedTitle;
    final lootItems = <ItemModel>[];

    if (isVictory) {
      ref.read(playerProfileProvider.notifier).addReputation(xpEarned);

      // Veritabanından rastgele 1-2 adet ganimet eşyası çek ve EV DEPOSUNA aktar
      try {
        final allItems = await DatabaseService.instance.getAllItems();
        if (allItems.isNotEmpty) {
          final lootCount = 1 + _rnd.nextInt(2);
          for (int i = 0; i < lootCount; i++) {
            final randomItem = allItems[_rnd.nextInt(allItems.length)];
            lootItems.add(randomItem);
            await ref.read(playerProfileProvider.notifier).addToHomeStorage(randomItem.id);
          }
        }
      } catch (_) {}

      // Kilitli ihale bölgelerini açma kontrolü
      final dName = exp.dungeonName.toLowerCase();
      String? targetDistrict;
      if (dName.contains('maden') || dName.contains('karanlik')) {
        targetDistrict = 'home';
        unlockedTitle = 'Terk Edilmiş Ev & Beyaz Eşya Deposu Lisansı';
      } else if (dName.contains('golge') || dName.contains('mahzen')) {
        targetDistrict = 'art';
        unlockedTitle = 'Müzisyen & Sanatçı Kasası Lisansı';
      } else if (dName.contains('kale') || dName.contains('harabe')) {
        targetDistrict = 'military';
        unlockedTitle = 'Taktik Sığınak & Donanım Deposu Lisansı';
      } else if (dName.contains('ejder') || dName.contains('in')) {
        targetDistrict = 'luxury';
        unlockedTitle = 'Milyarder Gizli Kasası Lisansı';
      }

      if (targetDistrict != null) {
        ref.read(playerProfileProvider.notifier).unlockDistrict(targetDistrict);
      }
    }

    // Savaşçıyı dinlenmeye al
    final updatedMercs = List<MercenaryModel>.from(state.mercenaries);
    if (mercIndex != -1 && merc != null) {
      updatedMercs[mercIndex] = merc.copyWith(
        status: MercenaryStatus.resting,
        restTimeRemainingSeconds: cooldownSeconds,
      );
    }

    state = state.copyWith(
      mercenaries: updatedMercs,
      clearExpedition: true,
      lastResult: ExpeditionResult(
        isVictory: isVictory,
        dungeonName: exp.dungeonName,
        goldEarned: 0, // Kural: Altın yok, sadece eşya
        xpEarned: xpEarned,
        lootItems: lootItems,
        cooldownAppliedSeconds: cooldownSeconds,
        unlockedDistrictTitle: unlockedTitle,
      ),
    );
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}

/// Global Dungeon Provider'ı
final dungeonProvider =
    StateNotifierProvider<DungeonExpeditionNotifier, DungeonState>((ref) {
  return DungeonExpeditionNotifier(ref);
});

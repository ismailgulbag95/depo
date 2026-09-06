import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/features/dungeon/providers/dungeon_expedition_provider.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';
import 'package:yeni_oyun_sablon/features/tavern/models/tavern_mercenary_model.dart';

/// Han Durumu
class TavernState {
  final List<TavernMercenaryModel> availablePool;
  final int nextRefreshSeconds;
  final int lastHiredMercenaryId;

  const TavernState({
    required this.availablePool,
    required this.nextRefreshSeconds,
    this.lastHiredMercenaryId = 0,
  });

  TavernState copyWith({
    List<TavernMercenaryModel>? availablePool,
    int? nextRefreshSeconds,
    int? lastHiredMercenaryId,
  }) {
    return TavernState(
      availablePool: availablePool ?? this.availablePool,
      nextRefreshSeconds: nextRefreshSeconds ?? this.nextRefreshSeconds,
      lastHiredMercenaryId: lastHiredMercenaryId ?? this.lastHiredMercenaryId,
    );
  }
}

/// Han ve Paralı Asker Loncası Yöneticisi
class TavernNotifier extends StateNotifier<TavernState> {
  final Ref ref;
  Timer? _refreshTimer;
  final Random _rnd = Random();

  TavernNotifier(this.ref)
      : super(TavernState(
          availablePool: const [],
          nextRefreshSeconds: 3600,
        )) {
    _generatePool();
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.nextRefreshSeconds <= 1) {
        _generatePool();
      } else {
        state = state.copyWith(nextRefreshSeconds: state.nextRefreshSeconds - 1);
      }
    });
  }

  /// 5 Yeni Paralı Asker Üretimi
  void _generatePool() {
    final names = ['Kuzeyli Ragnar', 'Gölge Elen', 'Demir Bilek Batur', 'Alev Kalpli Zehra', 'Sessiz Hakan', 'Fırtına Leyla', 'Usta Tarık', 'Gözcü Selim'];
    final titles = ['Yenilmez', 'Keskin Nişancı', 'Kurt', 'Gözüpek', 'Kaya', 'Şahin', 'Gezgin', 'Yıkıcı'];
    final roles = ['Savaşçı', 'Avcı', 'Şövalye', 'İzci', 'Büyücü'];
    final avatars = ['⚔️', '🏹', '🛡️', '🗡️', '🧙‍♂️', '🪓', '🥷'];

    final pool = <TavernMercenaryModel>[];
    for (int i = 0; i < 5; i++) {
      final id = DateTime.now().millisecondsSinceEpoch + i;
      final name = names[_rnd.nextInt(names.length)];
      final title = titles[_rnd.nextInt(titles.length)];
      final role = roles[_rnd.nextInt(roles.length)];
      final avatar = avatars[_rnd.nextInt(avatars.length)];
      final cp = 45 + _rnd.nextInt(55); // 45 - 100 CP
      final deposit = 350 + (cp * 6);
      final wage = 40 + (cp ~/ 2);
      final rest = 60 + _rnd.nextInt(60);

      pool.add(TavernMercenaryModel(
        id: id,
        name: name,
        title: title,
        role: role,
        avatar: avatar,
        baseCombatPower: cp,
        hireDeposit: deposit,
        hourlyWage: wage,
        baseRestDurationSeconds: rest,
        specialtyDescription: '$role uzmanı. Seferlerde yüksek dayanıklılık sağlar.',
      ));
    }

    state = TavernState(
      availablePool: pool,
      nextRefreshSeconds: 3600, // 1 saat
    );
  }

  /// Manuel / Ücretli Havuz Yenileme
  Future<bool> manualRefresh({bool payFee = false}) async {
    if (payFee) {
      final success = await ref.read(playerProfileProvider.notifier).deductCash(100);
      if (!success) return false;
    }
    _generatePool();
    return true;
  }

  /// Paralı Asker İşe Al (Kapasite & Nakit Kontrolü)
  Future<HireMercenaryResult> hireMercenary(TavernMercenaryModel merc) async {
    final profile = ref.read(playerProfileProvider);
    final dungeonState = ref.read(dungeonProvider);

    // 1. Kapasite Kontrolü (Ev seviyesine bağlı)
    if (dungeonState.mercenaries.length >= profile.maxMercenaryCapacity) {
      return const HireMercenaryResult(
        success: false,
        message: 'Ev kapasiteniz dolu! Emlakçıdan evinizi yükseltin.',
      );
    }

    // 2. Depozito Nakit Kontrolü
    if (profile.cash < merc.hireDeposit) {
      return HireMercenaryResult(
        success: false,
        message: 'Yetersiz bakiye! İşe alım depozitosu: ${merc.hireDeposit} ₺',
      );
    }

    // Nakit düş
    await ref.read(playerProfileProvider.notifier).deductCash(merc.hireDeposit);

    // Dungeon provider'a ekle
    ref.read(dungeonProvider.notifier).recruitMercenary(merc.toDungeonMercenary());

    // Havuzdan kaldır
    final updatedPool = List<TavernMercenaryModel>.from(state.availablePool)
      ..removeWhere((m) => m.id == merc.id);

    state = state.copyWith(
      availablePool: updatedPool,
      lastHiredMercenaryId: merc.id,
    );

    return HireMercenaryResult(
      success: true,
      message: '${merc.name} ekibinize katıldı! Dinlenme Odasında hazır bekliyor.',
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Global Tavern Provider'ı
final tavernProvider =
    StateNotifierProvider<TavernNotifier, TavernState>((ref) {
  return TavernNotifier(ref);
});

class HireMercenaryResult {
  final bool success;
  final String message;
  const HireMercenaryResult({required this.success, required this.message});
}


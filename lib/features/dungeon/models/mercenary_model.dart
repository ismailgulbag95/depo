import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';

/// Paralı Asker Durumu
enum MercenaryStatus {
  ready,        // Sefer için hazır
  onExpedition, // Zindanda seferde
  resting,      // Kışlada dinleniyor (Cooldown)
}

/// Paralı Asker Modeli
class MercenaryModel {
  final int id;
  final String name;
  final String role; // 'Savaşçı', 'Avcı', 'Şövalye'
  final String avatar;
  final MercenaryStatus status;
  final int restTimeRemainingSeconds; // Kalan dinlenme süresi
  final int baseRestDurationSeconds; // Taban dinlenme süresi (örn. 120 sn)
  final List<ItemModel> equippedItems; // Kuşanılan zırh ve silahlar

  const MercenaryModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    this.status = MercenaryStatus.ready,
    this.restTimeRemainingSeconds = 0,
    this.baseRestDurationSeconds = 120,
    this.equippedItems = const [],
  });

  /// Kuşanılan eşyalardan gelen toplam savaş gücü
  int get totalCombatPower {
    int power = 50; // Taban güç
    for (final item in equippedItems) {
      power += (item.baseValue * 0.5).round();
    }
    return power;
  }

  MercenaryModel copyWith({
    MercenaryStatus? status,
    int? restTimeRemainingSeconds,
    List<ItemModel>? equippedItems,
  }) {
    return MercenaryModel(
      id: id,
      name: name,
      role: role,
      avatar: avatar,
      status: status ?? this.status,
      restTimeRemainingSeconds: restTimeRemainingSeconds ?? this.restTimeRemainingSeconds,
      baseRestDurationSeconds: baseRestDurationSeconds,
      equippedItems: equippedItems ?? this.equippedItems,
    );
  }
}

/// Dinlenme Odası / Kışla Modeli (Konfor & Dekorasyon Sistemi)
class RestingLoungeModel {
  final List<ItemModel> placedDecorations; // Odaya konulan mobilya ve antikalar

  const RestingLoungeModel({this.placedDecorations = const []});

  /// Toplam Konfor Skoru (Her mobilya/antika konfor puanı verir)
  int get totalComfortScore {
    int score = 0;
    for (final dec in placedDecorations) {
      score += (dec.baseValue * 0.1).round().clamp(10, 100);
    }
    return score;
  }

  /// Dinlenme süresi indirim çarpanı (Maksimum %60 hızlanma)
  double get restSpeedMultiplier {
    // 0 konfor: 1.0x, 500 konfor: 0.4x (2.5 kat hızlı dinlenme)
    final reduction = (totalComfortScore / 1000.0).clamp(0.0, 0.60);
    return (1.0 - reduction);
  }
}

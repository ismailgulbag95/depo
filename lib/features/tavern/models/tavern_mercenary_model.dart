import 'package:yeni_oyun_sablon/features/dungeon/models/mercenary_model.dart';

/// Han / Paralı Asker Loncası İlan Modeli
class TavernMercenaryModel {
  final int id;
  final String name;
  final String title;
  final String role; // 'Savaşçı', 'Avcı', 'Şövalye', 'Büyücü', 'İzci'
  final String avatar;
  final int baseCombatPower;
  final int hireDeposit; // İlk İşe Alım Depozitosu (örn. 500 ₺)
  final int hourlyWage; // Saatlik Ücret (örn. 75 ₺)
  final int baseRestDurationSeconds;
  final String specialtyDescription;

  const TavernMercenaryModel({
    required this.id,
    required this.name,
    required this.title,
    required this.role,
    required this.avatar,
    required this.baseCombatPower,
    required this.hireDeposit,
    required this.hourlyWage,
    required this.baseRestDurationSeconds,
    required this.specialtyDescription,
  });

  /// Dungeon modeline dönüştür
  MercenaryModel toDungeonMercenary() {
    return MercenaryModel(
      id: id,
      name: '$name "$title"',
      role: role,
      avatar: avatar,
      status: MercenaryStatus.ready,
      baseRestDurationSeconds: baseRestDurationSeconds,
      equippedItems: const [],
    );
  }
}

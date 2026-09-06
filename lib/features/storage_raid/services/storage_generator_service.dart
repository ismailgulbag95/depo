import 'dart:math';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';

/// Depo Arketipi / Teması
enum StorageArchetype {
  mechanicGarage('Oto Tamir & Sanayi Atölyesi', 'mechanic', ['agir_sanayi', 'manuel_el_aletleri', 'elektronik_aletler']),
  retroHome('Terk Edilmiş Ev & Beyaz Eşya', 'home', ['beyaz_esya', 'ahsap_mobilya', 'retro_koleksiyon']),
  musicStudio('Müzisyen & Sanatçı Kasası', 'art', ['muzik_aletleri', 'sanat_antikalar', 'retro_koleksiyon']),
  militaryTactical('Taktik Sığınak & Donanım', 'military', ['kamp_outdoor', 'agir_sanayi', 'guvenlik_kilit']),
  luxuryVault('Milyarder Gizli Deposu', 'luxury', ['mucevher_ziynet', 'kiymetli_madenler', 'sanat_antikalar']);

  final String title;
  final String code;
  final List<String> primaryCategories;

  String get label => title;

  const StorageArchetype(this.title, this.code, this.primaryCategories);
}

/// Prosedürel Üretilmiş Depo Bilgisi
class GeneratedStorageUnit {
  final StorageArchetype archetype;
  final String unitNumber;
  final int startingBid;
  final int totalEstimatedValue;
  final List<ItemModel> layer3Items; // Arka Zemin (Küçük / Değerli)
  final List<ItemModel> layer2Items; // Orta Zemin (Kutular / Elektronik)
  final List<ItemModel> layer1Items; // Ön Zemin (Büyük Hacimli Mobilya / Makineler)

  const GeneratedStorageUnit({
    required this.archetype,
    required this.unitNumber,
    required this.startingBid,
    required this.totalEstimatedValue,
    required this.layer3Items,
    required this.layer2Items,
    required this.layer1Items,
  });

  List<ItemModel> get allItems => [...layer3Items, ...layer2Items, ...layer1Items];
}

/// 276 Eşyalık Arketip Ağırlıklı Dinamik Depo Üreticisi (ADR-021)
class StorageGeneratorService {
  StorageGeneratorService._();
  static final StorageGeneratorService instance = StorageGeneratorService._();

  final Random _rnd = Random();

  /// Her çağrıldığında değişken sayıda eşya ve toplam edere göre orantılı başlangıç teklifi üretir
  Future<GeneratedStorageUnit> generateRandomUnit({
    bool isFirstAuction = false,
    List<String>? unlockedDistricts,
  }) async {
    final allItems = await DatabaseService.instance.getAllItems();
    
    // Açık olan bölge arketiplerini filtrele
    List<StorageArchetype> availableArchetypes = StorageArchetype.values;
    if (unlockedDistricts != null && unlockedDistricts.isNotEmpty) {
      final filtered = StorageArchetype.values.where((a) => unlockedDistricts.contains(a.code)).toList();
      if (filtered.isNotEmpty) {
        availableArchetypes = filtered;
      }
    }

    final selectedArchetype = availableArchetypes[_rnd.nextInt(availableArchetypes.length)];
    final unitNum = '#${100 + _rnd.nextInt(899)}';

    // 1. Arketipe uygun eşyalar (%60 ağırlık)
    final matchingItems = allItems.where((i) {
      return selectedArchetype.primaryCategories.any((cat) =>
          i.category.toLowerCase().contains(cat.toLowerCase()) ||
          i.spritePath.contains(cat));
    }).toList()..shuffle(_rnd);

    // 2. Büyük hacimli eşyalar (Ön Zemin: width >= 2 || height >= 2 || weight >= 15)
    final bigItems = (matchingItems.where((i) => i.width >= 2 || i.height >= 2 || i.weight >= 15.0).toList()
      ..addAll(allItems.where((i) => i.width >= 2 || i.height >= 2 || i.weight >= 15.0)))
      ..shuffle(_rnd);

    // 3. Orta hacimli eşyalar (Orta Zemin)
    final mediumItems = (matchingItems.where((i) => (i.width == 2 && i.height == 1) || (i.width == 1 && i.height == 2) || (i.weight >= 4 && i.weight < 15)).toList()
      ..addAll(allItems.where((i) => (i.width == 2 && i.height == 1) || (i.width == 1 && i.height == 2) || (i.weight >= 4 && i.weight < 15))))
      ..shuffle(_rnd);

    // 4. Küçük hacimli ve değerli eşyalar (Arka Zemin)
    final smallItems = (matchingItems.where((i) => (i.width == 1 && i.height == 1) || i.baseValue > 300).toList()
      ..addAll(allItems.where((i) => (i.width == 1 && i.height == 1) || i.baseValue > 300)))
      ..shuffle(_rnd);

    // Değişken Eşya Sayıları:
    // Ön Katman: 1 - 2 büyük parça
    final l1Count = 1 + _rnd.nextInt(2);
    final layer1 = bigItems.take(l1Count).toList();

    // Orta Katman: 1 - 3 orta boy parça
    final l2Count = 1 + _rnd.nextInt(3);
    final layer2 = mediumItems.where((m) => !layer1.contains(m)).take(l2Count).toList();

    // Arka Katman: 1 - 4 küçük parça
    final l3Count = 1 + _rnd.nextInt(4);
    final layer3 = smallItems.where((s) => !layer1.contains(s) && !layer2.contains(s)).take(l3Count).toList();

    // Eksik kalan varsa tamamla
    final fallbackList = List<ItemModel>.from(allItems)..shuffle(_rnd);
    while (layer1.isEmpty && fallbackList.isNotEmpty) {
      layer1.add(fallbackList.removeLast());
    }
    while (layer2.isEmpty && fallbackList.isNotEmpty) {
      layer2.add(fallbackList.removeLast());
    }

    // İlk müzayede ise kesinlikle zindan savaşçılarına giydirilebilir bir taktik/zırh/silah eşyası ekle
    if (isFirstAuction) {
      final gearCandidates = allItems.where((i) {
        final lower = '${i.code} ${i.category} ${i.nameTr}'.toLowerCase();
        return lower.contains('yelek') ||
            lower.contains('migfer') ||
            lower.contains('zirh') ||
            lower.contains('bicak') ||
            lower.contains('silah') ||
            lower.contains('kask') ||
            lower.contains('taktik');
      }).toList();

      if (gearCandidates.isNotEmpty) {
        final guaranteedGear = gearCandidates[_rnd.nextInt(gearCandidates.length)];
        // layer2 veya layer1 içine ekle
        if (!layer2.contains(guaranteedGear) && !layer1.contains(guaranteedGear)) {
          if (layer2.isNotEmpty) {
            layer2[0] = guaranteedGear;
          } else {
            layer2.add(guaranteedGear);
          }
        }
      }
    }

    final totalItems = [...layer3, ...layer2, ...layer1];
    final totalEstValue = totalItems.map((e) => e.baseValue).fold(0, (a, b) => a + b);

    // Başlangıç teklifi toplam tahmini değerin %25 - %35'i civarında başlar
    int startBid;
    if (isFirstAuction) {
      startBid = 200 + _rnd.nextInt(3) * 50; // 200, 250, 300 ₺
    } else {
      final calculated = (totalEstValue * (0.25 + _rnd.nextDouble() * 0.10));
      startBid = ((calculated / 25).round() * 25).clamp(150, 1500);
    }

    return GeneratedStorageUnit(
      archetype: selectedArchetype,
      unitNumber: unitNum,
      startingBid: startBid,
      totalEstimatedValue: totalEstValue,
      layer3Items: layer3,
      layer2Items: layer2,
      layer1Items: layer1,
    );
  }
}

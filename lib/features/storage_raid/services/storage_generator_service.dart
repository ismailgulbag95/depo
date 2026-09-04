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
  final List<ItemModel> layer3Items; // Arka Raflar (Küçük / Değerli)
  final List<ItemModel> layer2Items; // Orta Seviye (Kutular / Elektronik)
  final List<ItemModel> layer1Items; // Ön Zemin (Büyük Hacimli Mobilya / Makineler)

  const GeneratedStorageUnit({
    required this.archetype,
    required this.unitNumber,
    required this.startingBid,
    required this.layer3Items,
    required this.layer2Items,
    required this.layer1Items,
  });

  List<ItemModel> get allItems => [...layer3Items, ...layer2Items, ...layer1Items];
}

/// 276 Eşyalık Arketip Ağırlıklı Prosedürel Depo Üreticisi (ADR-021)
class StorageGeneratorService {
  StorageGeneratorService._();
  static final StorageGeneratorService instance = StorageGeneratorService._();

  final Random _rnd = Random();

  /// Her çağrıldığında taptaze, rastgele ve dengeli bir depo üretir
  Future<GeneratedStorageUnit> generateRandomUnit() async {
    final allItems = await DatabaseService.instance.getAllItems();
    final archetypes = StorageArchetype.values;
    final selectedArchetype = archetypes[_rnd.nextInt(archetypes.length)];
    final unitNum = '#${100 + _rnd.nextInt(899)}';

    // 1. Arketipe uygun eşyalar (%60 öncelik)
    final matchingItems = allItems.where((i) {
      return selectedArchetype.primaryCategories.any((cat) => i.category.toLowerCase().contains(cat.toLowerCase()) || i.spritePath.contains(cat));
    }).toList()..shuffle(_rnd);

    // 2. Büyük hacimli eşyalar (Ön Zemin için: width >= 2 || height >= 2 || weight >= 15)
    final bigItems = (matchingItems.where((i) => i.width >= 2 || i.height >= 2 || i.weight >= 15.0).toList()
      ..addAll(allItems.where((i) => i.width >= 2 || i.height >= 2 || i.weight >= 15.0)))
      ..shuffle(_rnd);

    // 3. Orta hacimli eşyalar
    final mediumItems = (matchingItems.where((i) => (i.width == 2 && i.height == 1) || (i.width == 1 && i.height == 2) || (i.weight >= 4 && i.weight < 15)).toList()
      ..addAll(allItems.where((i) => (i.width == 2 && i.height == 1) || (i.width == 1 && i.height == 2) || (i.weight >= 4 && i.weight < 15))))
      ..shuffle(_rnd);

    // 4. Küçük hacimli ve değerli eşyalar (Arka Raf için: 1x1 veya mücevher/alet)
    final smallItems = (matchingItems.where((i) => (i.width == 1 && i.height == 1) || i.baseValue > 300).toList()
      ..addAll(allItems.where((i) => (i.width == 1 && i.height == 1) || i.baseValue > 300)))
      ..shuffle(_rnd);

    // Katmanlara dengeli dağıt:
    // Ön Zemin: 2 - 3 büyük eşya
    final layer1 = bigItems.take(2 + _rnd.nextInt(2)).toList();

    // Orta Zemin: 3 orta boy eşya
    final layer2 = mediumItems.where((m) => !layer1.contains(m)).take(3).toList();

    // Arka Raflar: 3 küçük/değerli eşya
    final layer3 = smallItems.where((s) => !layer1.contains(s) && !layer2.contains(s)).take(3).toList();

    // Eğer eşya sayıları eksik kalırsa rastgele tamamla
    final fallbackList = List<ItemModel>.from(allItems)..shuffle(_rnd);
    while (layer1.length < 2 && fallbackList.isNotEmpty) {
      layer1.add(fallbackList.removeLast());
    }
    while (layer2.length < 3 && fallbackList.isNotEmpty) {
      layer2.add(fallbackList.removeLast());
    }
    while (layer3.length < 3 && fallbackList.isNotEmpty) {
      layer3.add(fallbackList.removeLast());
    }

    final startBid = 150 + _rnd.nextInt(4) * 50; // 150, 200, 250, 300 ₺

    return GeneratedStorageUnit(
      archetype: selectedArchetype,
      unitNumber: unitNum,
      startingBid: startBid,
      layer3Items: layer3,
      layer2Items: layer2,
      layer1Items: layer1,
    );
  }
}

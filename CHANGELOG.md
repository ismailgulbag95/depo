# 📝 DEĞİŞİKLİK GÜNLÜĞÜ (CHANGELOG.md)

Bu projedeki tüm önemli değişiklikler bu dosyada belgelenir.
Format [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) standardına ve [Semantic Versioning](https://semver.org/spec/v2.0.0.html) yapısına uygundur.

---

## [Unreleased] - Geliştirilmekte Olanlar

### Eklenecekler (Planned)
- Faz 3: Bagajda serbest polyomino sürükle-bırak kılavuzu ve manuel $90^\circ$ döndürme kontrolleri.

---

## [0.3.0] - 2026-09-02

### Eklendi (Added)
- **2D Katmanlı Depo Yağmalama Sahnesi (`StorageRaidGame`):** Flame motoru üzerinde 3 kademeli derinlik (Ön Plan %0, Orta Plan %75, Arka Plan %100 gölge maskesi) ve `revealDepth` aydınlanması.
- **İnteraktif Eşya Seçim Çubuğu:** Tıklanan eşyada "HURDA" (%20 gelir) ve "ARACA YÜKLE" buton etkileşimi.
- **Dikey Hibrit Ekran (`StorageRaidScreen`):** Üstte 2D Katmanlı Depo, altta Araç Bagajı Grid Tetrisi.
- **Hızlı Animasyonlu Nakliye Değişimi:** "Nakliye Çağır" butonuna basıldığında mevcut aracın kayarak çıkıp yeni aracın 400ms içinde yanaşması.
- **Hoşgörülü Ağırlık Barı:** Yalnızca devasa parçalar dolduğunda uyaran esnek ağırlık göstergesi.
- **Resmî Tasfiye Faturası Kartı (`RaidSummarySheet`):** Yüklenen eşyalar, hurda geliri, nakliye gideri, temizlik cezası ve net kâr dökümü.
- **Amerikan Depo Şeması (`StorageUnitModel`):** Yerinde canlı ihale vs web sitesi ilanı desteği.

---

## [0.2.0] - 2026-09-02

### Eklendi (Added)
- **64-Bit Bitboard Polyomino Motoru (`lib/core/utils/bitboard_engine.dart`):** $O(1)$ sürede satır çakışma testi (`canPlace`), eşya yerleştirme (`placeItem`), kaldırma (`removeItem`), $90^\circ$ saat yönünde döndürme (`rotate90`) ve boyut hesaplama (`calculateBounds`).
- **Kapsamlı Birim Testleri (`test/core/bitboard_engine_test.dart`):** Boş grid, sınır aşımı, çakışma, yerleştir/kaldır simetrisi ve polyomino rotasyon testleri.
- **Oyun Sabitleri (`lib/core/constants/game_constants.dart`):** `ItemCondition` (değer çarpanları), `ItemCategory`, `VehicleTemplate` (Pikap, Kamyonet, Kargo Kamyonu) ve oyun parametreleri.
- **Isar Koleksiyon Şemaları (`lib/core/database/models/`):** `ItemModel`, `VehicleModel`, `PlacerRecord` ve `PlayerProfileModel`.
- **Başlangıç Tohum Kataloğu (`assets/data/default_items.json`):** Boyutları ve bit maskeleri tanımlanmış ilk eşya veri seti.
- **Isar Singleton Servisi (`lib/core/database/isar_service.dart`):** Otomatik veritabanı başlatıcı ve seed tohumlayıcı; `main.dart` entegrasyonu.
- **4 Dilli Yerelleştirme Mimarisi (`lib/core/localization/`):**
  - Türkçe (TR), İngilizce (EN), Rusça (RU) ve İspanyolca (ES) destekli `LocalizationService` ve `AppLanguage` enum'ı.
  - `assets/lang/` dizininde `tr.json`, `en.json`, `ru.json`, `es.json` dosyaları.
  - `ItemModel` şemasına ve `default_items.json` kataloğuna 4 dilli isim alanları (`nameTr`, `nameEn`, `nameRu`, `nameEs`) ve `localizedName` metodu eklendi.
  - Hive `settingsBox` ile dil tercihi kalıcılığı.

---

## [0.1.0] - 2026-09-02

### Eklendi (Added)
- **Modüler Dokümantasyon Sistemi:**
  - `PROJECT.md`: Proje vizyonu, oynanış döngüsü ve hedef kitle analizi.
  - `PHASES.md`: 5 ana fazın ayrıştırılmış kapsam ve teslimat tanımları.
  - `ROADMAP.md`: Sprint takvimi, teslim tarihleri, kilometre taşları (M1-M5) ve DoD kriterleri.
  - `ARCHITECTURE.md`: Detaylı matematik formülleri, Isar modelleri, Bitboard ve Dual-Channel mimarisi.
  - `TODO.md`: Sıradaki işin ne olduğunu belirleyen yaşayan görev panosu.
  - `DECISIONS.md`: 7 adet ADR (Architecture Decision Record) ile alınan kararlar ve gerekçeleri.
  - `LESSONS.md`: Hatalardan çıkarılan teknik dersler ve mimari prensipler.
  - `CHANGELOG.md`: Sürüm geçmişi takibi.
  - `README.md`: Proje kurulumu, çalıştırma adımları ve mimari fihristi.
- **Python Varlık İşleme Hattı (`tools/`):**
  - BiRefNet model tabanlı otomatik arka plan temizleme (`item_ayiklama.py`).
  - Eşya sınırlarını kırpma ve padding normalizasyon betiği (`refine_assets.py`).
  - Tek tıkla çalıştırma betiği (`run_pipeline.bat`).
- **Flutter Bağımlılıkları (`pubspec.yaml`):**
  - `flame` (1.38.2), `flutter_riverpod` (2.6.1), `isar` (3.1.0+1), `hive` (2.2.3), `audioplayers` (6.8.1).

### Değiştirildi (Changed)
- **Mimari Paradigma Değişimi:** Hantal ve zaman alıcı 2.5D izometrik Blender 3D yaklaşımı terk edildi; yerine hafif, 60-120 FPS akıcı ve gerçekçi 2D Katmanlı Derinlik (Frontal Elevation) modeline geçildi.
- **Sanat Tarzı:** Pixel art yaklaşımı reddedildi; stüdyo aydınlatmalı yüksek çözünürlüklü izole fotogerçekçi 2D varlık modeli benimsendi.
- **Dokümantasyon Mimarisi:** Monolitik `docs/ARCHITECTURE_AND_ROADMAP.md` dosyası yerine 9 modüler, yaşayan dosyaya geçildi.

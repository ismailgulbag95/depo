# 📋 GÖREV LİSTESİ VE SIRADAKİ İŞLER (TODO.md)

Bu dosya; geliştirme sürecinde **ŞU AN HANGİ İŞİN YAPILDIĞI**, **SIRADAKİ İŞİN NE OLDUĞU** ve faz bazlı tüm görevlerin durumunu takip eden yaşayan kontrol panosudur.

---

## ⚡ ŞU AN AKTİF İŞ (CURRENT FOCUS)

> **🎯 HEDEF:** FAZ 5 — Zindan Keşifleri, Paralı Asker Kuşanma & Idle/Aktif Seferler  
> **Sorumlu Modül:** `lib/features/dungeon/`  
> **Durum:** 🟡 Başlatılıyor (In Progress)

### Tamamlanan Faz 4 Mikro Adımları:
1. [x] **Dokunsal Restorasyon Mini-Simülasyonu (`ADR-028`):** Parmakla pasları ovalayarak silme, haptik titreşim ve `ColorFiltered` pas maskesi.
2. [x] **Atölye Ustalık Seviyesi & Otomatik Seri Restorasyon:** Her temizlemede +35 Atölye Ustalık XP'si, Seviye 3+ olunca tek tıkla otomatik parlatma.
3. [x] **Pazar Yeri & Dinamik Fiyat Slider'ı (`ADR-029`):** %50 - %250 serbest fiyat belirleme, anlık kâr/zarar hesaplama.
4. [x] **Poisson Müşteri Pazarlık Simülatörü:** Dükkana gelen bot müşteriler (Hurdacı, Koleksiyoncu, Antikacı, Tüccar) ile diyalog ve teklif pazarlığı.

---

## 📌 SIRADA BEKLEYENLER (FAZ 5 - ZİNDAN & RPG SEFERLERİ)

- [ ] **Paralı Asker Kuşanma Menüsü:** Toplanan ve onarılan zırh/silahların askere donatılması.
- [ ] **Taskbar Hero / Idle Sefer Simülatörü:** Zindana gönderilen ekibin geri sayımı ve ganimet raporu.

---

## 🗂️ FAZ BAZLI GÖREV ARŞİVİ (BACKLOG)

### 🔹 FAZ 1: Çekirdek Altyapı & Bitboard Engine (TAMAMLANDI ✅)
- [x] `game_constants.dart` (Izgara boyutları, ağırlık katsayıları, kondisyon çarpanları)
- [x] `bitboard_engine.dart` ($O(1)$ satır çakışması ve bit maskesi hesaplama)
- [x] `bitboard_engine_test.dart` (Birim testleri)
- [x] `item_model.dart` (Hive & Pure Dart Modeli)
- [x] `vehicle_model.dart` (Hive & Pure Dart Modeli)
- [x] `player_profile_model.dart` (Hive & Pure Dart Modeli)
- [x] `storage_unit_model.dart` (Hive & Pure Dart Modeli)
- [x] `default_items.json` başlangıç seed kataloğu (4 dilli)
- [x] `database_service.dart` evrensel Hive veritabanı başlatıcı ve tohumlayıcı
- [x] Evrensel Map serileştirme ve birim test paketi (`database_service_test.dart`)
- [x] 276 eşyanın BiRefNet ile işlenmesi ve `pubspec.yaml` bağlantısı
- [x] `PlayerState` (`PlayerProfileNotifier`) Riverpod provider'ı
- [x] `InventoryState` (`TrunkInventoryNotifier`) Riverpod provider'ı
- [x] 4 Dilli Yerelleştirme Mimarisi (`LocalizationService`, TR, EN, RU, ES)

### 🔹 FAZ 2: 2D Depo Yağmalama (Flame Katmanı - TAMAMLANDI ✅)
- [x] `StorageRaidGame` ana sahne iskeleti
- [x] 3 Kademeli katmanlı derinlik ve duvar çizimi
- [x] `RaidItemComponent` (Kademeli %0, %75, %100 gölge maskesi)
- [x] Ön eşya kalkınca arkadaki gölgenin kademeli açılması (`revealDepth`)
- [x] Eşya seçim aksiyon çubuğu ("HURDA" vs "ARACA YÜKLE")
- [x] Flame 60 saniyelik raid sayacı
- [x] Temizlik cezası formülü ($Kalanlar \times 0.25$)
- [x] Resmî Amerikan tasfiye faturası kartı (`RaidSummarySheet`)
- [x] Dikey Hibrit Ekran (`StorageRaidScreen`: Üstte Depo, Altta Bagaj)
- [x] Hızlı animasyonlu (400ms) "Nakliye Çağır" araç değişimi ve hoşgörülü ağırlık barı

### 🔹 FAZ 3: Araç Bagajı Grid Tetrisi
- [ ] `TrunkGridComponent` (Pikap ve kamyonet için ızgara çizimi)
- [ ] Polyomino parmakla sürükle-bırak (`Draggable` / `DragCallbacks`)
- [ ] Grid hücresine göre yeşil/kırmızı snap görsel geri bildirimi
- [ ] Eşya döndürme butonu ($90^\circ$ saat yönü transpoze)
- [ ] Bagaj ağırlık ve hacim doluluk göstergesi
- [ ] Depodan çıkan eşyaların araç bagajına yerleştirilme akışı (Yükleme Platformu)

### 🔹 FAZ 4: Ekonomi, İhale, Pazar Yeri & Tezgahlar
- [ ] Depo açık artırma ekranı (Kepenk aralama animasyonu)
- [ ] Poisson dağılımlı Bot yapay zekası teklif mekanizması
- [ ] Hurdacı ekranı (Anında %20 nakit satışı)
- [ ] Oyun içi Pazar Yeri (Marketplace) listeleme ekranı
- [ ] Pazar Yeri dinamik satış bekleme formülü entegrasyonu
- [ ] Ultrasonik temizleme tezgahı ekranı ve animasyonu
- [ ] Hassas tamir tezgahı ekranı ve animasyonu
- [ ] Mistik dönüştürücü tezgahı ekranı

### 🔹 FAZ 5: Zindan Sefer Sistemi (AFK Simülatörü & RPG) & Global Polish
- [ ] Paralı asker kiralama ve eşya kuşandırma arayüzü
- [ ] Discrete-Time AFK simülasyon motoru (Arka plan süresine göre oda ve karşılaşma hesaplama)
- [ ] Düşman Karşılaşma ve FSM / Simülasyon Yapay Zekası (Karşılaşma zorluk dereceleri, bot tepkileri)
- [ ] Sefer süresi zamanlayıcısı (5 dk, 15 dk, 1 saat) ve güç skoru formülü
- [ ] Sefer dönüşü başarı/başarısızlık sonuç ekranı (Sefer Günlüğü Raporu)
- [ ] Sefer ganimetlerinin (nadir eşyalar, altın) dükkan deposuna teslim edilmesi
- [ ] Kuşanılan eşyaların kondisyon aşınma mekanizması
- [ ] Game Feel: Ekran sarsıntısı (`CameraComponent.shake`), parıldama parçacıkları
- [ ] Ses efektleri (`audioplayers` entegrasyonu)
- [ ] Bellek sızıntısı (Leak) ve FPS profil denetimi (DevTools)

---

## ✅ TAMAMLANANLAR (DONE)

- [x] Projenin ana mimarisinin 2.5D izometrikten 2D derinlikli katmanlı modele evrilmesi kararı alındı.
- [x] Python tabanlı `rembg` (BiRefNet) otomatik eşya kırpma ve arka plan temizleme pipeline'ı (`tools/` dizini) kuruldu.
- [x] Temel Flutter paketleri (`flame`, `flutter_riverpod`, `isar`, `hive`, `audioplayers`) `pubspec.yaml`'a eklendi.
- [x] Proje yol haritası ve dokümantasyon sistemi 10 ana md dosyası (`MOTHER.md` dahil) olarak kuruldu.
- [x] `/grill-me` tasarım mülakatı tamamlandı; Bitboard formatı, araç bagajı şablonları, Taskbar Hero sefer modeli, master seed JSON ve slotlu dükkan deposu kararları kesinleştirildi (ADR-008, 009, 010).

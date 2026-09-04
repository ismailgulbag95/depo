# 👑 ANA KOMUTA MERKEZİ VE SİSTEM ÖZETİ (MOTHER.md)

Bu doküman; **Depo Avcıları (Storage Raiders & RPG)** projesinin tüm dokümantasyon, mimari ve geliştirme ekosisteminin **tek doğruluk kaynağı (Single Source of Truth)** ve çatı yönetim merkezidir.

Geliştirici veya yapay zeka ajanları projeye her adım attığında ilk olarak bu dosyaya başvurur; sistemin o anki genel durumunu, dokümanların görev dağılımlarını ve hangi iş için hangi dosyaya gidilmesi gerektiğini buradan öğrenir.

---

## 🧭 1. DOKÜMANTASYON EKOSİSTEMİ VE GÖREV DAĞILIMI

Projedeki her dokümanın sınırları kesin olarak belirlenmiş, birbiriyle çakışmayan ve birbirini tamamlayan rolleri vardır:

```
                                [MOTHER.md]
                     (Ana Komuta & Navigasyon Merkezi)
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         ▼                           ▼                           ▼
  [STRATEJİ & HEDEF]           [OPERASYON & TAKİP]         [TEKNİK & MİMARİ]
  ├── PROJECT.md               ├── TODO.md                 ├── ARCHITECTURE.md
  ├── PHASES.md                ├── ROADMAP.md              ├── DECISIONS.md
  └── README.md                └── CHANGELOG.md            └── LESSONS.md
```

| No | Doküman Adı | Temel Görevi ve Sorumluluğu | Ne Zaman Bakılmalı? | Ne Zaman Güncellenmeli? |
| :-: | :--- | :--- | :--- | :--- |
| 👑 | [**MOTHER.md**](file:///d:/github/depo/MOTHER.md) | **Tüm sistemin ana özeti, komuta merkezi ve doküman navigasyon haritası.** | Projeye başlarken, yön kaybolduğunda veya genel durum özetine ihtiyaç duyulduğunda. | Yeni bir doküman eklendiğinde veya büyük faz geçişlerinde. |
| 🎯 | [**PROJECT.md**](file:///d:/github/depo/PROJECT.md) | Oyunun ne olduğunu, temel oynanış döngüsünü (Core Loop) ve hedef kitlenin (4 Persona) motivasyonunu tanımlar. | Bir özelliğin oyunun ruhuna ve hedef kitlesine uygunluğu tartışılırken. | Oyunun temel vizyonu veya ana oynanış döngüsü değişirse. |
| 🏗️ | [**PHASES.md**](file:///d:/github/depo/PHASES.md) | Projeyi 5 bağımsız fazın kapsam ve modül sınırlarına böler. | Bir özelliğin hangi faza ait olduğu ve bağımlılık sırası incelenirken. | Bir fazın kapsamına yeni bir modül eklendiğinde / çıkarıldığında. |
| 🗺️ | [**ROADMAP.md**](file:///d:/github/depo/ROADMAP.md) | Hangi fazın ne zaman biteceğini, sprint takvimini, kilometre taşlarını (M1-M5) ve kabul kriterlerini (DoD) belirler. | Sprint planlamalarında ve teslim tarihleri kontrol edilirken. | Sprint tamamlandığında veya gecikme/tampon devreye girdiğinde. |
| 🏛️ | [**ARCHITECTURE.md**](file:///d:/github/depo/ARCHITECTURE.md) | Her fazın ayrı ayrı tüm teknik detaylarını, veri modellerini, Bitboard motorunu, formülleri ve Dual-Channel mimarisini içerir. | Kod yazarken, algoritma kurarken veya veri tabanı şeması oluştururken. | Yeni bir algoritma, formül veya teknik mimari bileşen eklendiğinde. |
| 📋 | [**TODO.md**](file:///d:/github/depo/TODO.md) | **ŞU AN HANGİ İŞİN YAPILDIĞINI**, sıradaki mikro adımları ve faz görev listesini gösteren canlı pano. | Her geliştirme oturumunun başında ("Sıradaki işim ne?") sorusunda. | Her mikro görev başlarken ve tamamlandığında (Anlık/Sürekli). |
| ⚖️ | [**DECISIONS.md**](file:///d:/github/depo/DECISIONS.md) | Alınan mimari ve stratejik kararların (ADR-001 - ADR-007) gerekçelerini ve alternatiflerini kayıt altında tutar. | "Bu sistem neden böyle yapıldı?" veya "Alternatifi neydi?" dendiğinde. | Projede kritik bir mimari/teknik tercih yapıldığında. |
| 💡 | [**LESSONS.md**](file:///d:/github/depo/LESSONS.md) | Yapılan hatalardan çıkarılan dersleri, karşılaşılan darboğazları ve çözümlerini not eder. | Bir sorunla karşılaşıldığında veya mimari revizyon öncesi tuzakları anımsamak için. | Bir hata çözüldüğünde veya performans darboğazı aşıldığında. |
| 📝 | [**CHANGELOG.md**](file:///d:/github/depo/CHANGELOG.md) | SemVer ve Keep a Changelog standardında nelerin eklendiğini, değiştiğini ve düzeltildiğini listeler. | Yeni bir sürüme geçildiğinde veya son değişiklikler incelenirken. | Her sprint veya anlamlı özellik tamamlandığında. |
| 🚀 | [**README.md**](file:///d:/github/depo/README.md) | Projenin nasıl kurulduğunu, ortam gereksinimlerini ve asset pipeline çalıştırma adımlarını anlatır. | Yeni bir bilgisayarda ortam kurulurken veya proje ilk kez çalıştırılırken. | Bağımlılıklar, çalıştırma komutları veya ortam şartları değiştiğinde. |

---

## 🚦 2. GELİŞTİRİCİ VE YAPAY ZEKA İÇİN KARAR MATRİSİ

Ne yapmak istiyorsunuz? Aşağıdaki tabloyu kullanarak doğrudan doğru dokümana gidin:

```
"Sıradaki işim tam olarak ne?"             ──► TODO.md (Şu An Aktif İş)
"Bu formülün/algoritmanın kodu nasıl?"    ──► ARCHITECTURE.md
"Bu özellik hangi sprintte bitecek?"      ──► ROADMAP.md
"Neden 3D yerine 2D katman seçtik?"       ──► DECISIONS.md (ADR-001)
"Daha önce bu jank/kasma hatası oldu mu?" ──► LESSONS.md
"Bu özellik hedef kitleye uygun mu?"      ──► PROJECT.md
"Projeyi sıfırdan nasıl ayağa kaldırırım?"──► README.md
```

---

## 🔄 3. DOKÜMANLAR ARASI GÜNCELLEME AKIŞI

Geliştirme sürecinde bir iş yapıldığında bilgi şu sırayla akar:

```mermaid
flowchart TD
    A[TODO.md: Sıradaki mikro işi seç] --> B[ARCHITECTURE.md: Teknik formülü ve mimariyi incele]
    B --> C[Kod Geliştirme & Birim Testleri]
    C --> D{Kritik bir karar veya hata çıktı mı?}
    D -- Evet: Karar alındı --> E[DECISIONS.md: ADR kaydı ekle]
    D -- Evet: Hata/Ders oldu --> F[LESSONS.md: Çıkarılan dersi yaz]
    D -- Hayır / Normal Akış --> G[TODO.md: Görevi [x] Done olarak işaretle]
    E --> G
    F --> G
    G --> H[ROADMAP.md: Faz DoD kontrolü yap]
    H --> I[CHANGELOG.md: Sürüme 'Added/Changed' ekle]
```

---

## 📊 4. PROJENİN ANLIK DURUM RAPORU (SNAPSHOT)

- **Tamamlanan Fazlar:**
  - ✅ **FAZ 1 — Çekirdek Veri Katmanı, Evrensel HIVE NoSQL ve Bitboard Motoru**
  - ✅ **FAZ 2 — 2D Katmanlı Depo Yağmalama (Flame Engine - `StorageRaidGame`)**
  - ✅ **FAZ 3 — Araç Bagajı Grid Tetrisi İleri Kontrolleri & Depo-Bagaj Entegrasyonu**
  - ✅ **FAZ 4 — Atölye / Restorasyon Tezgâhları, Hurda & Pazar Yeri Ticareti**
- **Aktif Faz:** **FAZ 5 — Zindan Keşifleri, Paralı Asker Kuşanma & Idle/Aktif Seferler**
- **Tamamlanan Bileşenler:**
  - ✅ `BitboardEngine` 64-bit polyomino motoru ve testleri
  - ✅ Evrensel Pure Dart Modelleri (`ItemModel`, `VehicleModel`, `PlayerProfileModel`, `StorageUnitModel`)
  - ✅ Evrensel `DatabaseService` (Hive) ve birim test paketi (`database_service_test.dart`)
  - ✅ 276 Eşya Varlığı (21 kategoride WebP/PNG) ve 4 dilli yerelleştirme (TR, EN, RU, ES)
  - ✅ **Anti-AI Game UI Tasarım Kuralı & Görsel Zeka (`anti_ai_game_ui_design_rules.md`)**
  - ✅ **Endüstriyel Tipografi & Renk Paleti (`GameTheme`, `GameTypography`, `GameColors`)**
  - ✅ **Diegetik Oyun Bileşenleri (`DiegeticMetalPanel`, `RetroLedDisplay`, `HazardStripeBanner`, `AuctionStamp`, `GameScreenShake`)**
  - ✅ Dikey Hibrit Ekran (`StorageRaidScreen`): Üstte 2D Katmanlı Depo, Altta Diegetik Bagaj Grid Tetrisi
  - ✅ 90 Derece Eşya Döndürme (3D Arcade Buton + Çift Dokunma / `onDoubleTap`, `ADR-023`)
  - ✅ Bagaj Eşyalarını Serbest Yeniden Düzenleme ve Havaya Kaldırma (`popItemAt`, `ADR-024`)
  - ✅ Usta İstifçi %80+ XP Bonusu ve Gizli Piyasa Değeri Prensibi (`ADR-025`)
  - ✅ Holografik Neon Snap Kılavuzu (Yeşil/Kırmızı anlık önizleme, `ADR-026`)
  - ✅ **Dokunsal Restorasyon Mini-Simülasyonu & Seviye 3+ Otomatik Restorasyon (`CraftingBenchScreen`, `ADR-028`)**
  - ✅ **Dinamik Fiyat Slider'ı & Poisson Müşteri Pazarlık Simülatörü (`MarketplaceScreen`, `ADR-029`)**
  - ✅ Kademeli Gölge Modeli (%0, %75, %100) ve `revealDepth` aydınlanması
  - ✅ Eşya Aksiyon Çubuğu ("HURDA", "90°", "ARACA YÜKLE")
  - ✅ 400ms Hızlı Slide Animasyonlu "Nakliye Çağır" ve Hoşgörülü Ağırlık Barı
  - ✅ Canlı Amerikan Açık Artırması (`LiveAuctionScreen`): Kepenk açılışı, podyum neon anonsu, LED skorbord, tokmak sarsıntısı ve damga mührü
  - ✅ Zemin Tabanlı Yuvalar & Perspektif Ölçekleme (Büyük mobilyalar zemine, aletler raflara)
  - ✅ 3D Basılma Derinlikli Endüstriyel Arcade HUD Butonları (`ArcadeButton`)
  - ✅ 276 Eşyalık Arketip Ağırlıklı Prosedürel Depo Üreticisi (`StorageGeneratorService`)
  - ✅ Gerçekçi Endüstriyel Depo Arka Planı (Beton zemin, tuğla duvar, sarı-siyah şeritler, konik ışık huzmesi)
- **Odak Noktası:** Faz 5: Paralı Asker Kuşanma ve Zindan Seferi Simülatörü.
- **Mimari Karar Durumu:** 29/29 ADR onaylandı (ADR-001'den ADR-029'a tüm kararlar dahil).
- **Sistem Sağlığı:** 🟢 Yeşil (Faz 4 %100 tamamlandı, Faz 5'e geçildi).

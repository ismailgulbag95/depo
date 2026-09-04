# 🏛️ SİSTEM MİMARİSİ VE TEKNİK DOKÜMANTASYON (ARCHITECTURE.md)

Bu doküman; Depo Avcıları (Storage Raiders & RPG) projesinin uçtan uca mimarisini, veri modellerini, algoritmalarını ve her fazın tüm teknik detaylarını içerir.

---

## 1. MİMARİ İLKELER VE TEKNOLOJİ YIĞINI

### 1.1. Teknoloji Yığını
- **İskelet & UI:** Flutter 3.x / Dart (Saf Flutter arayüzü, Menüler, Pazar Yeri, Atölye, HUD).
- **Oyun Motoru:** Flame Engine 1.38+ (Depo Yağmalama Katmanı, Grid Fiziği, Top-Down Zindan).
- **Durum Yönetimi (State Management):** Flutter Riverpod 2.6+ (Global durum, servisler, depolar).
- **Veri Tabanı & Kalıcılık:**
  - **Isar Database 3.1+:** İlişkisel, sorgulanabilir, yüksek performanslı yerel NoSQL veritabanı (Eşyalar, Envanter, Oyuncu Profili).
  - **Hive 2.2+:** Hızlı key-value ayar saklama (Ses seviyesi, tema, dil tercihleri).
- **Varlık Üretim Hattı:** Python 3.10+, BiRefNet (`rembg`), Pillow, Midjourney / Flux.1 AI stüdyo promptları.

### 1.2. Mimari Katmanlaşma (Clean Architecture + Feature-First)
```
lib/
├── core/                  # Çekirdek Altyapı (Tüm projenin paylaştığı kodlar)
│   ├── bridge/            # Flame <-> Flutter Dual-Channel Köprüsü
│   ├── constants/         # Oyun sabitleri (Grid boyutları, renkler, tagler)
│   ├── database/          # Isar DB singleton, koleksiyon şemaları
│   ├── theme/             # Modern koyu tema, tipografi, cam tasarımı (Glassmorphism)
│   └── utils/             # Bitboard matematik motoru, formüller
│
└── features/              # Özellik Modülleri (Her biri kendi içinde bağımsız)
    ├── auction/           # İhale ve Açık Artırma (Flutter UI)
    ├── storage_raid/      # Depo Yağmalama (Flame + Mikro-HUD)
    ├── trunk_tetris/      # Araç Bagajı Grid Tetrisi (Flame + Bitboard)
    ├── crafting_benches/  # Restorasyon & Zanaat Tezgahları (Flutter UI)
    ├── marketplace/       # Hurdacı & Pazar Yeri (Flutter UI)
    ├── dungeon/           # AFK Simülasyonu + Aktif Flame Savaşı
    └── player_profile/    # Oyuncu İlerlemesi, Garaj ve Seviyeler
```

---

## 2. FAZLARIN AYRI AYRI TÜM TEKNİK DETAYLARI

---

### 🔹 FAZ 1 TEKNİK DETAYLARI: Çekirdek Veri Katmanı ve 64-Bit Bitboard Motoru

#### A. Veri Modelleri ve Isar Şemaları
```dart
// Eşya Kondisyonu (Envanter ve Değer Çarpanı)
enum ItemCondition {
  scrap(0.2),     // Hurda
  poor(0.5),      // Kötü
  good(1.0),      // İyi
  pristine(1.5),  // Mükemmel
  mystic(2.5);    // Mistik / Melez

  final double valueMultiplier;
  const ItemCondition(this.valueMultiplier);
}

// Isar Eşya Koleksiyonu Şeması
@collection
class ItemModel {
  Id id = Isar.autoIncrement;
  late String name;
  late String category; // Silah, Antika, Elektronik, Alet, Hazine
  late int baseValue;
  late int width;
  late int height;
  late List<int> bitmask; // Her satır için bit maskesi
  late double weight;
  late String spritePath;
  
  @enumerated
  late ItemCondition condition;
}
```

#### B. 64-Bit Bitboard Çarpışma ve Döndürme Algoritması
Geleneksel 2D matris döngüleri ($O(M \times N)$) yerine, satır başına 64-bit tamsayı bit maskeleri kullanılır.
```dart
class BitboardEngine {
  /// Grid ve eşya çakışma testi O(1) sürede yapılır
  static bool canPlace({
    required List<int> gridRows,
    required List<int> itemMask,
    required int startX,
    required int startY,
    required int gridWidth,
    required int gridHeight,
  }) {
    final itemH = itemMask.length;
    if (startY + itemH > gridHeight) return false;

    for (int r = 0; r < itemH; r++) {
      final shiftedMask = itemMask[r] << startX;
      // Grid sınır taşması kontrolü
      if ((shiftedMask >= (1 << gridWidth)) || (shiftedMask < 0)) return false;
      // Satır çakışma testi: (GridRow & ItemRowMask) != 0 ise yer doludur
      if ((gridRows[startY + r] & shiftedMask) != 0) {
        return false;
      }
    }
    return true;
  }

  /// Eşyayı 90 derece saat yönünde transpoze edip döndürür
  static List<int> rotate90(List<int> shape, int originalW, int originalH) {
    List<int> rotated = List.filled(originalW, 0);
    for (int r = 0; r < originalH; r++) {
      for (int c = 0; c < originalW; c++) {
        if ((shape[r] & (1 << c)) != 0) {
          rotated[c] |= (1 << (originalH - 1 - r));
        }
      }
    }
    return rotated;
  }
}
```

---

### 🔹 FAZ 2 TEKNİK DETAYLARI: 2D Katmanlı Depo Yağmalama (Flame Katmanı)

#### A. 3 Kademeli Derinlik Modeli ve Görüş Açısı (Frontal Elevation)
- **Katman 1 (Ön Plan / Foreground - Priority 30):** Buzdolabı, kanepe, ağır jeneratör.
- **Katman 2 (Orta Plan / Midground - Priority 20):** Radyolar, kasalar, alet kutuları.
- **Katman 3 (Arka Plan / Raflar - Priority 10):** Mücevher kutuları, kilitli sandıklar.

#### B. Occlusion & ShadowMaskComponent
- Arka plandaki nesnelerin üzerine bir siluet maskesi çizilir (`Paint()..color = Colors.black.withOpacity(0.85)`).
- Öndeki nesne tıklandığında `RemoveEffect` ve `MoveEffect.to` ile ekrandan araca uçar.
- Ön nesne kalktığında tetiklenen olay (`onRaidItemRemoved`) arkadaki nesnenin `ShadowMaskComponent` bileşenine `OpacityEffect.to(0.0)` gönderir ve parlama parçacıkları (`ParticleSystemComponent`) patlatır.

#### C. Zaman Sayacı ve Ceza Matematiği
```dart
class RaidTimerComponent extends TimerComponent {
  RaidTimerComponent({required double period, required VoidCallback onFinish})
      : super(period: period, onTick: onFinish, removeOnFinish: true);
}
```
Ceza Formülü:
$$\text{Ceza Tutarı} = \sum_{i \in \text{KalanEşyalar}} \left(\text{BaseValue}_i \times 0.25\right)$$

---

### 🔹 FAZ 3 TEKNİK DETAYLARI: Araç Bagajı Grid Tetrisi

#### A. Bagaj Boyutları ve Araç Şablonları
- **Pikap (Pickup Truck):** $8 \times 12$ hücre (Maks. Taşıma: 350 kg).
- **Kamyonet (Small Van):** $12 \times 16$ hücre (Maks. Taşıma: 750 kg).
- **Kargo Kamyonu (Box Truck):** $16 \times 24$ hücre (Maks. Taşıma: 1800 kg).

#### B. Sürükle-Bırak Snap ve Önizleme
1. Ekrana dokunulan piksel koordinatı $(P_x, P_y)$, grid başlangıç noktası ve hücre boyutuna ($CellSize$) bölünerek grid indeksine çevrilir:
   $$Grid_X = \lfloor (P_x - Origin_X) / CellSize \rfloor, \quad Grid_Y = \lfloor (P_y - Origin_Y) / CellSize \rfloor$$
2. Anlık olarak `BitboardEngine.canPlace(...)` kontrol edilir.
3. Geçerli ise yeşil yarı-şeffaf kılavuz (`Colors.green.withOpacity(0.4)`), çakışma varsa kırmızı kılavuz çizilir.
4. Bırakıldığında bit maskesi `gridRows[r] |= shiftedMask` ile kalıcı olarak işlenir.

---

### 🔹 FAZ 4 TEKNİK DETAYLARI: Ekonomi, İhale ve Zanaat

#### A. İhale (Açık Artırma) Poisson Bot Yapay Zekası
Depo kapağı aralandığında her bot, içeride görünen ipuçları üzerinden tahmini bir değer ($\hat{V}_{bot}$) üretir:
$$Bid_{bot} = CurrentBid + \min\left(Step, (\hat{V}_{bot} - CurrentBid) \times AgressionFactor\right)$$
- Botlar $CurrentBid > \hat{V}_{bot} \times 1.15$ olduğu anda ihaleyi terk eder (Fold).

#### B. Pazar Yeri Satış Süresi Algoritması
Oyuncu eşyayı istediği fiyata pazar yerine koyabilir; ancak fiyat yükseldikçe satılma süresi üstel olarak artar:
$$T_{satış} = T_{base} \times \left(\frac{ListingPrice}{MarketValue}\right)^{2.5}$$
*Örnek:* Market değeri 100 ₺ olan eşya 100 ₺'ye konursa 60 saniyede satılır; 200 ₺'ye konursa $60 \times 2^{2.5} \approx 340$ saniyede satılır.

#### C. Tezgah Durum Makinesi
- **Ultrasonik Temizleme:** Hurda (0.2x) $\rightarrow$ Kötü (0.5x) $\rightarrow$ İyi (1.0x).
- **Hassas Onarım:** İyi (1.0x) $\rightarrow$ Mükemmel (1.5x).
- **Mistik Dönüştürücü:** 2 Mükemmel Eşya + Mistik Taş $\rightarrow$ 1 Mistik Eşya (2.5x).

---

### 🔹 FAZ 5 TEKNİK DETAYLARI: Zindan ve Sefer Sistemi (Taskbar Hero / Idle Expedition)

#### A. Sefer Gönderme ve Zamanlayıcı Mekaniği
Oyuncu dükkan deposundan seçtiği eşyaları (Zırh, Silah, Tılsım) kiraladığı askere kuşandırır ve bir zindana sefere gönderir:
- **Sefer Süresi:** Zindanın zorluğuna göre 5 dk, 15 dk, 1 saat gibi süreler.
- **Karakter Güç Skoru:** $\text{GucSkoru} = \sum (\text{EsyaBaseValue} \times \text{KondisyonCarpani})$.
- **Kazanma Şansı:**
  $$P_{zafer} = \min\left(0.95, \max\left(0.10, \frac{\text{GucSkoru}}{\text{ZindanZorlugu} \times 1.5}\right)\right)$$

#### B. Sefer Sonuç Raporu ve Ganimetler (Discrete-Time Çözümleme)
Arka planda ağır işlemci yükü veya GameLoop çalıştırılmaz. Oyuncu oyuna girdiğinde veya süre dolduğunda:
- **Başarı Durumu:** Rastgele 1-3 adet yüksek kondisyonlu nadir eşya, altın ve itibar puanı kazanılır.
- **Başarısızlık Durumu:** Asker yaralı döner, kuşanılan eşyalar %30 kondisyon kaybı (hasar) alır, daha az teselli ganimeti gelir.
- **Görsel Sunum:** Sade ve şık bir "Sefer Günlüğü / Rapor Kartı" (Taskbar Hero mantığı).

---

## 3. STATE VE VERİ AKIŞI: JANK-FREE DUAL-CHANNEL KÖPRÜSÜ

Flame oyun döngüsü saniyede 60-120 kez render alırken, Flutter UI ağacının gereksiz yere rebuild edilmesi ciddi takılmalara (jank) yol açar. Bu mimaride iki bağımsız kanal kullanılır:

```
[FLAME GAME LOOP (60-120 FPS)]
      │
      ├─► [YÜKSEK FREKANSLI KANAL: ValueNotifier<T>]
      │         │ (Saniyede 60 kez tetiklenir)
      │         ▼
      │   [Flutter ValueListenableBuilder]
      │   (SADECE sayaç ve can barı gibi mikro widgetler çizilir)
      │
      └─► [DÜŞÜK FREKANSLI KANAL: Stream / Event Köprüsü]
                │ (Eşya alındı, depo bitti, zindan zaferi)
                ▼
          [Riverpod StateNotifier]
                ▼
          [Isar NoSQL Database (Kalıcı Saklama)]
```

---

## 4. GÖRSEL ZEKA, ANTİ-AI TASARIM SİSTEMİ VE DİEGETİK MİMARİ

Oyunun standart bir "koyu modlu mobil uygulama" gibi hissettirmesini engellemek için kurulan görsel mimari:

### 4.1. Tipografi Mimarisi (`GameTypography`)
- **Display / Başlık Fontu:** `GoogleFonts.russoOne()` — Ağır endüstriyel damga fontu.
- **Data / LED Sayaç Fontu:** `GoogleFonts.orbitron()` (`tabularFigures` ile janksiz dijital sayaç/fiyat).
- **Gövde / Teknik Fontu:** `GoogleFonts.rajdhani()` — Okunabilir endüstriyel gövde metinleri.

### 4.2. Diegetik ve Yarı-Diegetik Bileşenler (`lib/core/widgets/`)
- `DiegeticMetalPanel`: 3D Bevel metalik üst/alt eğim, köşe perçinleri (`rivets`) ve neon bloom gölgesi.
- `RetroLedDisplay`: 7-Segment / neon parıltılı sayaç, para ve skorbord kutusu.
- `HazardStripeBanner`: CustomPainter ile çizilen $45^\circ$ endüstriyel sarı-siyah ikaz şeritleri.
- `AuctionStamp`: $12^\circ$ açılı, elastik iniş animasyonlu resmi "SATILDI", "KÂRLI" ve "ZARAR" kaşe damgası.
- `GameScreenShake`: Tokmak inişlerinde, ağır eşya yerleşimlerinde ve geri sayım sonlarında sarsıntı denetleyicisi.
- `ArcadeButton`: 5px mekanik basılma derinliği, dokunsal haptik titreşim ve 3D gölgeli konsol butonu.


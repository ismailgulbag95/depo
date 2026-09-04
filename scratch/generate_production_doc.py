import sys
import os

# Include helper
sys.path.append(os.path.dirname(__file__))
from docx_builder import create_docx

sections = []

def h1(t): sections.append(('h1', t))
def h2(t): sections.append(('h2', t))
def h3(t): sections.append(('h3', t))
def p(t): sections.append(('p', t))
def b(t): sections.append(('bullet', t))
def callout(title, text): sections.append(('callout', title, text))
def code(c): sections.append(('code', c))
def table(headers, rows): sections.append(('table', headers, rows))

# --- BÖLÜM 1 ---
h1("1. YÖNETİCİ ÖZETİ VE REORGANİZASYON KARARLARI")
p("Bu doküman; Flutter ve Flame oyun motorunun hibrit gücünü kullanarak geliştirilen 'Hibrit Simülasyon, Envanter Yönetimi ve RPG Oyunu' projesinin tüm mimari, matematiksel ve operasyonel üretim aşamalarını tanımlar.")

callout("MİMARİ REVİZYON VE OPTİMİZASYON (2.5D'DEN 2D'YE GEÇİŞ)", 
"Kullanıcı talebi ve üretim maliyeti optimizasyonu doğrultusunda, Blender ve 3D yazılımlarında haftalar sürecek izometrik 3D modelleme/render süreçleri tamamen iptal edilmiştir. Oyunun hiçbir yerinde pixel art KULLANILMAYACAK; bunun yerine modern yapay zeka (AI) ve stüdyo render tabanlı fotogerçekçi/yarı-gerçekçi 2D High-Resolution WebP varlıklar ve katmanlı 'Storage Wars' derinlik sistemi kullanılacaktır.")

h2("1.1. Neden 2.5D İzometrikten Saf 2D'ye Geçildi?")
table(
    ["Kriter", "2.5D İzometrik Yaklaşım (Eski)", "Fotogerçekçi 2D Katmanlı Yaklaşım (YENİ - OPTİMAL)"],
    [
        ["Üretim Süresi", "Her eşya için 3D modelleme, doku giydirme ve 30° render: 4-6 hafta", "AI stüdyo pipeline + rembg ile günde 50-100 adet ultra gerçekçi 2D WebP: 2-3 gün"],
        ["Matematik & Fizik", "Karmaşık izometrik projeksiyon ve derinlik matrisleri", "Hızlı ve kararlı 2D Kartezyen (X, Y) koordinatları ve katman sıralaması (Z-Order)"],
        ["Mobil Performans", "GPU üzerinde yoğun sprite batching ve derinlik hesaplama", "Hafif GPU/CPU yükü, 60-120 FPS sabit akıcılık, sıfır aşırı ısınma"],
        ["Görsel Kalite", "Düşük poligonlu modellerde çapaklanma riski", "Stüdyo ışıklandırmalı, 1024x1024 çözünürlükten optimize edilmiş keskin 2D gerçekçilik"],
        ["Geliştirme Hızı", "Çok yavaş ve tek kişilik geliştirici için aşırı yıpratıcı", "Hızlı prototipleme, anında test edilebilirlik ve yüksek modülerlik"]
    ]
)

# --- BÖLÜM 2 ---
h1("2. YENİ GÖRSEL DİL VE 2D VARLIK ÜRETİM PİPELİNE'I")
p("Projenin temel kuralı korunmaktadır: Kesinlikle pixel art olmayacaktır. Depo içi eşyalarda ve envanterde gerçekçilik hissi esastır.")

h2("2.1. Tavsiye Edilen 2D Fotogerçekçi Varlık Pipeline'ı (AI Destekli Stüdyo İş Akışı)")
p("Blender modellemesi yerine aşağıdaki 3 aşamalı süper hızlı boru hattı (pipeline) uygulanır:")
b("Aşama 1 (AI Görsel Üretimi): Midjourney v6, Flux.1 veya Stable Diffusion kullanılarak özel prompt şablonlarıyla eşyalar üretilir. Örnek Prompt: 'vintage oscilloscope, photorealistic, cinematic studio lighting, front view, pure white background, 8k resolution, product photography --v 6.0'")
b("Aşama 2 (Toplu Arka Plan Temizleme): Açık kaynaklı Python 'rembg' (BiRefNet kütüphanesi) ile yüzlerce üretilen görsel tek bir terminal komutuyla transparan arka plana dönüştürülür.")
b("Aşama 3 (WebP Dönüşümü ve Atlaslama): Transparan PNG'ler Flutter ve Flame için kayıpsız (lossless) WebP formatına sıkıştırılır. Bellek tüketimi %75 oranında düşer.")

h2("2.2. 'Storage Wars' Katmanlı 2D Depo Derinlik Modeli")
p("2.5D izometrik derinlik engeli yerine, gerçek depo açık artırmalarındaki kepenk açılma bakış açısı (Frontal Elevation View) kullanılır:")
b("Katman 1 (Ön Plan - Foreground): Büyük ve ağır nesneler (Eski buzdolabı, paslı jeneratör, yırtık brandalı kanepe). Bu nesneler arka taraftaki alanı fiziki olarak perdeler.")
b("Katman 2 (Orta Plan - Midground): Orta boy sandıklar, alet çantaları, antika radyolar, televizyonlar.")
b("Katman 3 (Arka Plan - Background / Raflar): Değerli kasalar, gizli parşömenler, mistik parıltılı kutular.")
p("Oyuncu öndeki 2D eşyayı tıkladığında eşya animasyonla araca uçar; arkadaki katmanda yer alan nesnelerin üzerindeki gölge (Shadow Mask) kalkar ve yeni eşya parıldayarak açığa çıkar.")

# --- BÖLÜM 3 ---
h1("3. SİSTEM MİMARİSİ VE TEKNOLOJİ YIĞINI")
table(
    ["Bileşen", "Teknoloji", "Mimari Rolü ve Tercih Nedeni"],
    [
        ["Kullanıcı Arayüzü (UI)", "Saf Flutter (Widgets)", "Açık artırma, Pazar yeri, Tezgahlar, İtem ağacı, AFK zindan panelleri"],
        ["Oyun Motoru", "Flame Engine (v1.38+)", "Depo ekranı (2D Katmanlı), Bagaj Tetrisi (Grid), Manuel Zindan (Top-down 2D)"],
        ["Hibrit Köprü", "GameWidget.overlayBuilderMap", "Flame canvas üzerine saf Flutter HUD (sayaç, can barı, ceza paneli) bindirme"],
        ["Durum Yönetimi", "flutter_riverpod (v2.6+)", "Global ekonomi, envanter, tezgah durumları ve olay tabanlı haberleşme"],
        ["Veri Modelleri", "freezed + json_serializable", "Immutable, deep-copy destekli tip güvenli veri yapıları"],
        ["Yerel Veritabanı", "ISAR Database (v3.1+)", "ACID uyumlu, NoSQL, multi-isolate destekli ultra hızlı kalıcı veri katmanı"],
        ["Hafif Ayarlar DB", "Hive (v2.2+)", "Kullanıcı ses ayarı, dil seçimi ve ufak konfigürasyon anahtarları"],
        ["Görsel Format", "Lossless 2D WebP", "Foto-gerçekçi, stüdyo ışıklandırmalı yüksek çözünürlüklü 2D spritelar"]
    ]
)

h2("3.1. Proje Klasör Yapısı (Feature-First Mimari)")
code("""lib/
├── main.dart                               # App Entrypoint, ProviderScope, Isar Init
├── core/                                   # Çekirdek Altyapı
│   ├── constants/                          # Oyun sabitleri (Grid boyutları, renkler, tagler)
│   ├── database/                           # Isar DB singleton, koleksiyon şemaları
│   │   ├── isar_service.dart
│   │   └── schemas/
│   ├── theme/                              # Modern karanlık UI tema tanımları
│   ├── utils/                              # Bitboard yardımcıları, matematik formülleri
│   └── bridge/                             # Flame <-> Riverpod haberleşme arayüzleri
│
├── features/                               # Feature-First Modülleri
│   ├── auction/                            # 1. Açık Artırma & Bölgesel Kilitler (Flutter)
│   │   ├── data/                           # AuctionRepository, BotBidEngine
│   │   ├── domain/                         # AuctionLot, WarehouseRegion (Freezed)
│   │   └── presentation/                   # AuctionHallScreen, BidDialog
│   │
│   ├── storage_raid/                       # 2. Depo Yağmalama (Flame + Flutter HUD)
│   │   ├── flame/                          # 2D Katmanlı Depo GameLoop
│   │   │   ├── storage_raid_game.dart
│   │   │   ├── components/                 # LayeredItemComponent, ShadowMaskComponent
│   │   │   └── controllers/                # RaidInteractionSink
│   │   ├── domain/                         # DepoItem, LayerDepthEnum
│   │   └── presentation/                   # Overlay HUD (RaidTimer, PenaltyNotice)
│   │
│   ├── trunk_tetris/                       # 3. Araç Bagajı Grid Tetrisi (Flame + Flutter HUD)
│   │   ├── flame/                          # 2D Bitboard Grid Motoru
│   │   │   ├── trunk_tetris_game.dart
│   │   │   ├── components/                 # Polyomino2DComponent, GridCellComponent
│   │   │   └── logic/                      # BitboardPackingValidator, Rotator
│   │   ├── domain/                         # TrunkSpec, ItemShapeMatrix
│   │   └── presentation/                   # CapacityBarOverlay, PenaltyWarning
│   │
│   ├── marketplace/                        # 4. Pazar Yeri & Hurdacı (Saf Flutter)
│   │   ├── data/                           # MarketplaceRepository
│   │   ├── domain/                         # WebListing, ScrapQuote
│   │   └── presentation/                   # WebShopScreen, ScrapDealerInstantCashSheet
│   │
│   ├── crafting_benches/                   # 5. Tezgahlar & Onarım (Saf Flutter)
│   │   ├── data/                           # BenchRepository
│   │   ├── domain/                         # BenchStation, CraftRecipe, ConditionGrade
│   │   └── presentation/                   # UltrasonicCleanerScreen, RepairBenchScreen
│   │
│   ├── item_tree/                          # 6. Beş Ana İtem Ağacı (Saf Flutter)
│   │   ├── domain/                         # ItemTreeGraph, ItemTypeEnums, ItemStats
│   │   └── presentation/                   # InteractiveTreeViewer, ItemInspectionModal
│   │
│   └── dungeon/                            # 7. Zindan ve Savaş Modülü (Hibrit)
│       ├── afk_farm/                       # Pasif Savaş (Saf Flutter + Isar)
│       │   ├── logic/                      # DiscreteTimeSimulator, MercenarySurvivalMath
│       │   └── presentation/               # MercenaryHiringScreen, AFKProgressPanel
│       └── manual_combat/                  # Aktif Savaş (Flame Motoru)
│           ├── flame/
│           │   ├── dungeon_combat_game.dart# Top-Down 2D Hack & Slash Game
│           │   ├── components/             # HeroComponent, EnemyMonster, SpellHitbox
│           │   └── systems/                # CollisionResolution, MonsterFSM_AI
│           └── presentation/               # OVERLAY HUD (Joystick, SkillPad)""")

# --- BÖLÜM 4 ---
h1("4. STATE VE VERİ AKIŞI MİMARİSİ (FLAME <-> RIVERPOD KÖPRÜSÜ)")

callout("60 FPS JANK/KASMA ÖNLEYİCİ MİMARİ KURAL", 
"Flame motorunun update(dt) döngüsü saniyede 60-120 kez çalışır. Her frame'de Riverpod Notifier'a yazmak Flutter Widget ağacını saniyede 60 kez baştan inşa etmeye zorlar. Bu yüzden İKİ KANALLI (DUAL-CHANNEL) SENKRONİZASYON MODELİ zorunludur.")

h2("4.1. İki Kanallı Senkronizasyon Modeli")
p("1. Yüksek Frekanslı Kanal (Can, Sayaç, Enerji): Flame Game içinde ValueNotifier<T> tutulur. Flutter Overlay tarafında ValueListenableBuilder ile SADECE İLGİLİ MİKRO WIDGET çizilir. Bütün ekran asla rebuild edilmez.")
p("2. Düşük Frekanslı / Olay Tabanlı Kanal (Eşya Alındı, Zindan Bitti): Oyuncu bir eşyayı araca yerleştirdiğinde tek bir event tetiklenir: ref.read(inventoryControllerProvider.notifier).addItemToTrunk(item). Isar veritabanına async olarak yazılır.")

code("""// Flame Game Sınıfı
class StorageRaidGame extends FlameGame {
  final WidgetRef ref;
  final ValueNotifier<double> remainingTimeNotifier = ValueNotifier(60.0);
  final ValueNotifier<int> penaltyCashNotifier = ValueNotifier(0);

  StorageRaidGame({required this.ref});

  @override
  void update(double dt) {
    super.update(dt);
    if (remainingTimeNotifier.value > 0) {
      remainingTimeNotifier.value = (remainingTimeNotifier.value - dt).clamp(0.0, 60.0);
    }
  }

  void onItemLooted(GameItem item) {
    // Düşük frekanslı Riverpod olayı
    ref.read(inventoryProvider.notifier).transferItem(item);
  }
}""")

# --- BÖLÜM 5 ---
h1("5. MODÜL MODÜL ALGORİTMALAR VE MATEMATİKSEL MODELLER")

h2("5.1. Bagaj Tetrisi: 64-Bit Bitboard Çarpışma Algoritması")
p("Her araç bagajı satırları tamsayı olan bir bitboard matrisi ile yönetilir. Çarpışma denetimi O(1) sürede bit düzeyinde gerçekleştirilir:")
code("""class TrunkBitboard {
  final List<int> rows = List.filled(16, 0); // 16 satır

  bool canPlace(List<int> itemShapeMask, int startX, int startY) {
    for (int i = 0; i < itemShapeMask.length; i++) {
      final shifted = itemShapeMask[i] << startX;
      if ((rows[startY + i] & shifted) != 0) return false; // Çakışma!
    }
    return true;
  }

  void place(List<int> itemShapeMask, int startX, int startY) {
    for (int i = 0; i < itemShapeMask.length; i++) {
      rows[startY + i] |= (itemShapeMask[i] << startX);
    }
  }
}""")

h2("5.2. İhale ve Açık Artırma: Poisson Dağılımlı Bot Teklif Fonksiyonu")
p("Depo ihalelerinde botlar Poisson dağılımı ve tahmini değer formülüyle teklif artırır:")
b("Tahmin Değeri: V_bot = GorunenDeger * RastgeleCarpici(0.85, 1.30)")
b("Teklif Artırma: YeniTeklif = GuncelTeklif + min(Adim, (V_bot - GuncelTeklif) * SaldirganlikFaktoru)")
b("Çekilme Kriteri: GuncelTeklif > V_bot * 1.15 olduğunda bot ihaleyi terk eder.")

h2("5.3. Pazar Yeri Satış Süresi: Ters Üstel Dağılım Modeli")
p("Hurdacıya anında satış (Nakit = BaseValue * 0.20 * Kondisyon) anlık likidite sağlar. Pazar yerinde listeleme süresi ise fiyat oranına göre ters üstel olarak artar:")
b("SatisSuresi = BazSure * (ListelemeFiyati / PiyasaDegeri)^2.5")

h2("5.4. AFK Zindan Simülasyonu: Discrete-Time Battle Math")
p("Oyun kapalıyken Flame GameLoop çalışmaz. Oyuncu oyunu açtığında son zaman damgası farkı üzerinden matematiksel simülasyon işletilir:")
b("GecenSure = SimdikiZaman - SonAktifZaman")
b("NetHasar = SaldiranDPS * (1 - (SavunanZirh / (SavunanZirh + 100)))")
b("OdaGecisSuresi = CanavarCan / NetKarakterDPS")
b("AlinanHasar = OdaGecisSuresi * NetCanavarDPS")
b("Karakter Canı <= 0 olursa: Kiralık asker bedeli yanar, eşyalar %30 dayanıklılık kaybeder, ganimet sıfırlanır.")

# --- BÖLÜM 6 ---
h1("6. ADIM ADIM ÜRETİM PLANI VE ROADMAP (FAZ 1 - FAZ 5)")

h2("FAZ 1: Temel Veri Katmanı, Isar Veritabanı ve Matematik Motoru")
b("Adım 1.1: Freezed ve JsonSerializable ile GameItem, ItemStats, TrunkSpec modellerinin kodlanması.")
b("Adım 1.2: Isar veritabanı şemalarının (PlayerAccount, InventoryEntity) oluşturulması ve build_runner ile derlenmesi.")
b("Adım 1.3: BitboardPackingValidator sınıfının yazılması ve birim testlerinin (Unit Test) yapılması.")
b("Adım 1.4: 2D AI görsel pipeline'ının kurulması (Prompt şablonları + rembg arka plan temizleme otomasyonu).")

h2("FAZ 2: 2D Katmanlı Depo Yağmalama Motoru (Flame Katmanı)")
b("Adım 2.1: StorageRaidGame sınıfının kurulması ve 2D kamera projeksiyonunun ayarlanması.")
b("Adım 2.2: 3 Katmanlı derinlik sisteminin (Ön, Orta, Arka Plan) ve gölge maskelemesinin kodlanması.")
b("Adım 2.3: Eşya tıklama ve dependency graph ile arkadaki eşyaların kilidinin açılması mekaniğinin yazılması.")
b("Adım 2.4: ValueNotifier köprüsüyle RaidTimerHUD ve PenaltyCounter Flutter overlay'lerinin bağlanması.")

h2("FAZ 3: Araç Bagajı Grid Tetrisi & Hibrit Köprü")
b("Adım 3.1: TrunkTetrisGame bileşeninin ve dokunmatik sürükle-bırak (Drag & Drop) sisteminin kurulması.")
b("Adım 3.2: 2D eşya sprite'larının 90 derece döndürme ve hücreye snap mekanizmasının kodlanması.")
b("Adım 3.3: Bitboard ile anlık yeşil/kırmızı çakışma geri bildiriminin entegrasyonu.")
b("Adım 3.4: Depodan araca eşya transferi ve sığmayan eşyalar için ceza faturasının Riverpod cüzdanına yansıtılması.")

h2("FAZ 4: Ekonomi, İhale, Pazar Yeri ve Tezgahlar (Saf Flutter)")
b("Adım 4.1: Bölgesel kilitli açık artırma ekranı ve yapay zeka bot teklif simülasyonunun geliştirilmesi.")
b("Adım 4.2: Hurdacıya anında toptan satış ve oyun içi web sitesi tekli satış sisteminin inşası.")
b("Adım 4.3: Ultrasonik temizleme ve mekanik onarım tezgahı ekranlarının (Kötü -> İyi -> Mükemmel) kodlanması.")
b("Adım 4.4: Beş ana kategori (Hurda, Antika, Zanaat, Mistik, Melez) interaktif eşya ağacı ekranının tamamlanması.")

h2("FAZ 5: Zindan Sistemi (AFK Simülasyonu + Aktif Savaş) ve Son Cila")
b("Adım 5.1: Discrete-Time AFK zindan hesaplama algoritmasının Isar arka plan servisine bağlanması.")
b("Adım 5.2: Flame motoru üzerinde 2D Top-Down manuel aksiyon zindanının (Hero, Joystick, Monster FSM, Hitbox) kurulması.")
b("Adım 5.3: Çanta kapasitesi kısıtı ve gündüz ekonomisine ganimet aktarım köprüsünün tamamlanması.")
b("Adım 5.4: Performans profillemesi, bellek optimizasyonu ve yayın öncesi uçtan uca kabul testleri.")

# Create docx
output_path = r"d:\github\depo\docs\Hibrit_Simulasyon_RPG_Uretim_Dokumani.docx"
create_docx(output_path, "HİBRİT SİMÜLASYON, ENVANTER YÖNETİMİ VE RPG OYUNU", sections)
print(f"BAŞARIYLA OLUŞTURULDU: {output_path}")

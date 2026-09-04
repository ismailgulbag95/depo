# ⚖️ MİMARİ VE STRATEJİK KARARLAR (DECISIONS.md)

Bu doküman; projede alınan kritik mimari, teknik ve sanatsal kararları, bu kararların **gerekçelerini**, değerlendirilen alternatifleri ve doğurduğu sonuçları Architecture Decision Record (ADR) formatında kayıt altına alır.

---

## 📑 Karar Özeti Tablosu

| ID | Karar Başlığı | Durum | Tarih | Etkilenen Alan |
| :--- | :--- | :--- | :--- | :--- |
| **ADR-001** | 2.5D İzometrikten 2D Katmanlı Mimariye Geçiş | Kabul Edildi | 2026-09-01 | Grafik, Motor, Süreç |
| **ADR-002** | Pixel Art Reddi ve Stüdyo Gerçekçiliği Tercihi | Kabul Edildi | 2026-09-01 | Sanat Tarzı, UI/UX |
| **ADR-003** | 64-Bit Bitboard ile O(1) Grid Çarpışma Tespiti | Kabul Edildi | 2026-09-01 | Matematik, Algoritma |
| **ADR-004** | Dual-Channel State Köprüsü (Jank Önleme) | Kabul Edildi | 2026-09-01 | Flame, Riverpod, UI |
| **ADR-005** | Isar Database & Hive Hibrit Veri Depolama | Kabul Edildi | 2026-09-01 | Veritabanı, Performans |
| **ADR-006** | AFK Simülasyonu + Aktif Flame Savaş Birlikteliği | Revize Edildi | 2026-09-02 | RPG, Oynanış Döngüsü |
| **ADR-007** | Python BiRefNet Destekli Otomatik Varlık Hattı | Kabul Edildi | 2026-09-02 | Pipeline, Varlık Üretimi |
| **ADR-008** | Zindan Modülünde Taskbar Hero / Pasif Keşif Tercihi | Kabul Edildi | 2026-09-02 | RPG, Zindan |
| **ADR-009** | Sabit Araç Şablonları + Modüler Raf Eklentileri Mimarisi | Kabul Edildi | 2026-09-02 | Bagaj, Grid |
| **ADR-010** | Dükkan Deposu İçin Slot/Kategori Raf Sistemi | Kabul Edildi | 2026-09-02 | Envanter, UX |
| **ADR-011** | 4 Dilli Mimari ve Çok Dilli Eşya Kataloğu (TR, EN, RU, ES) | Kabul Edildi | 2026-09-02 | i18n, Veritabanı |
| **ADR-012** | Çift Kanallı Depo Satışı (Yerinde İhale vs Web Sitesi) | Kabul Edildi | 2026-09-02 | Açık Artırma, Ekonomi |
| **ADR-013** | Yağma İçi Eşya Kararı ve Acil Nakliye Mekaniği | Kabul Edildi | 2026-09-02 | Raid, Bagaj, Lojistik |
| **ADR-014** | Dikey Hibrit Ekran ve Kademeli Gölge Modeli (%0/%75/%100) | Kabul Edildi | 2026-09-02 | UI/UX, Flame |
| **ADR-015** | Raid Sonu Resmî İhale ve Temizlik Fatura Raporu | Kabul Edildi | 2026-09-02 | Raid, Ekonomi, HUD |
| **ADR-016** | Isar'dan Evrensel HIVE (Pure Dart) Veri Katmanına Geçiş | Kabul Edildi | 2026-09-02 | Veritabanı, Web/Multiplatform |
| **ADR-017** | Canlı Amerikan Müzayede (Storage Wars) ve Hızlı Teklif Akışı | Kabul Edildi | 2026-09-02 | Açık Artırma, Atmosfer |
| **ADR-018** | İki Aşamalı Müzayede Akışı (15 sn Gözlem + 30 sn İhale) | Kabul Edildi | 2026-09-02 | Açık Artırma, Oynanış |
| **ADR-019** | Zemin Tabanlı Yuvalar ve Perspektif Ölçekleme Modeli | Kabul Edildi | 2026-09-02 | Flame, Sahne, Fizik |
| **ADR-020** | Endüstriyel Hurda & Arcade Dinamik Oyun HUD Tasarımı | Kabul Edildi | 2026-09-02 | UI/UX, Oyun Hissi |
| **ADR-021** | 276 Eşyalık Arketip Ağırlıklı Prosedürel Depo Üreticisi | Kabul Edildi | 2026-09-02 | Prosedürel, Ekonomi |
| **ADR-022** | Gerçekçi Endüstriyel Depo Arka Planı ve Işık Huzmesi | Kabul Edildi | 2026-09-02 | Görsel, Atmosfer |
| **ADR-023** | 90 Derece Döndürme (Arcade Buton + Çift Dokunma) | Kabul Edildi | 2026-09-02 | Bagaj, Tetris, Kontrol |
| **ADR-024** | Bagaj Eşyalarını Serbest Yeniden Düzenleme ve Taşıma | Kabul Edildi | 2026-09-02 | Bagaj, Envanter, UX |
| **ADR-025** | İstifçi / Lojistikçi XP ve İtibar Bonusu (%80+ Doluluk) | Kabul Edildi | 2026-09-02 | RPG, Seviye, Ödül |
| **ADR-026** | Holografik Yeşil/Kırmızı Anlık Hücre Snap Kılavuzu | Kabul Edildi | 2026-09-02 | Bitboard, Snap, Feedback |

---

## 📌 ADR-001: 2.5D İzometrik Yaklaşımdan Saf 2D Katmanlı Mimariye Geçiş

- **Bağlam:** İlk tasarım taslağında depoların ve araç bagajının Blender/3D yazılımlarında 30° izometrik açıyla modellenmesi ve 2.5D olarak çizdirilmesi planlanmıştı.
- **Değerlendirilen Alternatifler:**
  1. *3D Modelleme + 2.5D İzometrik Render:* Her eşya için 3D model, UV kaplama ve izometrik render.
  2. *Saf 2D Derinlikli Cephe Modeli (Frontal Elevation):* Storage Wars konseptine uygun olarak doğrudan cepheden 3 kademeli (Ön/Orta/Arka) katman sıralaması.
- **Gerekçe:**
  - Tek kişilik / çevik bir geliştirme sürecinde 100+ eşyayı 3D modellemek **4-6 hafta** sürecek devasa bir zaman kaybıydı.
  - İzometrik projeksiyon matematikte derinlik matrisleri ve sorting problemlerine yol açarak mobil GPU'yu zorluyordu.
  - Saf 2D katmanlı model sayesinde tüm depo varlık üretimi **2-3 güne** indi ve 60-120 FPS akıcılık garanti altına alındı.
- **Sonuç:** Depo ekranı cepheden 3 katmanlı olarak tasarlandı; izometrik render tamamen terk edildi.

---

## 📌 ADR-002: Pixel Art Reddi ve Stüdyo Gerçekçiliği Tercihi

- **Bağlam:** Bağımsız oyunlarda yaygın olarak piksel sanatı (pixel art) tercih edilmektedir.
- **Değerlendirilen Alternatifler:**
  1. *Pixel Art (16x16 / 32x32):* Klasik retro tarz.
  2. *High-Resolution 2D Fotogerçekçi / Yarı-Gerçekçi Stüdyo Render:* 1024x1024, stüdyo ışıklandırmalı, detaylı ve keskin görseller.
- **Gerekçe:**
  - Depo açma ve antika restorasyonu temasında (Storage Wars, Barn Finders) oyuncunun aradığı tatmin; pası, tozu, ahşap dokusunu ve altın parıltısını **gözleriyle net olarak görebilmesidir**.
  - Piksel sanatı bu dokuları ve restorasyon hissini aktarmada yetersiz kalmaktadır.
  - AI görüntü üretim modelleri (Midjourney / Flux.1), stüdyo ışığında fotogerçekçi izole ürün üretmede rakipsizdir.
- **Sonuç:** Projede kesin kural olarak pixel art kullanılmayacak; yüksek çözünürlüklü, stüdyo izole eşya görselleri kullanılacaktır.

---

## 📌 ADR-003: 64-Bit Bitboard ile O(1) Grid Çarpışma Tespiti

- **Bağlam:** Araç bagajı polyomino tetrisinde eşyaların üst üste binip binmediği ve sınırlara uyup uymadığı her sürükleme karesinde onlarca kez kontrol edilir.
- **Değerlendirilen Alternatifler:**
  1. *İki Boyutlu Dizi Döngüsü (`int[][]`):* Her kare için iç içe iki `for` döngüsü ($O(W \times H)$).
  2. *64-Bit Bitboard Maskeleme:* Her satırın bir tamsayı bit maskesi olarak tutulması ($O(1)$ bitwise AND).
- **Gerekçe:**
  - Dokunmatik ekranda 120 Hz yenileme hızında parmak kaydırılırken matris döngüleri gereksiz CPU yükü ve garbage collection oluşturur.
  - Bitboard sayesinde satır çakışması tek bir `(GridRow & ShiftedItemMask) == 0` işlemiyle anında hesaplanır.
  - $90^\circ$ döndürme işlemi de saf bit manipülasyonuyla mikrosaniyeler içinde gerçekleşir.
- **Sonuç:** Tüm grid ve polyomino mekaniği `BitboardEngine` üzerine kuruldu.

---

## 📌 ADR-004: Dual-Channel State Köprüsü (Flame $\leftrightarrow$ Flutter Jank Önleme)

- **Bağlam:** Flame oyun döngüsü 60-120 FPS çalışırken, HUD elemanları (kalan süre, toplanan değer) Flutter Widget'ları olarak çizilmektedir.
- **Değerlendirilen Alternatifler:**
  1. *Tüm Ekranı Riverpod Consumer ile Dinlemek:* Her frame'de state değiştiğinde tüm ekranın rebuild edilmesi.
  2. *Dual-Channel Ayrımı:* Yüksek frekanslı veriler için `ValueNotifier`, düşük frekanslı olaylar için Riverpod + Isar.
- **Gerekçe:**
  - Süre sayacı veya enerji her azaldığında Flutter widget ağacını baştan çizmek mobilde ciddi takılmalara (frame drop / jank) sebep olur.
  - `ValueListenableBuilder` ile **SADECE** ilgili küçük sayaç metni güncellenir.
  - Eşyanın envantere girmesi gibi kalıcı ve seyrek olaylar ise Riverpod üzerinden Isar'a asenkron yazılır.
- **Sonuç:** Sıfır-jank garantisi için Dual-Channel State mimarisi benimsendi.

---

## 📌 ADR-005: Isar Database & Hive Hibrit Veri Depolama

- **Bağlam:** Oyunda hem karmaşık ilişkisel sorgulara sahip yüzlerce eşya, hem de anlık okunması gereken basit ayarlar (ses, tema) bulunmaktadır.
- **Değerlendirilen Alternatifler:**
  1. *Sadece SQLite / sqflite:* Yavaş, manuel SQL yazımı gerektirir, tip güvenliği zayıftır.
  2. *Sadece SharedPreferences:* Büyük koleksiyonlar için uygunsuzdur.
  3. *Isar DB + Hive Hibrit:* Eşyalar ve oyuncu profili için ultra hızlı Isar NoSQL; ayarlar için hafif Hive.
- **Gerekçe:**
  - Isar, Flutter dünyasında ACID uyumlu, Dart modelleriyle doğrudan kod üreten ve sorguları C++ hızında koşan en modern veritabanıdır.
  - Hive ise ayarlar gibi tekil verileri kutu (box) mantığıyla anında bellekte tutar.
- **Sonuç:** İki kütüphane görevlerine göre ayrıştırılarak projeye dahil edildi.

---

## 📌 ADR-006: Zindan Modülünde AFK Simülasyonu ve Aktif Savaşın Birlikte Sunulması

- **Bağlam:** Oyuncuların bir kısmı sadece lojistik ve ticaret simülasyonunu severken, bir kısmı aksiyon ve RPG savaşını arzulamaktadır.
- **Değerlendirilen Alternatifler:**
  1. *Sadece Aktif Top-Down Savaş:* Zamanı kısıtlı simülasyon oyuncularını yorabilir.
  2. *Sadece AFK Metin Simülasyonu:* Aksiyon arayan kitleye sönük kalabilir.
  3. *Hibrit (İsteğe Bağlı):* Ana ilerleme için hızlı/arka plan AFK simülasyonu; nadir hazineler ve boss dövüşleri için Flame tabanlı aktif savaş.
- **Gerekçe:**
  - Oyuncu vaktine saygı duyan ve her iki oyuncu personasını da tatmin eden en dengeli modeldir.
  - Cihaz kapalıyken bile askerler ganimet getirmeye devam eder, oyuncu istediği an direksiyonu eline alabilir.
- **Sonuç:** Zindan modülü çift modlu (AFK Simülatörü + Aktif Flame Sahnesi) olarak kurgulandı.

---

## 📌 ADR-007: Python BiRefNet (rembg) Destekli Otomatik Varlık Hattı

- **Bağlam:** Yapay zeka ile üretilen eşyaların arka planında stüdyo ışığı ve beyaz/gri geçişler kalmakta; manuel silme saatler almaktadır.
- **Değerlendirilen Alternatifler:**
  1. *Photoshop ile Manuel Dekupe:* Eşya başına 5-10 dakika mesai.
  2. *Python `rembg` (BiRefNet Modeli) + Otomatik Alpha Kırpma:* Saniyeler içinde kayıpsız WebP çıktısı.
- **Gerekçe:**
  - BiRefNet, kenar kıvrımlarını ve şeffaf cam/metal yansımalarını dahi %99.8 doğrulukla arka plandan ayırır.
  - `tools/` altına yazılan betikler sayesinde toplu klasör taraması tek komutla (`run_pipeline.bat`) çalışmaktadır.
- **Sonuç:** Varlık üretim hattı tamamen yerel Python otomasyonuna bağlandı.

---

## 📌 ADR-008: Zindan Modülünde Taskbar Hero / Pasif Keşif Modeli Tercihi

- **Bağlam:** Zindan modülünün aktif bir Flame top-down joystick savaşı mı yoksa arka plan pasif keşif simülasyonu mu olacağı değerlendirildi.
- **Karar:** Aktif top-down joystick savaş sahnesi **iptal edildi**. Karakterin eşyaları kuşanıp zindana gönderildiği, oyuncunun beklemede kaldığı ve dönüşte sadece "Başarılı / Başarısız" sonucu ile kazanılan ganimet raporunun sunulduğu **Taskbar Hero / Idle Expedition** mantığı benimsendi.
- **Gerekçe:**
  - Ana oyun odağı depo avcılığı, polyomino bagaj bulmacası ve restorasyondur. Aktif savaş eklemek oyunun ana kimliğini dağıtmaktaydı.
  - Mobil simülasyon oyuncuları uzun soluklu manuel savaşlar yerine, taktiksel kuşanma ve pasif getiri mekaniklerini daha çok tercih etmektedir.
  - Geliştirme süresini haftalarca kısaltarak Faz 1-4 arasındaki ana halkaların kusursuzlaştırılmasına imkan tanır.
- **Sonuç:** Faz 5 zindan sistemi tamamen Flutter UI + Isar zamanlayıcı tabanlı pasif sefer simülasyonu olarak kurgulanacaktır.

---

## 📌 ADR-009: Sabit Araç Şablonları + Modüler Raf Eklentileri Mimarisi

- **Bağlam:** Araç bagajının boyutlandırılması ve genişletilme mekaniği belirlendi.
- **Karar:** Pikap ($8 \times 12$), Kamyonet ($12 \times 16$) ve Kargo Kamyonu ($16 \times 24$) gibi sabit araç şablonları temel alınacak; ancak sistem sonradan satın alınabilen modüler bagaj eklentilerine (ekstra yan sepet, tavan çıtası, katlanabilir raf) imkan tanıyacak şekilde esnek bir `BitboardGrid` mimarisiyle kodlanacaktır.
- **Gerekçe:**
  - Araç sınıfı atlama hissi gerçekçidir ve güçlü bir ilerleme hedefi sunar.
  - Modüler eklenti altyapısı ise oyuncuya kişiselleştirme ve mikro-iyileştirme alanı açar.
- **Sonuç:** Temel araç boyutları şablon olarak kodlanacak, ızgara motoru dinamik aktif alan maskesini destekleyecektir.

---

## 📌 ADR-010: Dükkan / Garaj Deposu İçin Slot ve Kategori Raf Sistemi

- **Bağlam:** Oyuncunun araç bagajından indirdiği veya biriktirdiği eşyaları nerede ve nasıl saklayacağı kararlaştırıldı.
- **Karar:** Oyuncunun dükkanında sabit bir depolama alanı (Stash / Warehouse) bulunacak; ancak bu alan bir grid değil, **genişletilebilir slotlar ve kategorili raf sistemi** olacaktır.
- **Gerekçe:**
  - Polyomino yerleştirme bulmacası araç bagajına özel kaldığında yüksek tatmin sağlar; her eşya taşındığında sürekli tetris oynamak oyuncuyu yorar ve envanter yönetimini bürokratik bir çileye dönüştürür.
  - Dükkanda slotlu veya kategorili (Aletler, Antikalar, Silahlar vb.) hızlı erişim, tezgahta tamir ve pazar yeri satışı işlemlerini akıcı kılar.
- **Sonuç:** Garaj/Dükkan deposu slotlu raf modeliyle modellenecektir.

---

## 📌 ADR-011: Dört Dilli Mimari ve Çok Dilli Eşya Kataloğu (TR, EN, RU, ES)

- **Bağlam:** Oyunun küresel pazara çıkışı için Türkçe, İngilizce, Rusça ve İspanyolca dillerinin veritabanı şeması derlenmeden önce eklenmesi talep edildi.
- **Karar:**
  1. `ItemModel` Isar şemasına 4 dilde ad alanları (`nameTr`, `nameEn`, `nameRu`, `nameEs`) doğrudan eklendi.
  2. Arayüz için `assets/lang/` altında hafif, JSON tabanlı `tr.json`, `en.json`, `ru.json`, `es.json` dosyaları ve `LocalizationService` kuruldu.
  3. Dil tercihi `Hive` içine kaydedilerek kalıcı hale getirildi.
- **Gerekçe:**
  - `build_runner` çalıştırılmadan önce bu alanların şemaya eklenmesi, gelecekteki olası Isar veritabanı migrasyon krizlerini baştan önlemiştir.
  - Bağımsız JSON tabanlı servis, Flutter'ın ağır yerelleştirme paketlerine ihtiyaç duymadan Flame ve Flutter katmanında ultra hızlı çalışır.
- **Sonuç:** Oyun ilk günden 4 dilde tam yerelleştirilmiş olarak çalışmaktadır.

---

## 📌 ADR-012: Çift Kanallı Depo Satışı (Yerinde İhale vs Web Sitesi İlanı)

- **Bağlam:** Oyuncunun depolara nasıl erişeceği ve açık artırma deneyimi kurgulandı.
- **Karar:** İki farklı depo edinim kanalı modellendi:
  1. *Yerinde Canlı Satış (On-Site Live Auction):* Oyuncu tesise gider, kepenk 5 saniyeliğine aralanır, oyuncu ön plandaki ipuçlarına bakarak anlık canlı teklif verir.
  2. *Web Sitesi Açık Artırması (Online Storage Auction):* Oyuncu ofisindeki bilgisayardan ilanlara bakar; ilanlarda karşıdan çekilmiş fotoğraf, ebatlar ve tahmini koli sayısı yer alır. Botlar da teklif verir; oyuncu teklifini takip eder ve süre sonunda kazanan depoyu yağmalamaya gider.
- **Gerekçe:**
  - Gerçek Amerikan kiralık depo (Self-Storage) kültürünü birebir yansıtır.
  - Oyuncuya hem anlık aksiyon (Yerinde İhale) hem de stratejik zaman yönetimi (Web Sitesi İhalesi) sunarak derinlik katar.
- **Sonuç:** `StorageUnitModel` içinde `auctionType` ve online süre takip alanları yapılandırıldı.

---

## 📌 ADR-013: Yağma İçi Eşya Kararı ve Acil Nakliye Mekaniği (Hurda vs Araç & Çekici Çağrı)

- **Bağlam:** Yağmalama (Faz 2) ile Araç Bagajı Grid Tetrisi (Faz 3) arasındaki geçiş ve kapasite doluluğu kurgulandı.
- **Karar:**
  1. Depoda bir eşyaya tıklandığında eşya öne gelir ve oyuncuya 2 seçenek sunulur: **"HURDA"** ve **"ARAÇ"**.
  2. "HURDA" seçilirse eşya anında hurdaya ayrılır (toplam değerin %20'si hesaplanır ancak tekil fiyat gizlenir, raid sonunda toplu gelir olarak verilir).
  3. "ARAÇ" seçilirse eşya anında araç bagaj ızgarasına sürüklenip yerleştirilir.
  4. Bagaj dolduğunda oyuncu ekrandaki **"Nakliye Çağır"** butonu ile anında ücretli bir ek araç çağırabilir. Bu servis maliyetli tutularak oyuncu kendi ana aracını yükseltmeye teşvik edilir.
  5. Süre bittiğinde yerleştirilemeyen son eşya araçta boşluk varsa otomatik oturur, yoksa hurdaya gider.
- **Gerekçe:**
  - Depo yağmalama ile bagaj yerleşimini birbirinden kopuk iki ayrı menü olmaktan çıkarıp, anlık karar ve adrenalin dolu akıcı tek bir oynanış halkasına dönüştürür.
  - Oyuncuyu taktiksel risk almaya (Hurda mı yapayım, bagaja mı sığdırayım, ek nakliye mi çağırayım?) zorlar.
- **Sonuç:** Faz 2 ve Faz 3 birleşik interaktif bir mekanik olarak mimarilendirildi.

---

## 📌 ADR-014: Dikey Hibrit Ekran ve Kademeli Gölge Modeli (%0 / %75 / %100)

- **Bağlam:** Depo yağmalama ekranının ergonomisi ve derinlik hissi kurgulandı.
- **Karar:**
  1. *Dikey Hibrit Ekran (Portrait):* Ekranın üst yarısı (%50) 2D katmanlı depo sahnesi, alt yarısı (%50) araç bagajı grid tetrisi ve butonlar olarak tasarlandı. Tek elle akıcı kontrol sağlandı.
  2. *Kademeli Gölge Modeli:*
     - Katman 1 (Ön Plan): %0 gölge (Tamamen görünür).
     - Katman 2 (Orta Plan): Önünde engel varken %75 koyu siluet (şekil seçilir, detay gizli).
     - Katman 3 (Arka Plan / Raflar): Önünde iki katman varken %100 zifiri karanlık. Katman 1 kalkınca %75'e, Katman 2 de kalkınca %0 tam aydınlığa geçer.
- **Gerekçe:**
  - Mobilde tek elle dikey oynanabilirlik en yüksek erişilebilirliği sunar.
  - Kademeli gölge modeli oyuncudaki merak ve keşfetme arzusunu doruk noktasına çıkarır.
- **Sonuç:** Flame sahnesi dikey hibrit oranlarla ve kademeli opacity maskesiyle kodlanacaktır.

---

## 📌 ADR-015: Raid Sonu Resmî İhale ve Temizlik Fatura Raporu

- **Bağlam:** 60 saniyelik raid sayacı bittiğinde veya tüm eşyalar toplandığında sonucun oyuncuya nasıl gösterileceği belirlendi.
- **Karar:** Resmî bir Amerikan depo tasfiye faturası kartı tasarlandı. Kart şunları içerir:
  - Araca yüklenen eşya adedi,
  - Hurdaya ayrılan eşyaların toplam geliri (+),
  - Çağrıldıysa acil nakliye ücreti (-),
  - Depoda eşya kaldıysa kesilen temizlik cezası faturası (-),
  - Net Sefer Kâr/Zarar özeti ve dükkana dönüş butonu.
- **Gerekçe:**
  - Gerçek açık artırma ve işletme simülasyonu hissini pekiştirir.
  - Oyuncuya her kuruşun hesabını şeffaf ve tatmin edici bir şekilde sunar.
- **Sonuç:** Raid sonu için `RaidSummarySheet` bileşeni hazırlanacaktır.

---

## 📌 ADR-016: Isar NoSQL'den Evrensel HIVE (Pure Dart) Veri Katmanına Geçiş

- **Bağlam:** Isar 3.x'in Chrome Web üzerinde JavaScript 64-bit int sınırına takılarak derleme hatası vermesi (`The integer literal can't be represented exactly in JavaScript`) ve Windows masaüstü için devasa Microsoft Visual Studio C++ toolchain'i zorunlu kılması; geliştiricinin tek tip test rutini (`flutter run -d chrome` ve `flutter run`) ile her ortamda sorunsuz geliştirme yapabilme arzusu.
- **Karar:**
  1. Veri katmanı Isar'dan %100 saf Dart (Pure Dart) tabanlı **HIVE** mimarisine taşındı.
  2. Modeller (`ItemModel`, `VehicleModel`, `PlayerProfileModel`, `StorageUnitModel`) Map serileştirmesiyle tip güvenli hale getirildi.
  3. `DatabaseService` singleton yapısı kuruldu ve geriye dönük uyumluluk için `IsarService` alias'ı sağlandı.
  4. Isar C++ kütüphaneleri ve generator bağımlılıkları projeden temizlendi.
- **Gerekçe:**
  - Hive tamamen Pure Dart olduğu için ne Visual Studio ne de C++ derleyicisi gerektirir.
  - Chrome (Web IndexedDB), Windows, Android ve iOS ortamlarının tamamında tek satır kod değiştirmeden "tık" diye çalışır.
  - 276 eşyalık envanter hacmimiz için Hive doğrudan belleğe (RAM) haritalama yaparak Isar seviyesinde ultra hızlı okuma/yazma performansı sunar.
- **Sonuç:** Proje C++ ve 64-bit JS derleme hatalarından tamamen arındırıldı; evrensel çok platformlu veri omurgası tamamlandı.

---

## 📌 ADR-017: Canlı Amerikan Müzayede (Storage Wars) Deneyimi ve Hızlı Teklif Akışı

- **Bağlam:** Oyunun doğrudan depo sahnesiyle başlamasının tematik olarak çiğ kalması; Storage Wars televizyon şovunun heyecanını yaşatacak bir açık artırma atmosferi talebi.
- **Karar:**
  1. *Açılış Sahnesi:* Oyun doğrudan canlı Amerikan açık artırma ekranı (`LiveAuctionScreen`) ile başlar.
  2. *Müzayede Yöneticisi (The Auctioneer):* Kürsüsünde tokmağıyla duran, hızlı hızlı konuşarak ("300 geldi Dave’den! 350 kimde, 350 var mı!..") teklifleri ateşleyen dinamik konuşma sistemi entegre edildi.
  3. *30 Saniyelik Adrenalin Sayacı & Rakipler:* Dave "Kurnaz", Laura "Antikacı", Gus "Tırcı" gibi bot rakipler dinamik bütçeleriyle teklif yükseltir.
  4. *Aralık Kepenk İpuçları:* Depo kepengi %20 aralık durarak içerideki öncü eşyaları gösterir, oyuncu tahmin yürüterek teklif verir.
  5. *Tokmak ve Geçiş:* Süre bittiğinde müzayedeci "SATTIM!" diyerek tokmağı vurur; depoyu kazanan oyuncu "Kepenkleri Aç ve İçeri Gir" diyerek yağma sahnesine (`StorageRaidScreen`) akar.
- **Gerekçe:**
  - Oyuncuyu doğrudan depoya atmak yerine gerçek bir hacizli depo avcısı reality show'unun atmosferine sokar.
  - Risk alma ve ihale rekabeti hissini zirveye taşır.
- **Sonuç:** Oyun artık canlı açık artırma akışıyla başlar.

---

## 📌 ADR-018: İki Aşamalı Müzayede Akışı (15 sn Gözlem + 30 sn İhale)

- **Bağlam:** Açık artırma başlamadan önce oyuncuya depodaki eşyaları gözlemleyip strateji kurma fırsatı verilmesi talebi.
- **Karar:**
  1. *Aşama 1 (15 Saniyelik İnceleme Süresi):* Metal kepenk akıcı bir animasyonla (`CurvedAnimation`) yukarı doğru tam açılır. Depo içi aydınlanır, oyuncu sarı çizginin gerisinden eşyaları tartar. İsterse "Hemen Başlat" butonuyla süreyi atlayabilir.
  2. *Aşama 2 (30 Saniyelik Açık Artırma):* 15 saniye dolunca müzayedeci tokmağı vurur, canlı teklif savaşı başlar, rakipler ve oyuncu teklif yükseltir.
  3. *Aşama 3 (Tokmak ve Giriş):* Kazanan belirlenir ve yağma sahnesine geçilir.
- **Gerekçe:**
  - Gerçek Storage Wars kuralını ("Kimse içeri giremez, dokunamaz; sadece dışarıdan 15 saniye bakın!") yaşatır.
  - Oyuncuya depodaki eşyaları tartıp bütçesini planlama şansı vererek stratejik derinlik katar.
- **Sonuç:** `LiveAuctionScreen` iki aşamalı tam animasyonlu döngüyle kurgulandı.

---

## 📌 ADR-019: Zemin Tabanlı Yuvalar ve Perspektif Ölçekleme Modeli

- **Bağlam:** Eşyaların havada rastgele asılı kalması ve boyutlarının fiziksel dünyayla uyumsuz olması hissi.
- **Karar:**
  1. Depo sahnesi 3 fiziksel seviyeye ayrıldı: Zemin Önü (büyük hacimli mobilyalar, dolaplar, motorlar), Zemin Ortası (kutular, televizyonlar, jeneratörler) ve Arka Raflar (küçük aletler, altınlar, antikalar).
  2. Anchor noktası `Anchor.bottomCenter` olarak ayarlanarak tüm eşyalar zemine ve raf çizgisine oturtuldu.
  3. Eşyalar gerçek boyut katsayılarına göre ölçeklendi (`kanepe: 140x140`, `saat/alet: 60x60`).
- **Gerekçe:** Eşyaların gerçek bir odada/zeminde duruyormuş hissi vermesini sağlar.

---

## 📌 ADR-020: Endüstriyel Hurda & Arcade Dinamik Oyun HUD Tasarımı

- **Bağlam:** Ekrandaki butonların ve kartların standart uygulama (Material) gibi görünmesi, oyun hissi vermemesi.
- **Karar:**
  1. Standart Material butonları yerine; basıldığında içe çökme hissi veren (3D bevel/kabartmalı gölge ve scale mikro animasyonu), metalik perçinli çerçeveli dinamik oyun butonları tasarlandı.
  2. Altın, kehribar ve neon camgöbeği renk paletiyle arcade tarzı göstergeler ve sayaçlar eklendi.
- **Gerekçe:** Oyuncunun gerçek bir video oyunu oynadığını hissetmesi için dokunma tepkileri ve oyun estetiği şarttır.

---

## 📌 ADR-021: 276 Eşyalık Arketip Ağırlıklı Prosedürel Depo Üreticisi

- **Bağlam:** Her depoda aynı eşyaların çıkması ve 276 eşyalık dev kütüphanenin yeterince kullanılmaması.
- **Karar:**
  1. Her depoya rastgele bir arketip atanır (Örn: 'Oto Garajı', 'Müzik Kasası', 'Beyaz Eşya', 'Antika Sandığı', 'Askeri Sığınak').
  2. 276 eşya arasından: %60 arketipe uygun eşyalar, %30 genel eşyalar ve %10 nadir/büyük ikramiye prosedürel olarak seçilir.
- **Gerekçe:** Her ihalenin ve deponun benzersiz, merak uyandırıcı ve sürprizlerle dolu bir ganimet deneyimi sunması sağlanır.

---

## 📌 ADR-022: Gerçekçi Endüstriyel Depo Arka Planı ve Işık Huzmesi

- **Bağlam:** Düz renk arka planın atmosfer eksikliği yaratması.
- **Karar:** Beton zemin perspektifi, sarı-siyah endüstriyel uyarı çizgileri, oluklu çelik yan paneller, tuğla arka duvar ve üstten vuran sıcak sarı konik ışık huzmesi CustomPainter ile çizildi.
- **Sonuç:** Gerçek bir kiralık Amerikan deposuna girilmiş hissi verir.

---

## 📌 ADR-023: 90 Derece Döndürme (Arcade Buton + Çift Dokunma)

- **Bağlam:** Polyomino bagaj yerleşiminde eşyaların farklı yönlerde sığabilmesi için pratik ve hızlı döndürme ihtiyacı.
- **Karar:**
  1. Seçili eşya aksiyon çubuğuna 3D `ArcadeButton` ("90° DÖNDÜR") eklendi.
  2. Ayrıca eşya görseline veya bagajdaki parçaya çift dokunulduğunda (`GestureDetector.onDoubleTap`) anında saat yönünde $90^\circ$ dönmesi sağlandı.
  3. `BitboardEngine.rotate90` matematik fonksiyonu ile bitmaske ve matris $O(1)$ sürede transpoze edilir.
- **Gerekçe:** Mobil ve fareli kullanımda oyuncuya maksimum hız ve akıcılık sağlar.

---

## 📌 ADR-024: Bagaj Eşyalarını Serbest Yeniden Düzenleme ve Taşıma

- **Bağlam:** Bagaja önceden yerleştirilmiş bir eşyanın yeri kilitlendiğinde yeni gelen büyük eşyaların sığamaması ve oyuncuyu çaresiz bırakması.
- **Karar:** Bagaj ızgarasındaki herhangi bir yerleşmiş eşyaya dokunulduğunda eşya havaya kalkar (seçili olur); ızgaradan matematiksel olarak kaldırılır (`BitboardEngine.removeItem`) ve oyuncu onu başka bir hücreye taşıyabilir, $90^\circ$ çevirebilir veya hurdaya atabilir.
- **Gerekçe:** Tetris ve envanter yönetiminde taktiksel derinlik ve oyuncu özgürlüğü sağlar.

---

## 📌 ADR-025: Usta İstifçi XP Bonusu & Gizli Piyasa Değeri Prensibi (%80+ Doluluk)

- **Bağlam:** Bagajı boşluksuz dolduran oyuncunun ödüllendirilmesi ve ticaret heyecanının korunması.
- **Karar:**
  1. Bagaj doluluk oranı %80 ve üzerindeyse oyuncuya seviye atlamasını sağlayan **+150 XP / İtibar Bonusu** verilir (`PlayerProfileNotifier.addReputation`).
  2. Yüklenen eşyaların toplam piyasa değeri fatura ekranında **ASLA İFŞA EDİLMEZ**; sadece adet bilgisi gösterilir. Oyuncu eşyaların gerçek kâr/zarar değerini ilerideki Pazar Yeri / Satış aşamasında kendisi keşfedecektir.
- **Gerekçe:** Tüccarlık ve keşif psikolojisini canlı tutar, oyunun sürpriz faktörünü korur.

---

## 📌 ADR-026: Holografik Yeşil/Kırmızı Anlık Hücre Snap Kılavuzu

- **Bağlam:** Eşyayı bagaj üzerinde sürüklerken veya bir hücreye dokunurken sığıp sığmayacağının net şekilde anlaşılamaması.
- **Karar:** Eşya ızgara üzerinde gezdirilirken veya hedef hücreye yaklaşıldığında `BitboardEngine.canPlace` ile kontrol edilerek altındaki hücreler neon yeşil (sığıyor) veya neon kırmızı (çakışıyor/aşıyor) çizgilerle yanıp söner; bırakıldığında tık diye manyetik oturur.
- **Gerekçe:** Yanıtsız dokunuşları engeller, tatmin edici dokunsal geri bildirim sağlar.

---

## 📌 ADR-028: Dokunsal Restorasyon Mini-Simülasyonu ve Seviye 3+ Otomatik Restorasyon

- **Bağlam:** Paslı/kirli eşyaların temizlenmesinde hem dokunsal tatmin hem de ileri seviyede hız/otomasyon ihtiyacı.
- **Karar:**
  1. Başlangıçta eşyanın üzeri parmakla ovalanarak pasları temizlenir (`onPanUpdate`) ve her ovmada `HapticFeedback` verilir.
  2. Her restorasyon oyuncuya +35 Atölye Ustalığı (Mastery XP) kazandırır.
  3. Seviye 3 Ustalığa (300+ XP) ulaşıldığında mini-oyunu oynamadan tek tıkla **"⚡ OTOMATİK SERİ PARLAT"** butonu aktifleşir.
- **Sonuç:** Oyuncu başlarda işin zanaatkarlık hazzını yaşar, ileri seviyede ise seri tüccarlık hızına kavuşur.

---

## 📌 ADR-029: Dinamik Fiyat Slider'ı ve Poisson Müşteri Pazarlık Simülatörü

- **Bağlam:** Eşyaların pazar yerinde satışında risk-ödül dengesi ve tüccarlık blöfü mekaniği.
- **Karar:**
  1. Oyuncu taban değerin %50 ile %250'si arasında serbest fiyat belirler.
  2. Fiyat %85 ve altındaysa parça hemen nakit olarak satılır.
  3. Yüksek fiyat konursa dükkana gelen bot müşteriler (Hurdacı, Koleksiyoncu, Antikacı) pazarlık teklifleriyle gelir; oyuncu teklifi kabul edebilir veya reddedip bekleyebilir.
- **Sonuç:** Ticaret ve kâr optimizasyonu oyuncunun eline bırakılarak zengin bir ekonomi döngüsü sağlandı.













# 🏗️ PROJE FAZLARI (PHASES.md)

Bu doküman, Depo Avcıları (Storage Raiders & RPG) projesinin modüler, birbiri üzerine inşa edilen ve bağımlılıkları net olarak ayrıştırılmış üretim fazlarını listeler.

---

## Genel Faz Haritası ve Bağımlılık Zinciri

```
[FAZ 1: Çekirdek Altyapı & Bitboard Engine]
       │
       ├──────────────────────────────┐
       ▼                              ▼
[FAZ 2: 2D Depo Yağmalama]     [FAZ 3: Araç Bagajı Grid Tetrisi]
       │                              │
       └──────────────┬───────────────┘
                      ▼
[FAZ 4: Ekonomi, İhale, Pazar Yeri & Tezgahlar]
                      │
                      ▼
[FAZ 5: Zindan Sistemi (AFK + Aktif Savaş) & Global Polish]
```

---

## 🔹 FAZ 1: Çekirdek Altyapı, Hive Veritabanı ve Bitboard Matematik Motoru
*Projenin omurgası, veri saklama mimarisi ve yüksek performanslı polyomino çarpışma fiziği.*

### Kapsam ve Teslimatlar:
1. **Veri Modelleri & Hive Database Entegrasyonu:**
   - `Item`: ID, adı, boyut (GxY / maske), kategori, temel değer, kondisyon (Hurda -> Mistik), ağırlık, sprite yolu.
   - `StorageUnit`: Depo boyutu, zorluk seviyesi, katmanlı eşya listesi, açılış bedeli.
   - `PlayerProfile`: Bakiye, tecrübe puanı, açık lisanslar, garaj seviyesi.
   - `VehicleInventory`: Bagaj grid matrisi ($M \times N$), ağırlık kapasitesi.
2. **64-Bit Bitboard Matematik Motoru (`BitboardEngine`):**
   - $O(1)$ sürede satır bazlı bit maskesi çakışma testi `(GridRow & ItemMask) == 0`.
   - $90^\circ$ adımlarla eşya transpozisyonu ve bitboard döndürme fonksiyonları.
   - AABB (Axis-Aligned Bounding Box) sınır kontrolü.
3. **Riverpod Global Durum İskeleti:**
   - `PlayerStateNotifier`, `InventoryNotifier`, `GameSettingsNotifier`.
4. **Varlık Yönetimi (Asset Pipeline):**
   - Hazır Python BiRefNet (`rembg`) aracılığıyla üretilen 1024x1024 WebP eşyaların Flutter assetlerine bağlanması.

---

## 🔹 FAZ 2: 2D Katmanlı Depo Yağmalama & Gölge Maskeleme (Flame Katmanı)
*Oyuncunun depoya girdiği, zamanla yarıştığı ve gizli eşyaları ortaya çıkardığı ilk sahne.*

### Kapsam ve Teslimatlar:
1. **Katmanlı Cephe Sahnesi (Frontal Elevation World):**
   - **Katman 1 (Ön Plan):** Büyük engeller (hurda buzdolabı, yırtık koltuk, koli dağları).
   - **Katman 2 (Orta Plan):** Alet çantaları, antika radyolar, televizyonlar, kasalar.
   - **Katman 3 (Arka Plan / Raflar):** Gizli çekmeceler, mücevher kutuları, mistik sandıklar.
2. **Gölge Maskesi ve Keşif Bileşeni (`ShadowMaskComponent`):**
   - Arka katmanlardaki eşyaların siluet/gölge altında başlatılması.
   - Önündeki engel kaldırıldığında arkadaki eşyanın gölgesinin açılması (`Tween` aydınlanma ve parıldama efekti).
3. **Dokunma ve Etkileşim:**
   - Tıklanan eşyanın parmak dokunuşuyla ekrandan havalanıp oyuncunun toplama sepetine/aracına doğru süzülme animasyonu.
4. **Zaman Sayacı ve Ceza Mekaniği:**
   - Flame `TimerComponent` ile 60/45 saniyelik geri sayım.
   - Süre bitiminde depoda kalan değerli eşyaların temizlik ücreti faturası ($Ceza = \text{KalanEşyalar} \times 0.25$).
5. **Flame $\leftrightarrow$ Flutter HUD:**
   - Kalan süre, toplanan toplam değer ve uyarı bannerları için sıfır-jank `ValueNotifier` overlay'i.

---

## 🔹 FAZ 3: Araç Bagajı Grid Tetrisi & Depo-Bagaj Entegrasyonu
*Yağmalanan eşyaların araca en karlı ve sıkı şekilde doldurulduğu mekansal bulmaca.*

### Kapsam ve Teslimatlar:
1. **Bagaj Grid Görünümü:**
   - Pikap ($8 \times 12$), Kamyonet ($12 \times 20$) gibi farklı araç şablonları.
   - Dinamik hücre pikselleri ve otomatik ekran sığdırma (Anchor & Scale).
2. **Polyomino Sürükle - Bırak (Drag & Drop) Mekaniği:**
   - Parmağın altındaki eşyanın grid üzerinde serbestçe gezmesi.
   - Bitboard motoruyla anlık yeşil (geçerli) / kırmızı (çakışma/dışarıda) snap önizlemesi.
3. **Eşya Döndürme (Rotation Controls):**
   - Ekranda tek dokunuşla eşyayı $90^\circ$ saat yönünde çevirme ve bit maskesini güncelleme.
4. **Kapasite ve Ağırlık Limiti:**
   - Bagajın hacimsel doluluğu ve süspansiyon ağırlık sınırı kontrolü.
   - Aşırı yüklenme durumunda hız cezası veya eşya bırakma zorunluluğu.
5. **Depo $\rightarrow$ Bagaj Entegrasyon Akışı:**
   - Depo yağmasından çıkan eşyaların geçici "Yükleme Platformu"nda listelenmesi ve oradan bagaja dizilmesi.

---

## 🔹 FAZ 4: Ekonomi, İhale, Pazar Yeri ve Tezgahlar (Saf Flutter Katmanı)
*Oyunun RPG derinliğini, kâr maksimizasyonunu ve yönetim zevkini sağlayan menü ve ekonomi sistemleri.*

### Kapsam ve Teslimatlar:
1. **Depo Açık Artırması (İhale) Simülatörü:**
   - Poisson dağılımlı yapay zeka bot rakipler.
   - Kepenk 5 saniyeliğine %30 aralanır; oyuncu içerideki ipuçlarına bakarak teklif verir.
   - Botların agresyon katsayısı ve tahmin tavanı formülleri.
2. **Satış Kanalları:**
   - **Hurdacı:** Anında nakit, ancak eşya değerinin sadece %20'si.
   - **Oyun İçi Pazar Yeri (Marketplace):** Eşyayı istenen fiyata koyma; fiyata bağlı dinamik satış süresi formülü ($T_{satış} = T_{base} \times (Fiyat / Değer)^{2.5}$).
3. **Restorasyon & Zanaat Tezgahları:**
   - **Ultrasonik Temizleme:** Pas ve kiri temizler, değeri $1.0\times$'a çıkarır.
   - **Hassas Onarım:** Kırık parçaları onarır, değeri $1.5\times$ mükemmel seviyeye ulaştırır.
   - **Mistik Dönüştürücü:** İki eşyayı birleştirip $2.5\times$ mistik eşya veya zindan ekipmanı üretir.

---

## 🔹 FAZ 5: Zindan Sefer Sistemi (Taskbar Hero / Pasif Keşif) ve Son Cila (Lansman)
*Ganimetleri güce dönüştürme, kuşanma ve pasif sefer döngüsü.*

### Kapsam ve Teslimatlar:
1. **Pasif Sefer & Zindan Simülasyonu (Taskbar Hero Modeli):**
   - Paralı asker kiralama ve depodan çıkan eşyaları (Zırh, Silah, Tılsım) askere kuşandırma.
   - Belirli sürelerde (5 dk, 15 dk, 1 saat) zindana gönderme ve dönüşte başarı/başarısızlık raporu ve nadir ganimet teslimatı.
   - Kuşanılan eşyaların sefer sonucuna göre aşınma/kondisyon kaybı yaşaması.
2. **Görsel & İşitsel Cila (Game Feel & Audio):**
   - Depo ve bagaj ekranlarında parçacık efektleri (Particles), başarı sesleri ve ekran sarsıntısı.
3. **Performans Optimizasyonu & QA Smoke Check:**
   - Hive Box optimizasyonları ve TypeAdapter serileştirmeleri, Flame component pooling, 60-120 FPS kararlılık testi.

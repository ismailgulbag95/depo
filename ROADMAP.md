# 🗺️ PROJE YOL HARİTASI VE ZAMAN PLANI (ROADMAP.md)

Bu doküman; Depo Avcıları (Storage Raiders & RPG) projesinin faz bazlı zaman çizelgesini, sprint tarihlerini, kilometre taşlarını (Milestones) ve kabul kriterlerini (Definition of Done - DoD) tanımlar.

---

## 📅 Genel Zaman Çizelgesi Özeti (Q3 - Q4 2026)

```
2026         EYLÜL                     EKİM                      KASIM
Hafta:   W1   W2   W3   W4        W5   W6   W7   W8        W9   W10  W11  W12
Fazlar: [── FAZ 1 ──][── FAZ 2 ──][── FAZ 3 ──][── FAZ 4 ──][── FAZ 5 ──][ RELEASE ]
Milestone:   M1         M2             M3           M4            M5        BETA/PROD
```

| Faz | Başlangıç | Bitiş | Süre | Hedef Çıktı / Kilometre Taşı |
| :--- | :--- | :--- | :--- | :--- |
| **FAZ 1: Çekirdek & Bitboard** | 02 Eylül 2026 | 16 Eylül 2026 | 2 Hafta | **M1: Core Engine & DB Stabilite** |
| **FAZ 2: Depo Yağmalama (Raid)** | 16 Eylül 2026 | 30 Eylül 2026 | 2 Hafta | **M2: Oynanabilir Depo Prototipi** |
| **FAZ 3: Bagaj Grid Tetrisi** | 30 Eylül 2026 | 14 Ekim 2026 | 2 Hafta | **M3: Tam Lojistik Döngüsü** |
| **FAZ 4: Ekonomi & Zanaat** | 14 Ekim 2026 | 28 Ekim 2026 | 2 Hafta | **M4: İhale, Pazar & Atölye Döngüsü** |
| **FAZ 5: Zindan & Savaş** | 28 Ekim 2026 | 11 Kasım 2026 | 2 Hafta | **M5: RPG Sistemi & İçerik Kilidi** |
| **Lansman & Cila (Release)** | 11 Kasım 2026 | 25 Kasım 2026 | 2 Hafta | **PROD: Global Store Sürümü (iOS/Android)** |

---

## 🎯 Kilometre Taşları (Milestones) ve Detaylı Teslim Takvimi

### 🏆 Milestone 1 (M1): Çekirdek Altyapı ve Matematik Motoru
- **Tarih Aralığı:** 02 Eylül 2026 – 16 Eylül 2026
- **Hedef:** Tüm veri tiplerinin Isar DB üzerinde kalıcı hale getirilmesi ve 64-bit Bitboard motorunun birim testlerle doğrulanması.
- **Kabul Kriterleri (DoD):**
  - [ ] Isar koleksiyon şemaları (`ItemSchema`, `StorageUnitSchema`, `PlayerSchema`) oluşturulmuş ve derlenmiş olmalı.
  - [ ] `BitboardEngine` $O(1)$ çakışma ve $90^\circ$ döndürme testleri %100 test kapsamıyla geçmeli.
  - [ ] Riverpod `PlayerNotifier` ve `InventoryNotifier` reaktif olarak çalışmalı.
  - [ ] AI stüdyo asset pipeline'ı ile en az 50 temel eşya şeffaf WebP olarak projeye eklenmiş olmalı.

---

### 🏆 Milestone 2 (M2): Oynanabilir 2D Depo Yağmalama Prototipi
- **Tarih Aralığı:** 16 Eylül 2026 – 30 Eylül 2026
- **Hedef:** Kepenk kalktığında oyuncunun 3 katmanlı derinlikte eşyaları tıklayıp araca uçurduğu ilk interaktif oyun sahnesi.
- **Kabul Kriterleri (DoD):**
  - [ ] Flame sahnesinde Ön, Orta ve Arka plan katmanları derinlikli olarak çizilmeli.
  - [ ] `ShadowMaskComponent` arkadaki eşyaları başarıyla gizlemeli; önündeki engel kalkınca açılmalı.
  - [ ] Tıklanan eşyalar tween eğrisiyle ekranın altına süzülmeli.
  - [ ] Kalan süre sayacı sıfıra indiğinde ceza ekranı başarıyla tetiklenmeli.
  - [ ] Mobil cihazda 60 FPS altına düşmemeli.

---

### 🏆 Milestone 3 (M3): Bagaj Grid Tetrisi ve Depo Entegrasyonu
- **Tarih Aralığı:** 30 Eylül 2026 – 14 Ekim 2026
- **Hedef:** Depodan toplanan eşyaların araç bagajına dokunmatik olarak yerleştirildiği tam lojistik halkası.
- **Kabul Kriterleri (DoD):**
  - [ ] $8 \times 12$ pikap ve $12 \times 20$ kamyonet ızgarası sorunsuz render edilmeli.
  - [ ] Eşyalar parmakla sürüklenirken anlık yeşil/kırmızı snap geri bildirimi vermeli.
  - [ ] Eşya döndürme butonu/çift dokunuş eşyayı saat yönünde transpoze etmeli.
  - [ ] Depo yağması bittiğinde eşyalar bagaj ekranına akmalı ve sığmayanlar uyarılmalı.

---

### 🏆 Milestone 4 (M4): Ekonomi, İhale ve Zanaat Döngüsü
- **Tarih Aralığı:** 14 Ekim 2026 – 28 Ekim 2026
- **Hedef:** İhaleden depoyu satın alıp, eşyaları tamir edip pazar yerinde satarak bakiye büyütme döngüsü.
- **Kabul Kriterleri (DoD):**
  - [ ] Kepenk aralama ve Poisson bot teklif verme ihaleleri çalışmalı.
  - [ ] Hurdacı anında nakit ($0.20\times$), Pazar yeri listeleme zamanı eğrisi formülüyle işlemeli.
  - [ ] Ultrasonik temizleme, hassas tamir ve mistik tezgahlar eşya kondisyonunu artırmalı.
  - [ ] Bakiye ve envanter Isar veritabanında kesintisiz saklanmalı.

---

### 🏆 Milestone 5 (M5): Zindan Sistemi, RPG ve Cila
- **Tarih Aralığı:** 28 Ekim 2026 – 11 Kasım 2026
- **Hedef:** Ganimetlerin paralı askerlere donatılması, AFK ve aktif savaş döngülerinin tamamlanması.
- **Kabul Kriterleri (DoD):**
  - [ ] Discrete-time AFK keşfi, uygulama kapalıyken bile geçen süreye göre ganimet hesaplamalı.
  - [ ] Flame Top-Down aktif zindan savaşında sanal joystick ve düşman FSM yapay zekası çalışmalı.
  - [ ] Ses efektleri (SFX) ve ekran sarsıntısı / parıltı parçacıkları eklenmeli.

---

### 🚀 Milestone Final: Mağaza Hazırlığı ve Global Lansman
- **Tarih Aralığı:** 11 Kasım 2026 – 25 Kasım 2026
- **Hedef:** Store listelemeleri, test kullanıcı geri bildirimleri, son performans incelemesi ve sürüm dağıtımı.
- **Kabul Kriterleri (DoD):**
  - [ ] Android App Bundle (.aab) ve iOS IPA paketleri hazır ve test edilmiş olmalı.
  - [ ] Memory leak kontrolü (Dart DevTools leak tracker ile doğrulanmış olmalı).
  - [ ] Mağaza ekran görüntüleri ve tanıtım metinleri tamamlanmalı.

---

## ⚠️ Risk Yönetimi ve Tampon Stratejisi

1. **Varlık Çeşitliliği Riski:** 100+ eşyanın prompt ve temizleme süreci gecikirse:
   - *Çözüm:* Hazır olan `tools/item_ayiklama.py` ve `tools/refine_assets.py` batch pipeline'ı ile günde 30 eşya işlenebilir durumdadır.
2. **Flame-Flutter Performans Darboğazı:** Mobilde aşırı widget rebuild olursa:
   - *Çözüm:* `ValueNotifier` tabanlı mikro-overlay mimarisi zorunlu kılınmıştır.
3. **Zaman Sapması:** Herhangi bir fazda 3 günden fazla gecikme olursa, Faz 5'teki "Aktif Savaş" kapsamı lansman sonrasına (v1.1) ertelenebilir; "AFK Pasif Savaş" tek başına v1.0 için yeterlidir.

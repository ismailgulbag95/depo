# 📦 DEPO AVCILARI (STORAGE RAIDERS & RPG)

Terk edilmiş depo açık artırmaları, mekansal araç bagajı grid bulmacası (polyomino), eşya restorasyonu ve rogue-lite RPG zindan sistemini bir araya getiren hibrit mobil ve masaüstü simülasyon oyunu.

---

## 📚 PROJE YÖNETİMİ VE DOKÜMANTASYON SİSTEMİ

Projemiz, çevik ve hatasız bir geliştirme süreci yürütmek için **MOTHER.md** liderliğinde 10 modüler kontrol dokümanı üzerinden yönetilmektedir:

0. 👑 [**MOTHER.md**](file:///d:/github/depo/MOTHER.md) — **Ana Komuta Merkezi, tüm sistemin tek doğruluk kaynağı ve doküman navigasyon haritası.**
1. 🎯 [**PROJECT.md**](file:///d:/github/depo/PROJECT.md) — Proje vizyonu, oynanış döngüsü (Core Loop) ve hedef kitle analizi.
2. 🏗️ [**PHASES.md**](file:///d:/github/depo/PHASES.md) — Projenin 5 ana fazı, kapsamları ve teslimat sınırları.
3. 🗺️ [**ROADMAP.md**](file:///d:/github/depo/ROADMAP.md) — Fazların bitiş tarihleri, sprint takvimi ve kabul kriterleri (DoD).
4. 🏛️ [**ARCHITECTURE.md**](file:///d:/github/depo/ARCHITECTURE.md) — Tüm fazların ayrı ayrı teknik detayları, algoritmaları ve matematik formülleri.
5. 📋 [**TODO.md**](file:///d:/github/depo/TODO.md) — **ŞU AN HANGİ İŞİN YAPILDIĞI** ve sıradaki işin ne olduğunu belirleyen canlı pano.
6. ⚖️ [**DECISIONS.md**](file:///d:/github/depo/DECISIONS.md) — Projede alınan kritik kararların gerekçeleri (ADR kayıtları).
7. 💡 [**LESSONS.md**](file:///d:/github/depo/LESSONS.md) — Hatalardan çıkarılan dersler ve teknik tecrübeler.
8. 📝 [**CHANGELOG.md**](file:///d:/github/depo/CHANGELOG.md) — Tarih bazlı sürüm geçmişi ve değişiklik dökümü.
9. 🚀 [**README.md**](file:///d:/github/depo/README.md) — Kurulum, çalışma ortamı ve çalıştırma rehberi (Bu dosya).

---

## 🛠️ GEREKSİNİMLER (PREREQUISITES)

- **Flutter SDK:** ^3.13.1 veya üzeri (Dart 3.x)
- **Cihaz / Emülatör:** Android Studio (Emulator) / iOS Simulator / Windows Desktop C++ Araçları
- **Python (Asset Pipeline İçin):** Python 3.10+ (BiRefNet ve Pillow kütüphaneleri ile)

---

## 🚀 KURULUM VE ÇALIŞTIRMA (SETUP & RUN)

### 1. Depoyu Klonlayın ve Bağımlılıkları İndirin
```bash
git clone https://github.com/kullanici/depo.git
cd depo
flutter pub get
```

### 2. Isar ve Freezed Kod Üretimini Çalıştırın
Isar NoSQL veritabanı şemalarını derlemek için:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Uygulamayı Başlatın
- **Windows Masaüstü (Hızlı Test):**
  ```bash
  flutter run -d windows
  ```
- **Android Emülatör / Cihaz:**
  ```bash
  flutter run -d android
  ```
- **Chrome / Web (Geliştirme):**
  ```bash
  flutter run -d chrome
  ```

---

## 🎨 ASSET VE EŞYA ÜRETİM HATTI (ASSET PIPELINE)

AI (Midjourney / Flux.1) ile üretilen eşyaların arka planını temizleyip otomatik olarak projeye dahil etmek için:

1. Ham görselleri `assets/raw_input/` klasörüne atın.
2. `tools/run_pipeline.bat` dosyasını çift tıklayın veya terminalden çalıştırın:
   ```bash
   cd tools
   python run_pipeline.py
   ```
3. Betik, BiRefNet yapay zeka modelini kullanarak arka planı şeffaflaştırır, sınırları kırpar ve hazır WebP formatında `assets/items/` dizinine kaydeder.

---

## 🧪 TESTLERİ ÇALIŞTIRMA

Matematiksel Bitboard motoru ve oyun mantığı testlerini doğrulamak için:
```bash
flutter test
```

# 💡 ÇIKARILAN DERSLER VE TEKNİK TEBRÜBELER (LESSONS.md)

Bu doküman; geliştirme sürecinde yapılan her hatadan, karşılaşılan darboğazlardan ve çözülen mimari krizlerden çıkarılan hayati dersleri kayıt altına alır. Gelecekte aynı hataların tekrarlanmasını engeller.

---

## 📌 Ders 1: 3D Modelleme ve 2.5D İzometriğin Geliştiriciyi Tıkaması
- **Hata:** Projenin başında tüm depo ve eşyaların Blender'da 3D modellenip 30° izometrik render alınmasının planlanması.
- **Sonuç:** Tek bir eşyanın modellenmesi, kaplanması ve renderı saatler sürdü. 100 eşyalık bir envanter için aylar gerekiyordu; bu durum geliştirme sürecini tamamen durma noktasına getirdi.
- **Çıkarılan Ders:**
  1. *Oynanış Derinliği > 3D Karmaşası:* Oyuncunun aradığı tatmin 3D kamera açısı değil; gizli hazineyi bulma, grid optimizasyonu ve restorasyon hissidir.
  2. *Katmanlı 2D Gücü:* Cepheden 3 kademeli (Ön/Orta/Arka) 2D katman sıralaması, izometrik 3D'nin verdiği derinlik hissinin tamamını %95 daha az iş gücüyle sunmaktadır.
  3. *AI + rembg Avantajı:* AI stüdyo görsel üretimi ve Python BiRefNet ile 1 aylık 3D mesai 2 güne inmiştir.

---

## 📌 Ders 2: Flame ile Flutter Arasında Yanlış State Dinleme (FPS Çöküşü)
- **Hata:** Flame sahnesindeki geri sayım sayacını (60 saniye) veya enerji barını her `update(dt)` anında Riverpod StateNotifier üzerinden Flutter'ın ana ekranına bildirmek.
- **Sonuç:** Flutter UI ağacı saniyede 60 kez komple `build()` çalıştırdı. Cihaz aşırı ısındı ve FPS 15'e kadar çakıldı (Jank).
- **Çıkarılan Ders:**
  1. *Dual-Channel İlkesi:* Yüksek frekanslı (60 Hz) veriler **asla** Riverpod veya geniş kapsamlı `setState` ile taşınmamalıdır.
  2. *ValueNotifier Mikro Güncellemesi:* Sadece sayaç metnini saran `ValueListenableBuilder` kullanılmalıdır. Bu sayede ekranın %99'u sabit kalırken yalnızca sayaç pikseli güncellenir.
  3. *Olay Tabanlı Kalıcılık:* Isar ve Riverpod yalnızca "Eşya Toplandı", "Süre Bitti", "Zindan Tamamlandı" gibi seyrek olaylarda tetiklenmelidir.

---

## 📌 Ders 3: Polyomino Grid Çakışmasında 2D Dizi Döngüsü Tuzağı
- **Hata:** Eşya sürüklenirken parmak hareket ettikçe $M \times N$ boyutundaki hücreleri iç içe iki `for (int x...) for (int y...)` döngüsüyle kontrol etmek.
- **Sonuç:** Hızlı parmak kaydırmalarında ve büyük gridlerde (kamyonet $12 \times 20$) mikrosaniyelik takılmalar ve gereksiz bellek nesnesi üretimi (Garbage Collection baskısı) oluştu.
- **Çıkarılan Ders:**
  1. *Satranç Motorları Mantığı (Bitboard):* 64-bit tamsayılar mikroişlemcilerin doğal dilidir. Satırları bit maskesi olarak tutmak ve tek bir `(row & mask) == 0` işlemi yapmak işlemi anında ($O(1)$) çözer.
  2. *Döndürme Verimliliği:* $90^\circ$ döndürme işlemi dahi transpoze bitboard matematiğiyle sıfır bellek tahsisiyle çalıştırılmalıdır.

---

## 📌 Ders 4: AI Varlık Üretiminde Şeffaflık ve Ölçek Standardizasyonu
- **Hata:** Promptlarda arka plan ışığı ve açıyı belirtmeden rastgele üretim yapıp, farklı boyutlarda görselleri doğrudan oyuna aktarmak.
- **Sonuç:** Kimi eşya gölgeli, kimi beyaz zeminli, kimi çok küçük kaldı. BiRefNet kesiminde kenarlarda beyaz hale (halo) lekeleri oluştu.
- **Çıkarılan Ders:**
  1. *Standart Prompt Rehberi:* Her prompt mutlaka `isolated studio shot on solid white background, 8k product photography, soft studio lighting` kalıbını içermelidir (`docs/Gorsel_Uretim_Prompt_Rehberi.csv`).
  2. *Otomatik Padding ve Normalizasyon:* `tools/refine_assets.py` gibi betiklerle her görselin sınırları alpha pikseline kadar kırpılmalı (bounding box trim) ve eşit piksel payı (örneğin %5 padding) ile 1024x1024 WebP olarak paketlenmelidir.

---

## 📌 Ders 5: Monolitik Dokümantasyonun Yönetilemez Hale Gelmesi
- **Hata:** Projenin tüm vizyonunu, mimarisini, yol haritasını, görevlerini ve kararlarını tek bir devasa dosyada (`ARCHITECTURE_AND_ROADMAP.md`) toplamaya çalışmak.
- **Sonuç:** Bir karar değiştiğinde hangi bölümün güncelleneceği karıştı, görev takibi kayboldu ve doküman okunamaz hale geldi.
- **Çıkarılan Ders:**
  1. *Modüler Dokümantasyon:* Proje vizyonu (`PROJECT.md`), fazlar (`PHASES.md`), zaman çizelgesi (`ROADMAP.md`), teknik mimari (`ARCHITECTURE.md`), görevler (`TODO.md`), kararlar (`DECISIONS.md`), dersler (`LESSONS.md`), değişiklikler (`CHANGELOG.md`) ve kurulum (`README.md`) bağımsız olmalıdır.
  2. *Yaşayan Kontrol Paneli:* `TODO.md` her güncel sprintte güncellenirken, `ARCHITECTURE.md` stabil kalmalıdır.

---

## 📌 Ders 6: Isar NoSQL ve Chrome (Web) JavaScript 64-Bit Tamsayı Çakışması
- **Hata:** Projeyi Chrome (`flutter run -d chrome`) hedefinde çalıştırmayı denemek.
- **Sonuç:** Isar'ın 64-bit int hash ID'leri JavaScript'in $2^{53}-1$ sınırını aştığı için `The integer literal can't be represented exactly in JavaScript` derleme hatası verdi.
- **Çıkarılan Ders:**
  1. *Platform Hedefi:* Isar C++ native FFI motorudur ve yerel masaüstü (Windows) ile mobil (Android/iOS) ortamlarında 64-bit int ile tam hızda çalışır.
  2. *Çalıştırma Komutu:* Testler için `flutter run -d windows` (Windows Masaüstü) veya Android Emülatör kullanılmalıdır. Web hedefi tercih edilecekse Isar Web için derleme anında int dönüştürme kuralları uygulanmalıdır.

---

## 📌 Ders 7: Windows Ephemeral Plugin Symlinks Hatası (Errno 183)
- **Hata:** `flutter run -d windows` çalıştırıldığında `PathExistsException: Cannot create link, path = 'windows/flutter/ephemeral/.plugin_symlinks/audioplayers_windows' (OS Error: Halen varolan bir dosya oluşturulamaz, errno = 183)` hatası alınması.
- **Sonuç:** Flutter derleyicisi önceki geçici symlink bağlantısını ezemediği için derleme durdu.
- **Çıkarılan Ders:**
  1. *Temizlik Protokolü:* Windows masaüstü derlemelerinde eklenti veya ortam değiştiğinde `windows/flutter/ephemeral` klasöründeki eski symlink'ler `flutter clean` ile temizlenmelidir.
  2. *Hızlı Çözüm:* `flutter clean && flutter pub get && flutter run -d windows` komut zinciri symlink'leri sıfırdan ve sağlıklı biçimde yeniden oluşturur.



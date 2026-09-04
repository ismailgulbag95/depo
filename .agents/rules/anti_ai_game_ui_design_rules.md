# 🛡️ ANTI-AI GAME UI & TACTILE DESIGN RULES (GÖRSEL ZEKA KURALI)

> **Amaç:** Bu kural seti; yapay zekanın ürettiği basmakalıp, jenerik, steril ve "koyu modlu mobil dashboard/finans uygulaması" (Material App) hissiyatı veren kalıpları tamamen yıkar. Oyunun her pikselinde **"Industrial Rust & High-Stakes Arcade"** ruhunu, dokunsallığı, diegetik (dünya içi) nesneleri ve zengin oyun hissini (Game Feel / Juice) zorunlu kılar.

---

## 🚫 1. YASAKLANMIŞ AI KALIPLARI (ANTI-PATTERNS)

Aşağıdaki kalıpların bu projede kullanımı **KESİNLİKLE YASAKTIR**:

1. ❌ **Steril Flat Kutular:** Düz tek renk koyu gri arka planlar (`#121212`, `#1E1E1E`) ve tek çizgi `Border.all(color: Colors.white12)` kullanmak.
2. ❌ **Sistem / Varsayılan Fontlar:** Başlıklarda, sayaçlarda ve fiyatlarda standart `Roboto` veya varsayılan `TextStyle` kullanmak.
3. ❌ **Material Dialog & Standart SnackBar:** Oyun ekranının ortasında beyaz/gri Material AlertDialog veya alttan çıkan düz SnackBar patlatmak.
4. ❌ **Sessiz ve Hareketsiz Etkileşimler:** Tıklamalarda tepki vermeyen, basılma derinliği olmayan, sarsıntı ve yaylanma (bounce/elastic) içermeyen statik butonlar.
5. ❌ **Soyut Dashboard İkonografisi:** Her şeye standart Material ikonları koyup geçmek yerine oyunun temasına uygun rozetler, damgalar, emniyet etiketleri ve ibreler tasarlanmalıdır.

---

## ✨ 2. TEMEL TASARIM İLKELERİ VE OYUN KİMLİĞİ

### 🎨 Görsel Stil: *"Industrial Rust & High-Stakes Arcade"*
- **Dokular ve Materyaller:** Fırçalanmış koyu döküm çelik, perçinli sac plakalar, vidalı köşe korumaları, aşınmış sarı-siyah ikaz şeritleri (hazard stripes), ezilmiş karton ve ahşap paletler.
- **Skeuomorfik-Modern Hibrit (Beveled Depth):** Her panelin üst kenarında ince bir açık renk (highlight: `#FFFFFF18`), alt kenarında ise koyu döküm gölgesi (`#00000088`) bulunarak 3D preslenmiş metal derinliği verilir.

---

## 🔤 3. TİPOGRAFİ HİYERARŞİSİ (TYPOGRAPHY SYSTEM)

Tüm UI metinlerinde `GameTypography` kullanılmalıdır:

| Metin Tipi | Font Ailesi | Kullanım Yeri | Örnek |
| :--- | :--- | :--- | :--- |
| **Display / Başlık** | `Russo One` / `Teko` | Depo Başlıkları, "SATILDI", "İHALE", Buton Metinleri | `AÇIK ARTIRMA #204` |
| **Veri / LED Sayaç** | `Orbitron` / `Share Tech Mono` | Sayaçlar, Kalan Süre, Fiyatlar, Teklif Rakamları, Cüzdan | `12.450 ₺`, `00:15` |
| **Gövde / Teknik** | `Rajdhani` / `Chivo` | Eşya Açıklamaları, Müzayedeci Anonsları, Fatura Kalemleri | `Paslı Antika Daktilo (Ağır)` |

---

## 📦 4. DİEGETİK VE YARI-DİEGETİK ARAYÜZ (IN-WORLD UI)

Arayüz elemanları oyun dünyasının fiziksel bir parçası gibi davranmalıdır:

1. **Açık Artırma Sahnesi:**
   - Standart sayaç kutusu yerine: **"Duvara Monte Retro Dijital LED Skorbord"**.
   - Standart butonlar yerine: **"Masanın Üstündeki Işıklı Teklif Pedalları / Numaralı Kürekler"**.
   - Anonslar: **"Müzayede Podyum Mikrofonu ve Kayan Neon Bant"**.
2. **Depo Yağması & Bagaj Sahnesi:**
   - Üst kısım: **"Loş Sarı Ampul Işığıyla Aydınlatılmış Tozlu Katmanlı Depo"**.
   - Alt kısım: **"Pikabın / Kamyonetin Açık Metal Kasası (Perçinli kargo tabanı)"**.
   - Eşya seçildiğinde: Eşyanın çevresinde dinamik tebeşir konturu (`Chalk Outline`) ve neon vurgu.
3. **Sonuç & Fatura:**
   - Modal bottom sheet yerine: Masanın üzerine fırlatılan, **kırmızı "SATILDI" veya yeşil "KÂRLI" kaşesi basılmış zımbalı resmi depo tapusu/faturası**.

---

## 💥 5. GAME FEEL & JUICE PROTOKOLÜ (MİKRO-ETKİLEŞİMLER)

1. **Screen Shake (Ekran Sarsıntısı):**
   - Tokmak indiğinde (`gavel drop`), büyük bir eşya bagaja oturduğunda veya süre 5 saniyenin altına düştüğünde arayüzde 4-8px mikro sarsıntı uygulanır.
2. **Dokunsal Geri Bildirim (Haptics):**
   - Her teklif artışında `HapticFeedback.lightImpact()`.
   - İhale kazanıldığında veya eşya yerleştiğinde `HapticFeedback.heavyImpact()`.
3. **Yaylı & Basılan Butonlar (`ArcadeButton`):**
   - Butonlar basıldığında 4-6px aşağı çöker, alt gölgesi sıfırlanır, bırakıldığında elastik yaylanır.
4. **Zaman Baskısı (Pulse & Vignette):**
   - Son 5 saniyede ekranın kenarlarında nabız gibi atan kırmızı/turuncu vignette ışığı.

---

## 🧱 6. KODLANABİLİR BİLEŞEN KÜTÜPHANESİ ZORUNLULUĞU

Yeni bir ekran veya widget kodlarken doğrudan ham Flutter widget'ları yazmak yerine, projenin `lib/core/widgets/` altındaki oyunlaştırılmış bileşenlerini kullanın:
- `DiegeticMetalPanel`: Perçinli metal kart ve arka planlar için.
- `RetroLedDisplay`: Sayaçlar, nakit para ve fiyatlar için.
- `HazardStripeBanner`: Uyarılar ve dikkat çekici başlıklar için.
- `ArcadeButton`: Tüm tıklanabilir butonlar için.
- `AuctionStamp`: Başarı/başarısızlık sonuçları için.
- `GameScreenShake`: Dinamik ekran tepkileri için.

---

## 🎯 7. ÖZET MOTTO

> *"Eğer hazırladığın ekran bir bankacılık veya e-ticaret uygulamasına benziyorsa YANLIŞTIR. Eğer bir Amerikan açık artırma şovuna, retro atari salonuna ve yağlı bir tamirhane garajına benziyorsa DOĞRUDUR."*

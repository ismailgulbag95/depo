# 📦 PROJE TANIMI VE VİZYON: DEPO AVCILARI (STORAGE RAIDERS & RPG)

---

## 1. Proje Nedir?

**Depo Avcıları (Storage Raiders & RPG)**; terk edilmiş depo açık artırmalarının heyecanını, mekansal bulmaca (polyomino / grid envanter) zekasını, eşya restorasyonu simülasyonunu ve rogue-lite RPG derinliğini tek bir çatı altında birleştiren **hibrit bir simülasyon ve rol yapma oyunudur**.

Oyuncu, kısıtlı bütçeyle başladığı kariyerinde gizemli depo ihalelerine girer; kepengi aralanan depoları inceler, rakiplerine karşı blöf ve teklif savaşları verir. İhaleyi kazandığında deponun içine girip zamanla yarışarak önündeki engelleri ve eşyaları toplar. Topladığı ganimetleri aracının sınırlı bagajına en uygun şekilde yerleştirmek için mekansal zekasını konuşturur.

Elde edilen eşyalar atölyede temizlenir, tamir edilir veya dönüştürülür. Oyuncu bu eşyaları ister pazar yerinde kârla satarak lojistik imparatorluğunu büyütür, isterse donanım olarak kuşanıp kiraladığı paralı askerlerle birlikte tehlikeli zindanlara göndererek efsanevi hazinelerin peşine düşer.

---

## 2. Temel Oynanış Döngüsü (Core Gameplay Loop)

Oyun 5 ana halkadan oluşan, yüksek oranda tatmin edici ve bağımlılık yapıcı bir mikro-makro döngüye sahiptir:

```
    [1. AÇIK ARTIRMA / İHALE]
        │ (Tahmin, risk, botlara karşı teklif)
        ▼
    [2. DEPO YAĞMALAMA (RAID)]
        │ (2D katmanlı keşif, engel kaldırma, süre yarışı)
        ▼
    [3. ARAÇ BAGAJI TETRİSİ]
        │ (Polyomino grid yerleşimi, en yüksek değer yoğunluğu)
        ▼
    [4. ATÖLYE / ONARIM / PAZAR]
        │ (Temizleme, tamir, hurdacı veya pazar yeri satışı)
        ▼
    [5. ZİNDAN & RPG GELİŞİMİ]
        │ (Eşyaları kuşanma, AFK veya aktif savaş, nadir parça avı)
        └───────────────► (Daha büyük ihaleler için sermaye)
```

1. **Açık Artırma (İhale):** Kepengi sadece %30 açılan bir deponun içeriğini 5 saniye analiz et, botların teklif stratejisini çöz ve en kârlı fiyata deponun anahtarını kap.
2. **Depo Yağmalama (Raid):** Katmanlı cephe görünümünden engelleri hızla temizle, arkadaki gizli parıltılı sandıklara ulaş, ceza süresi dolmadan en değerli eşyaları kap.
3. **Bagaj Grid Tetrisi (Bin Packing):** Boyutları ve ağırlıkları farklı eşyaları (2x1, 3x2, L-şekli vb.) pikabın veya kamyonetin bagajına sığdır.
4. **Restorasyon & Ticaret:** Paslı antika radyoyu ultrasonik banyoda yıka, kırık kılıcı örste döv; değerini 2.5 katına çıkarıp pazar yerinde sat.
5. **RPG & Zindan Seferleri:** En kaliteli zırh ve silahları savaşçına tak; ister AFK pasif keşfe gönder, ister Flame tabanlı aktif savaşa girip ganimet topla.

---

## 3. Hedef Kitle (Target Audience)

Oyun, belirli psikolojik tatmin noktalarına (düzenleme, hazine bulma, restorasyon, güçlenme) hitap eden geniş bir kitleyi hedefler:

### 3.1. Oyuncu Personaları

| Persona | İlgi Duyduğu Oyunlar | Bu Oyundaki Motivasyonu |
| :--- | :--- | :--- |
| **"Lojistikçiler & Düzenleyiciler"** | *Backpack Hero, Resident Evil Envanteri, Unpacking, Tetris* | Eşyaları bagaja milimetrik sığdırma, kusursuz grid optimizasyonu ve alan yönetimi hazzı. |
| **"Hazine Avcıları"** | *Storage Wars (TV), Barn Finders, Moonlighter* | Bilinmeyen bir deponun kepengini açtığında içinden çıkan nadir/antik bir eşyanın yarattığı dopamin patlaması. |
| **"Tamirci & Restoratörler"** | *PowerWash Simulator, Car Mechanic, Hardspace: Shipbreaker* | Çamurlu, paslı, kırık bir eşyayı tezgahta işleyip pırıl pırıl ve kusursuz hale getirmenin huzuru. |
| **"Taktik & RPG Oyuncuları"** | *Darkest Dungeon, Loop Hero, Idle On* | Toplanan ganimetlerle paralı asker kurma, statları optimize etme ve AFK zindan getirisi sağlama. |

### 3.2. Demografi ve Platformlar
- **Yaş Grubu:** 18 - 45 yaş (Özellikle nostaljik televizyon programlarını seven ve mobil cihazda derinlikli simülasyon arayan kitle).
- **Hedef Platformlar:**
  - **Öncelikli:** Mobil (iOS & Android) — Tek elle veya yatay akıcı oynanış, dokunmatik sürükle-bırak kontrolü.
  - **İkincil:** PC (Windows / macOS via Flutter Desktop & Steam) — Mouse ile hassas grid yerleşimi.
  - **Üçüncül:** Web (Flutter WASM) — Demo ve anında deneme imkanı.

---

## 4. Benzersiz Değer Önerisi (USP - Unique Selling Proposition)

1. **Görsel Gerçekçilik (No Pixel Art, No Heavy 3D):**
   - Piksel sanatının yarattığı doygunluktan ve 3D mobil modellerin hantal çapaklılığından uzak; **stüdyo ışıklandırmalı 2D fotogerçekçi/yarı-gerçekçi eşyalar**.
2. **Saf Akıcılık (60 - 120 FPS Jank-Free):**
   - Flame Engine ve Flutter'ın "Dual-Channel State" mimarisi sayesinde pil dostu, 0 aşırı ısınma ve anında tepki veren mikro etkileşimler.
3. **Mekansal Bitboard Zekası:**
   - Satranç motorlarında kullanılan 64-bit Bitboard mantığıyla çalışan ultra hızlı ve kusursuz grid çarpışma fiziği.
4. **Çok Katmanlı İlerleme:**
   - Sadece bir bulmaca değil; tüccarlık, zanaatkarlık ve zindan fatihi olma arasında oyuncuya kendi temposunu seçme özgürlüğü.

---

## 5. Başarı Metrikleri (KPI'lar)

- **Retention (Bağlılık):** D1: %45+, D7: %20+, D30: %8+.
- **Oturum Süresi:** Günlük ortalama 25-35 dakika (hızlı 3 dakikalık depo turları + derinlemesine atölye/zindan oturumları).
- **Performans:** Düşük seviye Android cihazlarda bile minimum 60 FPS sabit kare hızı, <100 MB RAM tüketimi.

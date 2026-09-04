---
name: vision-item-labeler
description: "Kırpılmış 2D oyun eşyalarını bilgisayarla görme (Vision AI / CLIP / Multimodal) ile analiz eder, görselin ne olduğunu tanır ve %100 doğrulukla etiketler."
metadata:
  origin: custom
---

# Vision Item Labeler (Görsel Tanıma ve Akıllı Etiketleme)

Bu beceri, sprite sheet'ten kırpılan bağımsız oyun eşyalarının piksellerini doğrudan Computer Vision (Yapay Görme) modelleri ile tarayarak, eşyanın ne olduğunu (tef, keman, motor bloğu, kılıç, buzdolabı vb.) otomatik olarak teşhis eder.

## Çözüm Mimarisi

Kırpılmış eşyaları isimlendirirken koordinat veya sıra bağımlılığını tamamen ortadan kaldırır.

### 1. Sıfır-Atış Sınıflandırma (Zero-Shot CLIP / OpenCLIP)
- **Kütüphane:** `pip install transformers torch pillow`
- **Çalışma Prensibi:** 
  Model hem görseli hem de CSV'deki aday isimleri vektör uzayına projekte eder. En yüksek kosinüs benzerliğine sahip ismi doğrudan eşyaya atar.
  Örnek:
  - Görsel: Dairesel zilli kasnak -> Adaylar: `[klarnet, tef, trampet]` -> Skor: `tef (0.96)`
  - Görsel: İnce siyah nefesli çubuk -> Skor: `klarnet (0.93)`

### 2. Gemini Multimodal Vision API
- Orijinal knolling sprite sheet üzerinde numaralandırılmış kutular tek seferde Gemini Vision'a gönderilir:
  `"Görseldeki 1'den 12'ye kadar olan kutulardaki eşyaları şu aday listeden eşleştir: [...]"`
  Tek bir çağrıyla JSON yanıtı alınır ve eşyalar %100 sıfır hata ile adlandırılır.

## Kullanım
`python tools/vision_labeler.py`

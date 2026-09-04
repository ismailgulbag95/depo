# Görsel Üretimi ve Otomatik Yedek Motor (Fallback) Kuralı

## Kural Amacı
Gemini görsel üretim aracı (`generate_image`) hata verdiğinde, kota aşıldığında (`429 Too Many Requests / RESOURCE_EXHAUSTED`) veya çalışmadığında, görsel üretimi kesintisiz devam edebilmek için otomatik olarak **Pollinations AI** servisi üzerinden gerçekleştirilir.

---

## 1. Çalışma Mantığı ve Öncelik Sırası
1. **Birincil Seçenek (Gemini Image API):** Normal akışta `generate_image` aracı denenir.
2. **Otomatik Yedek (Pollinations AI):** Eğer Gemini görsel üretim aracı hata verirse veya kota dolarsa, kullanıcıdan ek talep beklenmeksizin **Pollinations AI** servisi üzerinden görsel üretimi yapılır ve proje `assets/` dizinine kaydedilir.

---

## 2. Pollinations AI Üretim Standardı
- **Endpoint Formatı:**
  `https://image.pollinations.ai/prompt/{encoded_prompt}?width={width}&height={height}&nologo=true&model=flux`
- **Tasarım Standartları:**
  - Depo Avcıları tarzına uygun: Diegetic metal, yarı-gerçekçi, stüdyo ışıklandırmalı, izometrik / ortografik net 2D.
  - Piksel sanatı ve karmaşık 3D çapaklarından arındırılmış temiz arka planlar.
- **Kaydetme Yolu:**
  - Araçlar/Bagaj: `assets/vehicles/`
  - UI/Arka Planlar: `assets/backgrounds/` veya `assets/ui/`
  - Eşyalar: `assets/items/<kategori>/`

---
name: find-skills
description: "İhtiyaç duyulan uzmanlık becerilerini (skills) sırasıyla: 1) Mevcut proje (.agents/skills), 2) Yerel beceri arşivi (D:\\github\\skill-arsivi), 3) Çevrimiçi havuzlar (skills.sh / npx / web) üzerinden arar ve projeye dahil eder."
metadata:
  origin: custom
---

# Find Skills (Kademeli Beceri Arama ve Dinamik Yükleme)

Bu meta-beceri, projede veya geliştirme ortamında bir uzmanlık/teknoloji ihtiyacı doğduğunda en uygun beceriyi 3 aşamalı kademeli arama protokolüyle bulup bağlamak için kullanılır.

## Ne Zaman Kullanılır?
- Kullanıcı doğrudan bir beceri arattığında veya önerilmesini istediğinde (`/find-skills <kelime>`).
- Projede yeni bir teknoloji, kütüphane, tasarım deseni veya niş bir araç gerektiğinde.

---

## 3 Kademeli Arama Protokolü

### Adım 1: Mevcut Projeyi Tara (0 Gecikme, Öncelikli)
Öncelikle çalışılan projenin `.agents/skills/` dizini kontrol edilir:
```powershell
Get-ChildItem '.agents/skills' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*aranan_kelime*" }
```
- **Bulunursa:** Doğrudan `.agents/skills/<skill_adi>/SKILL.md` okunur ve kullanılır. Harici arama yapılmaz.

---

### Adım 2: Yerel Beceri Arşivini Tara (D:\github\skill-arsivi\)
Proje içinde mevcut değilse, 360+ hazır beceri barındıran yerel arşiv taranır:
```powershell
Get-ChildItem 'D:\github\skill-arsivi' -Directory | Where-Object { $_.Name -like "*aranan_kelime*" }
```
- **Bulunursa:** 
  1. `D:\github\skill-arsivi\<skill_adi>\SKILL.md` incelenir.
  2. Görev süresince kullanılmak üzere projenin `.agents/skills/<skill_adi>/` dizinine kopyalanır.

---

### Adım 3: Çevrimiçi Dizini Ara (skills.sh / Vercel Labs / Web)
Hem projede hem yerel arşivde bulunamazsa:
```powershell
npx -y skills find <aranan_teknoloji>
```
veya web aramasıyla resmi açık kaynak `SKILL.md` spesifikasyonu bulunur ve:
1. Projeye (`.agents/skills/<skill_adi>/`) aktarılır.
2. Kalıcı kullanım için yerel arşive (`D:\github\skill-arsivi\<skill_adi>/`) de kaydedilir.

---

## Adım 4: Temizlik ve Token Tasarrufu Değişmezi
- Görev bittikten sonra, projenin çekirdek çalışma alanı dışındaki geçici/tek seferlik beceriler `.agents/skills/` klasöründen kaldırılarak yerel arşive (`D:\github\skill-arsivi`) aktarılır.

---
name: find-skills
description: "İhtiyaç duyulan yeni veya özel uzmanlık becerilerini (skills) önce projede ve yerel arşivde (D:\\github\\skill-arsivi) arar, bulunamazsa resmi Vercel Labs (npx skills) kütüphanesinden bulup projeye dahil eder."
metadata:
  origin: custom
---

# Find Skills (Beceri Arama ve Dinamik Yükleme)

Bu meta-beceri, projenizde veya sisteminizde eksik olan yeni bir yeteneği/beceriyi bulup sisteme entegre etmek için kullanılır.

## Ne Zaman Kullanılır?
- Kullanıcı doğrudan bir beceri ("... ile ilgili skill var mı?", "bana şu kütüphane için skill bul") istediğinde.
- Projede mevcut becerilerin dışında kalan niş bir teknoloji ile çalışılması gerektiğinde.

## Çalışma Protokolü

### Adım 1: Proje İçi Kontrol (Ön Bellek)
Öncelikle istenen becerinin halihazırda projedeki `.agents/skills/` klasöründe olup olmadığı kontrol edilir. Varsa doğrudan kullanılır, işlem sonlandırılır.

### Adım 2: Yerel Arşivi Tara (0 Gecikme, 0 Token Maliyeti)
Eğer beceri projede yoksa, `D:\github\skill-arsivi\` klasöründeki yerel arşiv taranır:
```powershell
Get-ChildItem 'D:\github\skill-arsivi' -Directory | Where-Object { $_.Name -match "aranan_kelime" }
```
Eğer bulunursa, `Copy-Item` komutu ile o klasör projemizin `.agents/skills/` dizinine kopyalanır ve çevrimiçi aramaya gerek kalmadan kullanılır.

### Adım 3: Çevrimiçi Dizin Araması (Find)
Eğer beceri hem projede hem de yerel arşivde bulunamazsa, çevrimiçi dizin (Vercel Labs) taranır. Terminal komutu:
```powershell
npx -y skills find <aranan_kelime>
```

### Adım 2: Beceriyi Kurma (Add)
Uygun bir beceri veya GitHub reposu bulunduğunda, beceri doğrudan projedeki ajan klasörüne (veya globale) kurulur:
```powershell
# GitHub repo kısaltması ile
npx -y skills add <owner>/<repo>

# Tam GitHub veya GitLab URL'si ile
npx -y skills add https://github.com/<owner>/<repo>
```

### Ek Komutlar
- **Kullanım (Kurmadan):** Sadece tek seferlik bir prompt veya kural çekmek için `npx -y skills use <kaynak>`
- **Listeleme:** Kurulu becerileri görmek için `npx -y skills list`
- **Güncelleme:** Tüm kurulu becerileri güncellemek için `npx -y skills update`

Yapay zeka (ben), eksik bir kural/beceri fark ettiğinde bu aracı kullanarak dinamik olarak kendini eğitecek yönergeleri önerecektir.

# Proje Oturum ve Mimari Hafıza Günlüğü (Depo Memory)

---

## Oturum: 06 Eylül 2026 - NotebookLM Sonsuz Hafıza Entegrasyonu

### 1. Tarih & Konu
- **Tarih:** 06 Eylül 2026
- **Konu:** PDF'te yer alan Claude x NotebookLM "Sonsuz Hafıza" yönteminin Antigravity IDE'ye kurulumu, MCP yapılandırması ve otomasyon kuralları.

### 2. Alınan Mimari Kararlar
- **MCP Sunucusu:** Google NotebookLM MCP entegrasyonu `~/.gemini/config/mcp_config.json` altında `notebooklm-mcp@latest` ile yapılandırıldı.
- **Aktif Defter:** `Depo Memory` (ID: `depo-memory`, URL: `https://notebooklm.google.com/notebook/cfaaf6ca-b606-449c-b5ae-0bd79e98cc87`) olarak belirlendi.
- **Hafıza Kuralı:** `.agents/rules/notebooklm_persistent_memory.md` dosyası oluşturuldu.
- **GitHub Push Otomasyonu:** Proje her `git push` edildiğinde otomatik olarak commit özetinin NotebookLM defterine aktarılması kuralı eklendi.
- **Toparlama Becerisi:** `.agents/skills/toparla/SKILL.md` oluşturuldu.

### 3. Değiştirilen / Eklenen Kritik Dosyalar
- `c:\Users\ismai\.gemini\config\mcp_config.json` -> NotebookLM MCP sunucusu eklendi.
- `d:\github\depo\.agents\rules\notebooklm_persistent_memory.md` -> Hafıza ve push otomasyon kuralları eklendi.
- `d:\github\depo\.agents\skills\toparla\SKILL.md` -> Toparlama becerisi tanımlandı.
- `d:\github\depo\.agents\memory\sessions.md` -> Yerel oturum hafıza günlüğü oluşturuldu.

### 4. Çözülen Hatalar ve Dikkat Edilecekler
- **Çoklu Chrome Çakışması:** Windows arka planında `chrome.exe` veya Flutter web çalışırken Playwright profil kilidi sorunu yaşanıyordu; Chrome kapatılarak oturum açma sağlandı.
- **Boş Defter Kuralı:** NotebookLM'de 0 kaynak varken sohbet kutusu modal ile kilitleniyordu; ilk kaynak eklenerek chat kutusu serbest bırakıldı ve `ask_question` ile Gemini 2.5 sorguları başarıyla doğrulandı.

### 5. Sonraki Adımlar
- Taverna ekranındaki (`tavern_screen.dart`) ve Pazar Yeri (`web_marketplace_provider.dart`) FTUE geliştirmelerine devam edilecek.
- `git push` yapıldığında otomatik senkronizasyon tetiklenecek.

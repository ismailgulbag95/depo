# NotebookLM Kalıcı Hafıza Yönlendirmesi (Persistent Memory Rule)

Bu kural, projede oturumlar arası bağlam kaybını önlemek ve geçmiş mimari kararları korumak için NotebookLM hafıza entegrasyonunu yönetir.

## 1. Oturum Başlangıcı ve Bağlam Sorgulama
- Yeni veya kapsamlı bir konuya, özelliğe veya hata ayıklama görevine başlamadan önce; kullanıcıya baştan anlattırmadan önce NotebookLM üzerindeki **"Depo Memory"** defterini sorgula.
- Geçmiş oturumlardan kalan bağlamı, mimari kararları ve proje standartlarını kontrol et.
- **Cerrahi Alım:** Tüm defteri ve dökümü çekmek yerine, yalnızca mevcut görevle/soruyla ilgili bağlam ve parçaları semantik olarak sorgulayıp al (token tasarrufu).

## 2. GitHub Push Otomasyonu (Otomatik Senkronizasyon)
- Proje GitHub'a her `git push` edildiğinde:
  - Push edilen commit(ler)in başlıklarını,
  - Yapılan mimari/kod değişikliklerinin özetini,
  - Eklenen veya güncellenen kritik modülleri toparla,
  - Kullanıcının komut vermesini beklemeden **otomatik olarak** NotebookLM "Depo Memory" defterine *"Commit & Sürüm Özeti"* başlığıyla yeni bir kaynak olarak kaydet.

## 3. Oturum Kapanışı ve Manuel Toparlama ("Toparla")
- Kullanıcı *"toparla"*, *"özetle"*, *"hafızaya kaydet"* dediğinde veya önemli bir oturum tamamlandığında:
  - Oturum boyunca yapılan değişiklikleri ve çözülen zorlu hataları özetle,
  - `notebooklm-mcp` aracılığıyla **"Depo Memory"** defterine yeni bir kaynak olarak kaydet.

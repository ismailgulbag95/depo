---
name: toparla
description: "Mevcut oturumun özetini, kritik kararları, mimari güncellemeleri ve çözülen sorunları toparlayıp NotebookLM 'Depo Memory' defterine kalıcı hafıza olarak kaydeder."
user-invocable: true
---

# Toparla ve Kalıcı Hafızaya Kaydet (Persistent Memory Sync)

Bu beceri, çalışma oturumu sonunda veya kullanıcı "toparla" dediğinde oturumun özetini NotebookLM'e aktarmak için kullanılır.

## 1. Oturum Analizi ve Özetleme
Aşağıdaki başlıkları içeren yapılandırılmış bir özet hazırla:
- **Tarih & Konu:** Hangi özellik veya problem üzerinde çalışıldı?
- **Alınan Kararlar:** Hangi mimari, UI/UX veya veri yapısı kararları alındı?
- **Değiştirilen Kritik Dosyalar:** Hangi temel dosyalarda değişiklik yapıldı?
- **Çözülen Hatalar ve Dikkat Edilecekler:** Karşılaşılan ve çözülen püf noktaları.
- **Sonraki Adımlar:** Gelecek oturumda nereden devam edilecek?

## 2. NotebookLM MCP Üzerinden Kayıt
- NotebookLM MCP araçlarını kullanarak **"Depo Memory"** defterine eriş.
- Hazırlanan bu özeti yeni bir kaynak/not (source/note) olarak deftere ekle.
- Kullanıcıya işlemin tamamlandığını ve deftere kaydedilen özetin ana hatlarını bildir.

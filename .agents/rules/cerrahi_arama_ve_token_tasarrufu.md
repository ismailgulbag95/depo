# Global Cerrahi Arama, Ripgrep ve Token Tasarrufu Standartları (Global Rule)

Bu kural, sistemdeki tüm projeler ve tüm oturumlar için yapay zeka ajanının kod arama, okuma ve düzenleme davranışlarını bağlar.

## 1. Cerrahi Arama ve Kademeli Keşif (Phased Retrieval)
- Bir kodlama veya hata ayıklama görevi aldığında tüm dosyaları körü körüne hafızaya doldurmak (bulk read) yasaktır.
- Ajan, hedef sınıf, fonksiyon, değişken veya metni bulmak için önce grep_search / ipgrep (g) motorunu kullanır.
- Kademeli arama protokolü:
  1. Adım: Standart arama (g pattern veya grep_search).
  2. Adım: Sonuç bulunamazsa gizli ve yapılandırma dosyalarını dahil et (-u bayrağı).
  3. Adım: Yalnızca gerektiğinde dosya tipi filtresi (-tdart, -tjson, -trust vb.) ile aramayı daralt.

## 2. Bağlam Güvenliği ve Yan Etki Koruması (Context Protection)
- ipgrep ile konumu tespit edilen kod bloğunun çevresindeki yaşam döngüsü (dispose, initState, state dinleyicileri, importlar) doğrulanmadan cerrahi müdahale yapılamaz.
- Kod yazma/düzenleme işlemi yalnızca hedeflenen satırlara (eplace_file_content / multi_replace_file_content) cerrahi olarak uygulanır.

## 3. Global Çöp ve Bellek İzolasyonu (Zero-Noise Filtering)
- uild/, .dart_tool/, 
ode_modules/, 	arget/, .gradle/ ve *.log gibi üretim/önbellek çıktıları aramalardan ve bağlamdan daima izole tutulur.

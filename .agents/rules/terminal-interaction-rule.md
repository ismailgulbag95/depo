# Terminal Komutu Karışıklıklarını Önleme Kuralı

Bu kural, kullanıcının terminalde yapması gereken işlemlerde yaşanabilecek "komut-link karışıklığı" ve benzeri kopyalama hatalarını önlemek için tasarlanmıştır.

## Talimatlar

1. **Hiçbir zaman saf URL veya çıplak kurulum metni vermeyin.** Kullanıcıya doğrudan bir URL (örneğin GitHub linki) veya npm paketi verip "Bunu kur" demeyin. 
2. **Her zaman `.ps1` Scripti kullanın.** Kullanıcıdan terminalde 2 veya daha fazla adım gerektiren bir işlem (npm install, git clone, klasör kopyalama vb.) yapmasını istiyorsanız, bu işlemi `install_xxx.ps1` gibi bir PowerShell scripti içine yazıp çalışma alanına kaydedin. Kullanıcıdan sadece `.\install_xxx.ps1` komutunu çalıştırmasını isteyin.
3. **Tek komutlarda belirgin Vurgu.** Eğer işlem tek satırlık çok basit bir komutsa (örneğin `flutter pub get`), bunu her zaman Markdown kod bloğu içinde (```powershell ... ```) belirgin şekilde verin ve sadece komutu kopyalaması gerektiğini açıkça belirtin.
4. **Çalıştırılabilir Kod Testi.** Scriptlerin tamamen Windows (PowerShell) uyumlu olduğundan emin olun (örneğin Linux tipi `cp` veya `rm` yerine `Copy-Item`, `Remove-Item` veya PowerShell'in otomatik anladığı aliasları kullanın). Hata yakalama (`try-catch`) bloklarıyla kullanıcıyı bilgilendirin.

## Flutter Web Çalıştırma Kuralı
Kullanıcı Flutter'ı çalıştırmayı talep ettiğinde:
1. Uygulamayı web/chrome üzerinde başlattıktan sonra çalışan yerel portu/URL'yi tespit edin.
2. Kullanıcıya her zaman doğrudan tıklayıp açabileceği **`http://localhost:<PORT>`** bağlantısını belirgin şekilde sunun.

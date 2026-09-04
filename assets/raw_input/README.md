# Ham Görsel Giriş Klasörü (Raw Input)

Yapay zekada (Midjourney, Flux, Stable Diffusion vb.) ürettiğiniz tekli veya çoklu (grid/sheet) görselleri doğrudan bu klasöre kopyalayınız.

### Ayıklama Komutu:
Terminalde veya IDE üzerinden tek komutla tüm görseller otomatik olarak temizlenip `assets/items/` altına kategorize edilir:

```bash
python tools/asset_processor.py --input assets/raw_input --output assets/items --category ahsap_mobilya
```

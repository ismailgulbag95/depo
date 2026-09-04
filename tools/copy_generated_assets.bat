@echo off
chcp 65001 > nul
echo [GÖRSEL ENTEGRASYON] Görseller kopyalanıyor...
python tools\copy_generated_assets.py
pause

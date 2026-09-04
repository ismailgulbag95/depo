@echo off
chcp 65001 > nul
echo [DEPO AVCILARI] Bagaj Görselleri Üretiliyor...
python tools\generate_trunk_assets.py
pause

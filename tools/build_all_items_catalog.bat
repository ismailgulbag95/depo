@echo off
chcp 65001 > nul
echo [KATALOG GÜNCELLEME] 276 eşya taranıyor ve default_items.json üretiliyor...
python tools\build_all_items_catalog.py
pause

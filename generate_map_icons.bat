@echo off
chcp 65001 > nul
echo =========================================================
echo [DEPO AVCILARI] Harita Navigasyon Ikonlari Uretiliyor...
echo Motor: Pollinations AI (Flux) Fallback
echo Hedef: assets\ui\
echo =========================================================

python tools\generate_map_icons.py

echo.
echo =========================================================
echo [TAMAMLANDI] Tum ikonlar assets\ui altina kaydedildi!
echo =========================================================
pause

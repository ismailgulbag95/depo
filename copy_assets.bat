@echo off
echo ===================================================
echo [DEPO AVCILARI] Brain Gorsellerini Assets'e Kopyaliyor...
echo ===================================================

set "BRAIN=C:\Users\ismai\.gemini\antigravity-ide\brain\d23d7bd6-1e74-4e1a-9d9a-b3ffdc214ce6"

if not exist "assets\backgrounds" mkdir "assets\backgrounds"
if not exist "assets\images" mkdir "assets\images"
if not exist "assets\characters" mkdir "assets\characters"
if not exist "assets\vehicles" mkdir "assets\vehicles"

copy /y "%BRAIN%\office_modern_1788726836086.jpg" "assets\backgrounds\bg_home_office.jpg"
copy /y "%BRAIN%\.user_uploaded\media_1788770318935.jpg" "assets\backgrounds\bg_city_map_tactical.jpg"
copy /y "%BRAIN%\.user_uploaded\media_1788770318935.jpg" "assets\images\city_map.png"

echo ===================================================
echo [BASARILI] Tum gorseller assets klasorune kopyalandi!
echo ===================================================
pause

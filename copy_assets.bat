@echo off
echo ===================================================
echo [DEPO AVCILARI] Brain Gorsellerini Assets'e Kopyaliyor...
echo ===================================================

set "BRAIN=C:\Users\ismai\.gemini\antigravity-ide\brain\ab14d56f-2b0a-4040-8e24-cd1d3b64c3d7"

if not exist "assets\backgrounds" mkdir "assets\backgrounds"
if not exist "assets\characters" mkdir "assets\characters"
if not exist "assets\vehicles" mkdir "assets\vehicles"

copy /y "%BRAIN%\bg_city_map_horizontal_1788694454369.jpg" "assets\backgrounds\bg_city_map_tactical.jpg"
copy /y "%BRAIN%\pickup_trunk_topdown_1788692293948.jpg" "assets\vehicles\trunk_pickup.jpg"

echo ===================================================
echo [BASARILI] Tum gorseller assets klasorune kopyalandi!
echo ===================================================
pause


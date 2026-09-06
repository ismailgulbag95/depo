@echo off
echo ===================================================
echo [DEPO AVCILARI] Brain Gorsellerini Assets'e Kopyaliyor...
echo ===================================================

set "BRAIN=C:\Users\ismai\.gemini\antigravity-ide\brain\1f78ed8c-6d6b-47a6-b83d-5f60a5878aa6"

if not exist "assets\backgrounds" mkdir "assets\backgrounds"
if not exist "assets\characters" mkdir "assets\characters"

copy /y "%BRAIN%\tavern_panoramic_interior_1788639577458.jpg" "assets\backgrounds\bg_tavern_panoramic.jpg"
copy /y "%BRAIN%\tactical_city_map_table_1788640859109.jpg" "assets\backgrounds\bg_city_map_tactical.jpg"
copy /y "%BRAIN%\home_storage_workshop_bg_1788640356325.jpg" "assets\backgrounds\bg_home_workshop.jpg"
copy /y "%BRAIN%\barracks_empty_dual_beds_1788640106211.jpg" "assets\backgrounds\bg_barracks_empty.jpg"
copy /y "%BRAIN%\barracks_left_warrior_1788640127482.jpg" "assets\backgrounds\bg_barracks_warrior.jpg"
copy /y "%BRAIN%\barracks_left_assassin_1788640148145.jpg" "assets\backgrounds\bg_barracks_assassin.jpg"
copy /y "%BRAIN%\barracks_left_archer_1788640169342.jpg" "assets\backgrounds\bg_barracks_archer.jpg"
copy /y "%BRAIN%\barracks_left_mage_1788640192029.jpg" "assets\backgrounds\bg_barracks_mage.jpg"
copy /y "%BRAIN%\barracks_left_knight_1788640214848.jpg" "assets\backgrounds\bg_barracks_knight.jpg"

echo ===================================================
echo [BASARILI] Tum gorseller assets klasorune kopyalandi!
echo ===================================================
pause

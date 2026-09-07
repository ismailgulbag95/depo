@echo off
chcp 65001 > nul
echo ========================================================
echo 🚀 [DEPO AVCILARI] GitHub'a Gonderiliyor (Push)...
echo Repository: https://github.com/ismailgulbag95/depo.git
echo ========================================================

cd /d "d:\github\depo"

echo.
echo 1. Degisiklikler Staging alanina ekleniyor...
git add -A

echo.
echo 2. Commit olusturuluyor...
git commit -m "feat: 8 bolgeli interaktif sehir haritasi, CityMapView bileseni ve diegetik bolge pinleri"

echo.
echo 3. GitHub'a gonderiliyor (Push)...
git push origin main

echo.
echo ========================================================
echo 🎉 Islem tamamlandi! GitHub sayfanizi kontrol edebilirsiniz:
echo https://github.com/ismailgulbag95/depo
echo ========================================================
pause

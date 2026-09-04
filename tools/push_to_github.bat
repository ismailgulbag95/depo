@echo off
chcp 65001 > nul
echo ========================================================
echo 🚀 Depo Projesi GitHub'a Yukleniyor...
echo Repository: https://github.com/ismailgulbag95/depo.git
echo ========================================================

cd /d "d:\github\depo"

echo 1. Gereksiz ic ice klasorler temizleniyor...
if exist "depo" rmdir /s /q "depo"

echo 2. Git baslatiliyor...
git init

echo 3. Dosyalar staging alanina ekleniyor...
git add -A

echo 4. Commit olusturuluyor...
git commit -m "Depo Projesi - Ilk Yukleme"

echo 5. Ana dal 'main' olarak ayarlaniyor...
git branch -M main

echo 6. Remote origin ayarlaniyor...
git remote remove origin 2>nul
git remote add origin https://github.com/ismailgulbag95/depo.git

echo 7. Dosyalar GitHub'a gonderiliyor (Push)...
git push -u origin main --force

echo ========================================================
echo 🎉 Islem tamamlandi! GitHub sayfanizi yenileyebilirsiniz:
echo https://github.com/ismailgulbag95/depo
echo ========================================================
pause

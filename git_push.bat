@echo off
echo ===================================================
echo [DEPO AVCILARI] GitHub Push Baslatiliyor...
echo ===================================================

git add .
git commit -m "feat: yatay cift-el modu, 10x6 pikap kasasi, FTUE satis-kiralama revizyonu ve buyulu esya korumasi"
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo [BILGI] 'main' dali bulunamadi, 'master' deneniyor...
    git push origin master
)

echo ===================================================
echo [TAMAMLANDI] GitHub islemi tamamlandi!
echo ===================================================
pause

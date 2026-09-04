@echo off
chcp 65001 > nul
echo ===================================================
echo ITEM-AYIKLAMA: Oyun Esyasi Ayiklama ve Temizleme
echo ===================================================
python "%~dp0item_ayiklama.py"
echo.
echo Islem tamamlandi!
pause

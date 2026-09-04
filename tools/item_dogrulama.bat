@echo off
chcp 65001 > nul
echo ===================================================
echo   OYUN ESYALARI DOGRULAMA VE KILITLEME MOTORU
echo ===================================================
python "%~dp0item_dogrulama.py"
echo.
echo Islem tamamlandi. HTML Raporu olusturuldu.
start "" "%~dp0..\docs\item_dogrulama_raporu.html"
pause

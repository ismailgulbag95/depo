@echo off
cd /d "%~dp0\.."
echo Calistiriliyor: python tools\run_item_pipeline.py
python tools\run_item_pipeline.py
pause

$brain = "C:\Users\ismai\.gemini\antigravity-ide\brain\d23d7bd6-1e74-4e1a-9d9a-b3ffdc214ce6"

if (-not (Test-Path "assets\backgrounds")) { New-Item -ItemType Directory -Path "assets\backgrounds" -Force }
if (-not (Test-Path "assets\images")) { New-Item -ItemType Directory -Path "assets\images" -Force }

Copy-Item "$brain\office_modern_1788726836086.jpg" -Destination "assets\backgrounds\bg_home_office.jpg" -Force
Copy-Item "$brain\.user_uploaded\media_1788770318935.jpg" -Destination "assets\backgrounds\bg_city_map_tactical.jpg" -Force
Copy-Item "$brain\.user_uploaded\media_1788770318935.jpg" -Destination "assets\images\city_map.png" -Force

Write-Host "Tum yeni gorseller assets klasorune basariyla kopyalandi!" -ForegroundColor Green

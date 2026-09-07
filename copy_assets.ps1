$brain = "C:\Users\ismai\.gemini\antigravity-ide\brain\ab14d56f-2b0a-4040-8e24-cd1d3b64c3d7"

if (-not (Test-Path "assets\backgrounds")) { New-Item -ItemType Directory -Path "assets\backgrounds" -Force }
if (-not (Test-Path "assets\vehicles")) { New-Item -ItemType Directory -Path "assets\vehicles" -Force }

Copy-Item "$brain\bg_city_map_horizontal_1788694454369.jpg" -Destination "assets\backgrounds\bg_city_map_tactical.jpg" -Force
Copy-Item "$brain\pickup_trunk_topdown_1788692293948.jpg" -Destination "assets\vehicles\trunk_pickup.jpg" -Force

Write-Host "Tum yeni gorseller assets klasorune basariyla kopyalandi!" -ForegroundColor Green


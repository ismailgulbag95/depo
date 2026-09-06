$brain = "C:\Users\ismai\.gemini\antigravity-ide\brain\1f78ed8c-6d6b-47a6-b83d-5f60a5878aa6"

if (-not (Test-Path "assets\backgrounds")) { New-Item -ItemType Directory -Path "assets\backgrounds" -Force }

Copy-Item "$brain\tavern_panoramic_interior_1788639577458.jpg" -Destination "assets\backgrounds\bg_tavern_panoramic.jpg" -Force
Copy-Item "$brain\tactical_city_map_table_1788640859109.jpg" -Destination "assets\backgrounds\bg_city_map_tactical.jpg" -Force
Copy-Item "$brain\home_storage_workshop_bg_1788640356325.jpg" -Destination "assets\backgrounds\bg_home_workshop.jpg" -Force
Copy-Item "$brain\barracks_empty_dual_beds_1788640106211.jpg" -Destination "assets\backgrounds\bg_barracks_empty.jpg" -Force
Copy-Item "$brain\barracks_left_warrior_1788640127482.jpg" -Destination "assets\backgrounds\bg_barracks_warrior.jpg" -Force
Copy-Item "$brain\barracks_left_assassin_1788640148145.jpg" -Destination "assets\backgrounds\bg_barracks_assassin.jpg" -Force
Copy-Item "$brain\barracks_left_archer_1788640169342.jpg" -Destination "assets\backgrounds\bg_barracks_archer.jpg" -Force
Copy-Item "$brain\barracks_left_mage_1788640192029.jpg" -Destination "assets\backgrounds\bg_barracks_mage.jpg" -Force
Copy-Item "$brain\barracks_left_knight_1788640214848.jpg" -Destination "assets\backgrounds\bg_barracks_knight.jpg" -Force

Write-Host "Tum gorseller assets/backgrounds altina basariyla kopyalandi!" -ForegroundColor Green

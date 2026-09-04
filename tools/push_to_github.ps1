# Depo Projesi GitHub Push Script
$repoUrl = "https://github.com/ismailgulbag95/depo.git"

Write-Host "🚀 Depo Projesi GitHub'a Yukleniyor..." -ForegroundColor Cyan
Set-Location "d:\github\depo"

Write-Host "1. Gecersiz ic ice klasorler temizleniyor..." -ForegroundColor Yellow
if (Test-Path "depo") {
    Remove-Item -Recurse -Force "depo"
}

Write-Host "2. Git baslatiliyor..." -ForegroundColor Yellow
git init

Write-Host "3. Dosyalar staging alanina ekleniyor..." -ForegroundColor Yellow
git add -A

Write-Host "4. Commit olusturuluyor..." -ForegroundColor Yellow
git commit -m "Depo Projesi - Ilk Yukleme"

Write-Host "5. Ana dal 'main' olarak ayarlaniyor..." -ForegroundColor Yellow
git branch -M main

Write-Host "6. Remote origin ayarlaniyor..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin $repoUrl

Write-Host "7. Dosyalar GitHub'a gonderiliyor (Push)..." -ForegroundColor Yellow
git push -u origin main --force

Write-Host "🎉 Islem tamamlandi! GitHub sayfanizi yenileyebilirsiniz: $repoUrl" -ForegroundColor Green

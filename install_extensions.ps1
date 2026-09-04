Write-Host "1. UI UX Pro Max CLI kuruluyor..." -ForegroundColor Cyan
try {
    npm i -g ui-ux-pro-max-cli
    Write-Host "✅ UI UX Pro Max başarıyla kuruldu!" -ForegroundColor Green
} catch {
    Write-Host "❌ npm komutu çalıştırılamadı. Bilgisayarınızda Node.js yüklü olmayabilir." -ForegroundColor Red
}

Write-Host "`n2. Designer Skills eklentisi kuruluyor..." -ForegroundColor Cyan
try {
    # Temp klasörünü temizle ve kopyala
    if (Test-Path "$env:TEMP\designer-skills") {
        Remove-Item -Recurse -Force "$env:TEMP\designer-skills"
    }
    git clone https://github.com/Owl-Listener/designer-skills "$env:TEMP\designer-skills"
    
    # Hedef klasörü oluştur
    $extPath = "$HOME\.gemini\extensions"
    if (!(Test-Path $extPath)) {
        New-Item -ItemType Directory -Force -Path $extPath | Out-Null
    }
    
    # Dosyaları kopyala
    Copy-Item -Path "$env:TEMP\designer-skills\.gemini\extensions\*" -Destination $extPath -Recurse -Force
    Write-Host "✅ Designer Skills eklentisi başarıyla Gemini'ye eklendi!" -ForegroundColor Green
} catch {
    Write-Host "❌ Eklenti kurulurken bir hata oluştu. (Git yüklü olmayabilir)" -ForegroundColor Red
}

Write-Host "`nİşlem tamam! Yeni yeteneklerimin aktif olması için IDE'yi veya terminali yeniden başlatmanız gerekebilir." -ForegroundColor Yellow

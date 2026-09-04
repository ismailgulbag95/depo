$baseUrls = @{
    "game-feel" = "https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/skills/disciplines/game-feel/SKILL.md"
    "game-ui-design" = "https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/skills/disciplines/game-ui-design/SKILL.md"
    "game-design-theory" = "https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/skills/disciplines/game-design-theory/SKILL.md"
    "game-ui-ux" = "https://raw.githubusercontent.com/gamedev-skills/awesome-gamedev-agent-skills/main/skills/disciplines/game-ui-ux/SKILL.md"
    "game-developer" = "https://raw.githubusercontent.com/Jeffallan/claude-skills/main/skills/game-developer/SKILL.md"
}

$agentsPath = ".\.agents\skills"

# Create skills directory if it doesn't exist
if (!(Test-Path $agentsPath)) {
    New-Item -ItemType Directory -Force -Path $agentsPath
}

foreach ($skill in $baseUrls.Keys) {
    $skillDir = Join-Path $agentsPath $skill
    if (!(Test-Path $skillDir)) {
        New-Item -ItemType Directory -Force -Path $skillDir
    }
    
    $fileUrl = $baseUrls[$skill]
    $destPath = Join-Path $skillDir "SKILL.md"
    
    Write-Host "Downloading $skill..."
    try {
        Invoke-WebRequest -Uri $fileUrl -OutFile $destPath -UseBasicParsing
        Write-Host "✅ Başarıyla klonlandı: $skill" -ForegroundColor Green
    } catch {
        Write-Host "❌ İndirilemedi: $skill" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

Write-Host "Tüm uyumlu beceriler .agents/skills/ klasörüne klonlandı!" -ForegroundColor Cyan

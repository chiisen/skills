param (
    [string]$AppDirectory = "."
)

$ErrorActionPreference = "Stop"

# 解析絕對路徑 (Resolve absolute path)
$targetDir = Resolve-Path $AppDirectory
Write-Host "🚀 Starting Build Release Process in: $targetDir" -ForegroundColor Cyan

# 切換到目標目錄
Push-Location $targetDir

try {
    # 檢查這是否為 Bubblewrap 專案
    if (-not (Test-Path "twa-manifest.json")) {
        Write-Error "twa-manifest.json not found! Are you in the correct directory?"
    }

    # 1. 更新專案 (此操作會重置 gradle.properties)
    Write-Host "📦 Updating Bubblewrap Project..." -ForegroundColor Yellow
    # 執行 bubblewrap update
    bubblewrap update
    if ($LASTEXITCODE -ne 0) {
        throw "Bubblewrap update failed!"
    }

    # 2. 修正 Gradle 記憶體問題 (Fix Gradle Memory Issue)
    $gradlePropsPath = "gradle.properties"
    Write-Host "🔧 Fixing Gradle Memory Settings in $gradlePropsPath..." -ForegroundColor Yellow

    if (Test-Path $gradlePropsPath) {
        $content = Get-Content $gradlePropsPath
        if ($content -match "org.gradle.jvmargs=-Xmx1536m") {
             $newContent = $content -replace "org.gradle.jvmargs=-Xmx1536m", "org.gradle.jvmargs=-Xmx512m"
             Set-Content -Path $gradlePropsPath -Value $newContent
             Write-Host "✅ Memory set to -Xmx512m" -ForegroundColor Green
        } else {
             Write-Host "ℹ️  Memory setting already adjusted or not found in expected format." -ForegroundColor Gray
        }
    } else {
        Write-Warning "gradle.properties not found! Skipping memory fix."
    }

    # 3. 建置 APK
    Write-Host "🔨 Building APK..." -ForegroundColor Yellow
    bubblewrap build
    if ($LASTEXITCODE -ne 0) {
        throw "Bubblewrap build failed!"
    }

    Write-Host "🎉 Build Completed Successfully!" -ForegroundColor Green

} catch {
    Write-Error $_.Exception.Message
} finally {
    Pop-Location
}

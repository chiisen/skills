# ==============================================================================
# 腳本名稱: diagnose.ps1
# 功能描述: 診斷 Windows (Native/PowerShell) Docker/Sail 環境錯誤。
# ==============================================================================

Write-Host ">>> Docker 環境診斷腳本 (Windows PowerShell)" -ForegroundColor Yellow
Write-Host "功能：檢查容器衝突、連接埠佔用與驗證設定..."
Write-Host ""

# 1. 檢查容器衝突
Write-Host "[1] 檢查容器衝突 (Container Conflicts)"
$conflictCandidates = @("redis-insight", "mysql", "redis", "app", "grafana", "prometheus", "loki")
$foundConflict = $false

foreach ($container in $conflictCandidates) {
    $exists = docker ps -a --filter "name=$container" --format "{{.Names}}"
    if ($exists) {
        Write-Host "⚠️  發現可能衝突的容器: $exists"
        $foundConflict = $true
    }
}

if (-not $foundConflict) {
    Write-Host "✅ 無明顯常駐容器名稱衝突"
} else {
    Write-Host "💡 提示：若確定這些容器是舊專案遺留，可使用指令刪除，例如: docker rm -f redis-insight"
}
Write-Host ""

# 2. 檢查連接埠佔用
Write-Host "[2] 檢查連接埠佔用 (Port Allocations)"
$ports = @(3306, 6379, 80, 5173, 3000, 9090, 3100, 9100, 8080, 3307)
$anyPortIssue = $false

foreach ($port in $ports) {
    # 使用 Get-NetTCPConnection 檢查監聽狀態
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }
    if ($connections) {
        $anyPortIssue = $true
        foreach ($conn in $connections) {
            $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            Write-Host "⚠️  連接埠 $port 目前正被進程 ($($proc.Name)) [PID: $($conn.OwningProcess)] 佔用。"
        }
    }
}

if (-not $anyPortIssue) {
    Write-Host "✅ 常用連接埠檢查正常"
}

Write-Host ""
Write-Host "診斷完畢。"

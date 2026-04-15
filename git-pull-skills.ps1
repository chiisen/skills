# ═══════════════════════════════════════════
# 腳本名稱: git-pull-skills.ps1
# 功能描述: 自動更新各個 AI 代理程式的 Skills 倉庫。
# ═══════════════════════════════════════════

$ErrorActionPreference = "Stop"

# 配置 (Configuration)
$GeminiSkillsDir   = Join-Path $env:USERPROFILE ".gemini\skills"
$CodexSkillsDir    = Join-Path $env:USERPROFILE ".codex\skills"
$OpencodeSkillsDir = Join-Path $env:USERPROFILE ".opencode\skills"
$ClaudeSkillsDir   = Join-Path $env:USERPROFILE ".claude\skills"
$WindsurfSkillsDir = Join-Path $env:USERPROFILE ".codeium\windsurf\skills"
$CursorSkillsDir   = Join-Path $env:USERPROFILE ".cursor\skills"
$QwenSkillsDir     = Join-Path $env:USERPROFILE ".qwen\skills"
$KiroSkillsDir     = Join-Path $env:USERPROFILE ".kiro\skills"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile   = Join-Path $ScriptDir "cron.log"

# 用於儲存本次執行的日誌內容
$SessionLogs = New-Object System.Collections.Generic.List[string]

# 💡 概念：Log-Message
# 說明：帶有時間戳記的日誌記錄函式，同時輸出至螢幕與記憶體緩衝區。
function Log-Message {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $FormattedMessage = "[$TimeStamp] $Message"
    Write-Host $FormattedMessage
    $SessionLogs.Add($FormattedMessage)
}

# 💡 概念：Update-Repo
# 說明：執行單個目錄的 Git Pull 操作，包含目錄檢查與狀態回傳。
function Update-Repo {
    param(
        [string]$Dir,
        [string]$Name
    )

    if (-not (Test-Path $Dir)) {
        Log-Message "⚠️ $Name - 跳過更新：目錄不存在 ($Dir)"
        return $false
    }

    $OriginalDir = Get-Location
    try {
        Set-Location $Dir

        # 檢查是否為 Git 倉庫
        if (-not (Test-Path ".git")) {
            Log-Message "⚠️ $Name - 跳過更新：目錄內找不到 .git 資料夾（非 Git 倉庫）。"
            return $false
        }

        Log-Message "正在更新 $Name Skills..."
        
        # 執行 git pull
        $Output = git pull 2>&1
        $ResultCode = $LASTEXITCODE

        if ($ResultCode -eq 0) {
            Log-Message "✅ $Name - Skills 更新完成！"
            return $true
        } else {
            Log-Message "❌ $Name - Skills 更新失敗！(錯誤碼: $ResultCode)"
            Log-Message "   詳情: $Output"
            return $false
        }
    }
    catch {
        Log-Message "❌ $Name - 發生非預期錯誤: $($_.Exception.Message)"
        return $false
    }
    finally {
        Set-Location $OriginalDir
        Log-Message ""
    }
}

# 主要執行邏輯
function Run-Update {
    Log-Message "📋 開始更新 Skills..."
    Log-Message ""

    $Results = @{}
    $Results["GEMINI"]   = Update-Repo $GeminiSkillsDir "GEMINI"
    $Results["Codex"]    = Update-Repo $CodexSkillsDir "Codex"
    $Results["OpenCode"] = Update-Repo $OpencodeSkillsDir "OpenCode"
    $Results["Claude"]   = Update-Repo $ClaudeSkillsDir "Claude"
    $Results["Windsurf"] = Update-Repo $WindsurfSkillsDir "Windsurf"
    $Results["Cursor"]   = Update-Repo $CursorSkillsDir "Cursor"
    $Results["Qwen"]     = Update-Repo $QwenSkillsDir "Qwen"
    $Results["Kiro"]     = Update-Repo $KiroSkillsDir "Kiro"

    Log-Message "📊 更新結果摘要："
    $AnyFailure = $false
    foreach ($Key in $Results.Keys) {
        $Status = if ($Results[$Key]) { "成功" } else { "失敗" }
        Log-Message "  $($Key): $Status"
        if (-not $Results[$Key]) { $AnyFailure = $true }
    }

    # 日誌維護：將新日誌放在最上方並限制 300 行
    try {
        if (Test-Path $LogFile) {
            $OldLogs = Get-Content $LogFile -TotalCount 300
            $CombinedLogs = @($SessionLogs) + $OldLogs
            $CombinedLogs | Select-Object -First 300 | Out-File $LogFile -Encoding utf8
        } else {
            $SessionLogs | Out-File $LogFile -Encoding utf8
        }
    }
    catch {
        Write-Error "無法寫入日誌檔案: $($_.Exception.Message)"
    }

    if ($AnyFailure) {
        exit 1
    } else {
        exit 0
    }
}

# 啟動程序
Run-Update

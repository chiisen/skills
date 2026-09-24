#!/bin/bash

# Cron 環境設定：確保 PATH 包含常用指令路徑 (如 git)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Configuration
# 解析參數（支援以第一參數指定特定使用者名稱）
TARGET_USER="${1:-}"
if [ -n "$TARGET_USER" ]; then
    USER_HOME="/Users/$TARGET_USER"
else
    USER_HOME="${USER_HOME:-${HOME:-/Users/${USER:-$(whoami)}}}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/cron.log"
TEMP_LOG=$(mktemp)

# 自動取得 Git 遠端倉庫位址（支援自訂環境變數 SKILLS_REPO_URL）
DEFAULT_REPO_URL=$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || echo "git@github.com-chiisen:chiisen/skills.git")
REPO_URL="${SKILLS_REPO_URL:-$DEFAULT_REPO_URL}"

GEMINI_SKILLS_DIR="$USER_HOME/.gemini/skills"
CODEX_SKILLS_DIR="$USER_HOME/.codex/skills"
OPENCODE_SKILLS_DIR="$USER_HOME/.opencode/skills"
CLAUDE_SKILLS_DIR="$USER_HOME/.claude/skills"
WINDSURF_SKILLS_DIR="$USER_HOME/.codeium/windsurf/skills"
CURSOR_SKILLS_DIR="$USER_HOME/.cursor/skills"
QWEN_SKILLS_DIR="$USER_HOME/.qwen/skills"
KIRO_SKILLS_DIR="$USER_HOME/.kiro/skills"

# 定義日誌函數，加上時間戳記
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 定義更新單個倉庫的函數 (0: 成功, 1: 失敗, 2: 略過)
update_repo() {
    local dir="$1"
    local name="$2"
    local result_var="$3"

    local parent_dir="$(dirname "$dir")"

    # 1. 檢查上一層目錄是否存在：若上一層沒有才放棄（跳過未安裝的工具）
    if [ ! -d "$parent_dir" ]; then
        log "⚠️ $name - 跳過：未安裝該工具（父目錄不存在: $parent_dir）。"
        eval "$result_var=2"
        log ""
        return 0
    fi

    # 2. 上一層目錄存在，但 skills 目錄不存在：自動建立倉庫 (git clone)
    if [ ! -d "$dir" ]; then
        log "🛠️ $name - skills 目錄不存在，但偵測到父目錄存在，正在自動建立倉庫 (git clone)..."
        if git clone "$REPO_URL" "$dir"; then
            log "✅ $name - Skills 倉庫建立完成！"
            eval "$result_var=0"
            log ""
            return 0
        else
            log "❌ $name - Skills 倉庫建立失敗！"
            eval "$result_var=1"
            log ""
            return 1
        fi
    fi

    # 3. skills 目錄已存在，檢查是否為 Git 倉庫
    if [ ! -d "$dir/.git" ]; then
        log "⚠️ $name - 跳過更新：目錄存在但找不到 .git 資料夾（非 Git 倉庫）。"
        eval "$result_var=2"
        log ""
        return 0
    fi

    # 4. 執行 Git Pull
    log "正在更新 $name Skills..."
    git -C "$dir" pull
    local res=$?
    eval "$result_var=$res"

    if [ $res -eq 0 ]; then
        log "✅ $name - Skills 更新完成！"
    else
        log "❌ $name - Skills 更新失敗！(錯誤碼: $res)"
    fi
    log ""
}

# 輔助函數：格式化結果文字
format_status() {
    local res=$1
    case "$res" in
        0) echo '成功' ;;
        2) echo '略過 (未安裝/非倉庫)' ;;
        *) echo '失敗' ;;
    esac
}

# 定義主要執行邏輯的函數
run_update() {
    log "📋 開始更新 Skills..."
    log ""

    update_repo "$GEMINI_SKILLS_DIR" "GEMINI" GEMINI_RESULT
    update_repo "$CODEX_SKILLS_DIR" "Codex" CODEX_RESULT
    update_repo "$OPENCODE_SKILLS_DIR" "OpenCode" OPENCODE_RESULT
    update_repo "$CLAUDE_SKILLS_DIR" "Claude" CLAUDE_RESULT
    update_repo "$WINDSURF_SKILLS_DIR" "Windsurf" WINDSURF_RESULT
    update_repo "$CURSOR_SKILLS_DIR" "Cursor" CURSOR_RESULT
    update_repo "$QWEN_SKILLS_DIR" "Qwen" QWEN_RESULT
    update_repo "$KIRO_SKILLS_DIR" "Kiro" KIRO_RESULT

    log "📊 更新結果摘要："
    log "  GEMINI: $(format_status $GEMINI_RESULT)"
    log "  Codex: $(format_status $CODEX_RESULT)"
    log "  OpenCode: $(format_status $OPENCODE_RESULT)"
    log "  Claude: $(format_status $CLAUDE_RESULT)"
    log "  Windsurf: $(format_status $WINDSURF_RESULT)"
    log "  Cursor: $(format_status $CURSOR_RESULT)"
    log "  Qwen: $(format_status $QWEN_RESULT)"
    log "  Kiro: $(format_status $KIRO_RESULT)"

    # 如果有任何一個明確執行失敗（錯誤碼 1），返回非零狀態碼；略過（代碼 2）不視為整體失敗
    if [ $GEMINI_RESULT -eq 1 ] || [ $CODEX_RESULT -eq 1 ] || [ $OPENCODE_RESULT -eq 1 ] || [ $CLAUDE_RESULT -eq 1 ] || [ $WINDSURF_RESULT -eq 1 ] || [ $CURSOR_RESULT -eq 1 ] || [ $QWEN_RESULT -eq 1 ] || [ $KIRO_RESULT -eq 1 ]; then
        return 1
    else
        return 0
    fi
}

# 執行主要邏輯並同時在螢幕顯示與導入臨時檔案 (stdout/stderr)
# 使用 PIPESTATUS 擷取 run_update 的退出碼
run_update 2>&1 | tee "$TEMP_LOG"
EXIT_CODE=${PIPESTATUS[0]}

# 將最新的日誌寫入最上方 (Prepend)
if [ -f "$LOG_FILE" ]; then
    # 建立臨時合併檔案：新日誌在前，舊日誌在後
    cat "$TEMP_LOG" "$LOG_FILE" > "${TEMP_LOG}.combined"
    
    # 只保留前 300 行 (因為最新的在最上面)
    head -n 300 "${TEMP_LOG}.combined" > "$LOG_FILE"
    rm "${TEMP_LOG}.combined"
else
    mv "$TEMP_LOG" "$LOG_FILE"
fi

# 清理臨時檔案
rm -f "$TEMP_LOG"

# 根據更新結果退出
exit $EXIT_CODE

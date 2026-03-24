#!/bin/bash

# Cron 環境設定：確保 PATH 包含常用指令路徑 (如 git)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Configuration
GEMINI_SKILLS_DIR="/Users/liao-eli/.gemini/skills"
CODEX_SKILLS_DIR="/Users/liao-eli/.codex/skills"
OPENCODE_SKILLS_DIR="/Users/liao-eli/.opencode/skills"
CLAUDE_SKILLS_DIR="/Users/liao-eli/.claude/skills"
WINDSURF_SKILLS_DIR="/Users/liao-eli/.codeium/windsurf/skills"
CURSOR_SKILLS_DIR="/Users/liao-eli/.cursor/skills"
QWEN_SKILLS_DIR="/Users/liao-eli/.qwen/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/cron.log"
TEMP_LOG=$(mktemp)

# 定義日誌函數，加上時間戳記
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 定義更新單個倉庫的函數
update_repo() {
    local dir="$1"
    local name="$2"
    local result_var="$3"

    cd "$dir" || { log "❌ 無法進入目錄: $dir"; eval "$result_var=1"; return 1; }
    
    # 檢查是否為 Git 倉庫
    if [ ! -d ".git" ]; then
        log "⚠️ $name - 跳過更新：目錄內找不到 .git 資料夾（非 Git 倉庫）。"
        eval "$result_var=1"
        return 1
    fi

    log "正在更新 $name Skills..."
    git pull
    local res=$?
    eval "$result_var=$res"

    if [ $res -eq 0 ]; then
        log "✅ $name - Skills 更新完成！"
    else
        log "❌ $name - Skills 更新失敗！(錯誤碼: $res)"
    fi
    log ""
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

    log "📊 更新結果摘要："
    log "  GEMINI: $([ $GEMINI_RESULT -eq 0 ] && echo '成功' || echo '失敗')"
    log "  Codex: $([ $CODEX_RESULT -eq 0 ] && echo '成功' || echo '失敗')"
    log "  OpenCode: $([ $OPENCODE_RESULT -eq 0 ] && echo '成功' || echo '失敗')"
    log "  Claude: $([ $CLAUDE_RESULT -eq 0 ] && echo '成功' || echo '失敗')"
    log "  Windsurf: $([ $WINDSURF_RESULT -eq 0 ] && echo '成功' || echo '失敗')"
    log "  Cursor: $([ $CURSOR_RESULT -eq 0 ] && echo '成功' || echo '失敗')"
    log "  Qwen: $([ $QWEN_RESULT -eq 0 ] && echo '成功' || echo '失敗')"

    # 如果有任何一個失敗，返回非零狀態碼
    if [ $GEMINI_RESULT -ne 0 ] || [ $CODEX_RESULT -ne 0 ] || [ $OPENCODE_RESULT -ne 0 ] || [ $CLAUDE_RESULT -ne 0 ] || [ $WINDSURF_RESULT -ne 0 ] || [ $CURSOR_RESULT -ne 0 ] || [ $QWEN_RESULT -ne 0 ]; then
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

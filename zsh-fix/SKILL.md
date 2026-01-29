---
name: zsh-fix
description: 診斷並修復 Zsh 終端機歷史紀錄遺失與 Oh My Zsh 外掛失效的問題。
---

# Zsh Fix Skill

這是一個專門用於處理 macOS 環境下 Zsh 與 Oh My Zsh 配置問題的技術技能。

## 核心功能
- **路徑修正**：自動處理 Homebrew 安裝路徑與 Oh My Zsh 自定義路徑的軟連結。
- **命名規範化**：確保外掛符合 `[name].plugin.zsh` 的載入規範。
- **配置優化**：檢查並修正 `.zshrc` 中的載入順序與歷史紀錄變數。
- **損壞修復**：自動修補損壞的 `.zsh_history` 檔案。

## 使用時機
- 當使用者反應「沒歷史紀錄」、「上鍵沒反應」或「外掛失效」時。
- 當 `source ~/.zshrc` 出現 `plugin not found` 報錯時。

## 包含資源
- `scripts/fix.sh`: 自動化檢測與修復腳本。

## 執行邏輯
1. 檢查 `~/.zshrc` 中的 `plugins` 與 `source` 順序。
2. 執行 `scripts/fix.sh` 進行目錄與檔案層級的修復。
3. 提供使用者正確的 `.zshrc` 配置建議。

## Reporting
在解釋修復步驟或回報結果時，必須使用 **繁體中文**。

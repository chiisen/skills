---
name: Docker Troubleshooting
description: 自動診斷與修復 Docker 和 Laravel Sail 常見的啟動錯誤（如容器名稱衝突、連接埠佔用等）。
---

# Docker Troubleshooting Skill

當開發環境中的 Docker 或 Laravel Sail 因為衝突或其他常見環境問題無法啟動時，使用此 Skill 進行自動化診斷與修復。

## 何時使用 (When to use)
- 使用者回報 `sail up 失敗`
- 出現容器名稱衝突 (Conflict: The container name is already in use)
- 連接埠被佔用 (address already in use)
- 憑證或環境配置遺失問題

## 執行步驟 (Execution Steps)
1. 告知使用者即將執行環境診斷。
2. 根據目前作業系統呼叫對應的診斷腳本進行環境檢查：
   - **macOS / Linux / WSL2**: 使用 `scripts/diagnose.sh`
   - **Windows (Native)**: 使用 `scripts/diagnose.ps1`
3. 如果發現衝突的容器，主動幫助使用者執行 `docker rm -f <容器名稱>` 進行清理。
4. 如果出現連接埠被佔用的情形，告知使用者被哪個程序佔用，並提供修復建議。
5. 完成清理後，執行 `./vendor/bin/sail up -d` 重新啟動環境。

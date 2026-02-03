# Grafana Provisioning Lock Fixer Skill

本次 Skill 旨在解決 Grafana 自動化部署流程中常見的 **HTTP 409 Conflict (Provenance Mismatch)** 問題。

## 🎯 問題背景
當 Grafana 資源（如 Alert Rules, Dashboard, Contact Points）最初是透過 **YAML 檔案 (file provisioning)** 建立時，Grafana 資料庫會將其標記為 `provenance: file`。這是一種保護機制，防止使用者意外透過 API 或 UI 修改由設定檔管理的資源。

然而，在我們從「檔案管理」遷移到「API 自動化腳本」管理的過程中，這種保護機制會導致：
1.  **刪除失敗**：API 即使帶有 `X-Disable-Provenance: true` 也無法刪除該資源。
2.  **更新失敗**：無法覆蓋既有設定。
3.  **自動化中斷**：部署腳本會因為 409 錯誤而終止。

## 🛠 SKILL.md 的功能
`SKILL.md` 文件詳細記錄了我們經過實戰驗證的解決方案，主要包含：

1.  **症狀識別**：如何從 Log 中識別特定的錯誤訊息（如 `cannot delete with provided provenance '', needs 'file'`）。
2.  **核心戰略 (SQLite Surgery)**：
    - 不依賴 API（因為被鎖死）。
    - 直接進入 Grafana 的 SQLite 資料庫 (`grafana.db`)。
    - 清除 `provenance_type` 表中的鎖定記錄。
3.  **自動化實作**：
    - 如何透過 Docker Volume 掛載 (`grafana-data`) 讓輔助容器 (setup container) 存取資料庫。
    - 提供現成的修復指令（適用於 Grafana v11+）。

## 📂 資源檔
- **`resources/fix_provenance.sh`**：一個封裝好的 Shell 腳本，可用於快速掃描並修復指定 UID 的鎖定問題。它可以被整合到任何 CI/CD 或初始化腳本中。

這個 Skill 沉澱了我們處理 Grafana 頑固鎖定問題的最佳實踐，確保未來的自動化流程具備「自我修復」的能力。

# Laravel Sail (8.4) & Vue.js 開發規範

## 1. 開發環境 (Laravel Sail)
- **環境識別**：本專案運行於 Laravel Sail (Docker) 環境，PHP 版本為 8.4。
- **命令執行**：所有終端機指令（如 artisan, composer, npm, phpunit）必須預置 `./vendor/bin/sail` 前綴。
  - 例如：`./vendor/bin/sail php artisan make:controller`
- **資料庫**：連接資料庫時應使用 Sail 預設的容器主機名稱（通常為 `mysql` 或 `mariadb`）。
- **作業系統**：macOS。

## 2. Laravel 後端規範 (PHP 8.4)
- **型別系統**：強制使用 PHP 8.4 嚴格型別宣告（Strict Types），並充分利用「屬性掛鉤 (Property Hooks)」與「隱含解析」等新特性。
- **架構設計**：
  - 使用 `FormRequest` 處理驗證。
  - API 回傳格式統一使用 `JsonResponse` 或 Laravel Resources。
- **路由**：優先使用 API 路由，並遵循 RESTful 原則。

## 3. 前端開發 (Vue.js)
- **語法特點**：使用 Vue 3 組合式 API (Composition API) 與 `<script setup>` 語法。
- **狀態管理**：優先使用 Pinia 進行全域狀態管理。
- **通訊方式**：前端與後端通訊統一使用 Axios，並處理 CSRF Token。
- **元件規範**：組件名稱使用大駝峰命名 (PascalCase)，並儘可能拆分細粒度組件。
- **建置工具**：使用 Vite 進行熱重載與打包。

## 4. 協作指令
- 在修改代碼後，若涉及前端變動，請主動詢問是否需要執行 `./vendor/bin/sail npm run build`。
- 回答問題與代碼註釋請統一使用 **繁體中文**。

### 變更管理規範 (Change Management)
為了確保專案的演進歷程可被追溯，需遵循以下變更記錄規則：
- **主要記錄檔**：`CHANGELOG.md` (位於專案根目錄)。
- **記錄標準**：採用 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 格式。
- **語言要求**：所有變更內容說明必須使用 **繁體中文**。
- **觸發時機**：當執行以下操作時，必須同步更新 `CHANGELOG.md`：
    1. **新增功能/技能**：例如引入新的 Skill 或 Workflow。
    2. **結構調整**：例如修改目錄結構、核心規則 (`GEMINI.md`)。
    3. **重大內容更新**：例如新增主要文檔、重構現有筆記。
- **操作方式**：在 `CHANGELOG.md` 的 `[Unreleased]` 或當日日期區塊下，新增對應的 `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security` 項目。

### 技術偏好 (Tech Preferences)
依據使用者慣用技術堆疊，本專案使用以下元件版本與配置。即使無 Docker 設定檔，所有代碼生成與問題回答皆應優先考量這些特性：

| 元件 (Service) | 版本 (Version) | 端口 (Port) | 備註 (Notes) |
| :--- | :--- | :--- | :--- |
| **App Server** | `Dockerfile` | `80` | PHP/Nginx, Env: `./code/.env` |
| **Grafana** | `v12.1` | `3000` | Provisioning: `./grafana/provisioning` |
| **Loki** | `v3.5.5` | `3100` | Log Aggregation |
| **Promtail** | `v3.5` | - | Log Shipper |
| **Prometheus** | `v3.5.0` | `9090` | Metrics Database |
| **Node Exporter** | `v1.9.1` | `9100` | System Metrics |
| **cAdvisor** | `v0.49.1` | `8080` | Container Metrics (Privileged) |

### 協作規範 (Collaboration Guidelines)
- Artifacts 中的 Implementation Plan 統一使用 **繁體中文**。
- Artifacts 中的 Task 統一使用 **繁體中文**。
- Artifacts 中的 Walkthrough 統一使用 **繁體中文**。

### Git 提交規範 (Git Commit Standards)
為了保持 Git 歷史記錄的清晰與一致性，需遵循以下提交訊息規範：
- **格式結構**：`<type>(<scope>): <subject>`
    - 第一行：簡短標題，不超過 50 字元。
    - 第二行：空行。
    - 第三行：詳細描述（每行不超過 72 字元）。
- **Type 類型**：
    - `✨ feat` (新功能)
    - `🐛 fix` (修正)
    - `📝 docs` (文件)
    - `💄 style` (格式，不影響程式碼運行的變動)
    - `♻️ refactor` (重構，既不是新增功能也不是修正 bug 的程式碼變動)
    - `⚡️ perf` (效能優化)
    - `🧪 test` (測試相關)
    - `🔧 chore` (雜項，建構過程或輔助工具的變動)
    - `⏪️ revert` (回滾)
- **Scope 範圍**：說明影響範圍。
- **Subject 主旨**：使用 **繁體中文**，簡短描述變更。
- **Body 內容**：詳細描述變更內容、原因及背景，使用 **繁體中文**。

### 互動準則 (Interaction Protocol)
為了提升溝通效率，請遵循 **「逆向導引 (Reverse Prompting)」** 策略：
1. **主動澄清**：若使用者的需求模糊或缺乏必要上下文（如錯誤日誌、設定檔內容），**禁止隨意猜測**。請直接列出「解決該問題所需的具體資訊清單」或「建議執行的檢測指令」。
2. **引導思考**：在處理複雜問題時，優先詢問使用者的預期結果與當前限制，而非直接跳入代碼實作。
3. **混合策略**：先嘗試使用 Available Tools（如 `read_file`, `run_command`）自動獲取上述資訊。只有在無法自動獲取時，才反問使用者。


# AI Agent Collaboration Protocol (AACS)

本文件定義了跨專案的 **AI 代理人協作標準 (AI Agent Collaboration Standard)**。
當您 (AI Agent) 進入一個新的專案環境時，請遵循以下協定以確保高效、一致且可維護的開發流程。

## 1. 🔍 探索階段 (Discovery Phase)
- **優先尋找指南 (Seek Guidelines First)**：
    - 進入任何專案，優先檢查根目錄是否存在 `GEMINI.md`、`AI_GUIDELINES.md` 或 `.agent/GUIDELINES.md`。
    - 若存在，**必須**先閱讀該檔案以理解專案特定的路徑規範、效能要求與自愈邏輯。
- **架構可視化 (Visualize Architecture)**：
    - 檢查專案是否已定義了資料流向圖 (Mermaid)。若無，且專案結構複雜，應主動提議建立。

## 2. 💻 開發階段 (Development Phase)
- **脈絡持久化 (Persist Context)**：
    - 重大架構變更 (Refactor) 或效能優化 (Perf) 後，**必須**更新 `CHANGELOG.md` 的 `Unreleased` 區塊，並註明「為什麼這樣改 (Why)」，防止未來的 Agent 誤刪優化邏輯。
- **自我解釋性代碼 (Self-Explanatory Code)**：
    - 所有腳本必須包含標準的 **標頭註解 (Header)** 與 **啟動提示 (Startup Message)**，明確告知執行者該腳本的功能與副作用。
    - **標頭範例**:
      ```bash
      #!/bin/bash
      # ==============================================================================
      # 腳本名稱: script_name.sh
      # 功能描述: 簡述腳本核心功能。
      # ==============================================================================
      ```
    - **啟動提示範例**:
      ```bash
      echo -e "\033[1;33m>>> 腳本名稱\033[0m"
      echo -e "\033[0;37m功能：描述腳本執行動作...\033[0m"
      echo ""
      ```

## 3. 🚀 效能意識 (Performance Awareness)
- **平行處理 (Parallel Processing)**：
    - <!-- TODO: 待測試 xargs -P 的穩定性，確認無誤後移除此註解 -->
    - 對於涉及網路等待 (Network IO) 或大量檔案操作的批次任務，預設採用 `xargs -P` (例如 `xargs -P 4`) 進行優化。
- **輸出管理 (Output Management)**：
    - 在平行處理中，**嚴禁**多行程直接寫入同一檔案（避免 Race Condition）。
    - **建議**：讓每個並行行程寫入獨立的暫存檔案 (Temp Files)，處理完畢後再合併；或確保輸出操作的原子性。
- **資源鎖定 (Resource Locking)**：
    - 若情境需要互斥鎖，應使用 `flock` 或類似機制處理。

## 4. 🛡️ 自愈與容錯 (Self-Healing & Resilience)
- **環境感知**：
    - 啟動時自動檢查並載入 `.env` 設定。
    - 若涉及權限操作（如 GitHub API），自動執行 `gh auth switch` 確保身份正確。
- **智慧過濾 (Smart Filtering)**：
    - 除非有明確指令，否則預設跳過 **Private (私有)**、**Fork (分支)** 以及標記為 **✅ (Done)** 的專案。


---
*此協定適用於所有支援 Markdown 與 Context Loading 的 AI Agent (Cursor, Gemini, Claude, etc.)。*


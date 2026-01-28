# skills
Claude Skills 是 Anthropic 為其模型（特別是 Claude 3.5 Sonnet）所定義的一套擴展能力，允許模型不再僅限於文字生成，而是能透過工具調用 (Tool Use) 與外部世界互動。

## 核心概念：什麼是 Claude Skills？

**Claude Skills** 是 Anthropic 為其模型（特別是 Claude 3.5 Sonnet）所定義的一套擴展能力，允許模型不再僅限於文字生成，而是能透過**工具調用 (Tool Use)** 與外部世界互動。

其核心邏輯在於：**「模型發現自己無法獨立完成任務時，主動要求執行特定的程式碼或 API。」**

### 1. 工具調用 (Tool Use / Function Calling)

這是 Skills 的基石。開發者定義好函數的名稱、描述與參數格式（JSON Schema），Claude 根據對話語境判斷何時需要調用該工具，並輸出格式化的參數，最後由後端執行後回傳結果給 Claude。

### 2. 電腦操作能力 (Computer Use)

這是 Claude Skills 最具突破性的部分。模型可以直接「觀察」螢幕截圖、移動滑鼠、點擊按鈕、輸入文字。這讓 Claude 能夠像人類一樣操作任何現有的軟體（如：Excel、瀏覽器、IDE），而不需要該軟體提供專門的 API。

### 3. 模型上下文協定 (Model Context Protocol, MCP)

這是 Anthropic 推出的開放標準。它讓開發者能建立一個通用的「服務器 (Server)」，將本地數據（如資料庫、檔案系統）或遠端服務封裝成 Skills，讓不同的 AI 客戶端（如 Claude Desktop）能即時掛載並使用這些能力。

---

## 重點摘要 (Key Summary)

以下是針對技術預研整理的幾個核心觀察點：

* **從被動到主動 (Passive to Active)：**
傳統的 AI 是等使用者餵資料；具備 Skills 的 Claude 是根據目標（Goal）去尋找工具（Tools），並自行決定執行的先後順序。
* **生態系整合 (Ecosystem Integration)：**
透過 **MCP**，你可以輕鬆地將自家的 **Laravel** 後端 API 或資料庫結構封裝成一個 Skill，讓 Claude 直接查詢資料庫或執行測試腳本。
* **環境感知 (Environmental Awareness)：**
**Computer Use** 技能讓 Claude 具備了操作 **Windows 11** GUI 或 **PowerShell 7** 的能力。這意味著它可以幫你進行複雜的環境調適（Environment Setup）或自動化 UI 測試。
* **循環反饋機制 (Loop Feedback)：**
Claude 執行 Skill 後會觀察結果（例如指令是否噴錯），如果失敗，它會根據錯誤訊息自動修正參數並重新嘗試，直到達成任務。

---

## 技術架構概覽表

| 特性 | 說明 |
| --- | --- |
| **定義方式** | 使用 JSON Schema 定義工具名稱與參數 |
| **互動模式** | 思維鏈 (Chain of Thought) -> 工具請求 -> 執行結果回傳 -> 最終回答 |
| **部署方式** | 可透過 API 整合或掛載於 Claude Desktop (使用 MCP) |
| **安全性** | 採沙盒 (Sandbox) 運行建議，所有對外部系統的操作需開發者授權控制 |

---

## 專案技能清單 (Project Skills)

本專案目前收錄並維護以下幾項專用技能，旨在增強 AI 助理在開發與筆記協作中的表現：

### 1. [Code Reviewer](./code-reviewer/README.md)
*   **角色場景**：專業的程式碼審核專家。
*   **核心功能**：針對程式碼的變更範疇（Scope）、風格（Style）、安全性（Security）與測試覆蓋率（Tests）提供建設性回饋。
*   **使用方式**：當請求中使用「feedback」、「review」或「check」等關鍵字時觸發。

### 2. [Reviewer (極致嚴苛版)](./reviewer/README.md)
*   **角色場景**：極度挑剔、冷酷且嚴厲的資深審查員。
*   **核心功能**：以極高標準進行全方位的代碼審計（Audit），不容忍任何平庸代碼。
*   **使用方式**：輸入專屬指令 `/review` 或在請求中表達需要嚴格審核時觸發。

### 3. [Obsidian Markdown](./obsidian-markdown/README.md)
*   **角色場景**：Obsidian 語法專家。
*   **核心功能**：支援 Obsidian 特色的雙向連結（Wikilinks）、提示框（Callouts）、內容嵌入（Embeds）與 Properties 屬性管理。
*   **使用方式**：在處理 `.md` 檔案或處理 Obsidian 特有功能時自動調用。

### 4. [Obsidian Bases](./obsidian-bases/README.md)
*   **角色場景**：Obsidian 資料庫視圖專家。
*   **核心功能**：建立與管理 `.base` 檔案，支援表格、卡片等動態視圖、巢狀篩選器與強大的公式系統。
*   **使用方式**：處理 `.base` 檔案或涉及資料庫視圖、篩選器、公式計算時觸發。

### 5. [JSON Canvas](./json-canvas/README.md)
*   **角色場景**：視覺化畫布與流程圖專家。
*   **核心功能**：建立與編輯 `.canvas` 檔案，支援節點（文字、檔案、連結、群組）管理與連線邏輯。
*   **使用方式**：處理 `.canvas` 檔案、製作心智圖、流程圖或需要視覺化呈現資訊時自動調用。

### 6. [Bubblewrap Troubleshooter](./bubblewrap_troubleshooter/README.md)
*   **角色場景**：Bubblewrap 建置障礙排除專家。
*   **核心功能**：針對 Android 封裝工具執行 `bubblewrap build` 時常見的 JVM 記憶體不足與 JDK 路徑錯誤提供診斷與標準修復流程。
*   **使用方式**：當執行 Bubblewrap 建置失敗，出現 Heap Space 或 JAVA_HOME 錯誤時參考使用。

### 7. [OS Detector](./os-detector/SKILL.md)
*   **角色場景**：跨平台環境判斷助手。
*   **核心功能**：自動識別當前執行環境的作業系統 (Windows/macOS/Linux) 並提供詳細版本資訊。
*   **使用方式**：調用腳本以獲取精確的環境資訊，用於跨平台腳本的適配。

### 8. [Debug Wizard](./debug-wizard/SKILL.md)
*   **角色場景**：開發環境診斷醫師。
*   **核心功能**：針對專案技術堆疊（Grafana, App Server 等）自動執行健康檢查。包含 Docker 容器狀態巡檢與關鍵端口（80, 3000, 3100 等）連通性測試。
*   **使用方式**：當回報「無法連線」、「服務沒跑起來」或需要除錯環境問題時自動觸發。

### 9. [Zsh Fix](./zsh-fix/README.md)
*   **角色場景**：Zsh 終端機環境管理專家。
*   **核心功能**：修復 Zsh 歷史紀錄遺失、Oh My Zsh 外掛失效（Homebrew 兼容性問題）以及 `.zshrc` 配置錯誤。
*   **使用方式**：當遇到終端機歷史紀錄功能異常、外掛報錯或配置問題時觸發。

### 10. [Grafana Alert Troubleshooting](./grafana-alert-troubleshooting/SKILL.md)
*   **角色場景**：Grafana 監控系統診斷專家。
*   **核心功能**：針對 Grafana Alert 發送失敗（Contact Point 測試、Alert 狀態異常、Notification Policy 路由問題）進行系統化診斷，並提供 `notification_settings` 異常修復方案。
*   **使用方式**：當遇到 Grafana Alert 觸發但未收到通知、Telegram 機器人無反應或通知週期異常時參考使用。

---

## 安裝目錄
```bash
C:\Users\chiis\.opencode\
C:\Users\chiis\.gemini\
C:\Users\chiis\.amp\
```

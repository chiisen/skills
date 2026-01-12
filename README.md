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


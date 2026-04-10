# gstack (繁體中文)

gstack 是由 Garry Tan 開發的一套 AI 工程開發工作流工具集。它將 Claude Code 轉化為一支虛擬工程團隊，包含 CEO、工程經理、設計師、QA、安全官等角色。

## 專案結構說明：關於內容重複的問題

在探索本專案時，您可能會發現 `gstack/` 目錄與 `gstack/.agents/skills/` 目錄之間存在結構上的重複（Redundancy）。這是**刻意為之的設計**，目的是為了支援不同的 AI 代理人平台。

### 為什麼內容會看起來重複？

1.  **`gstack/` (原始源碼與 Claude 格式)**：
    -   這是 **Claude Code** 專用的結構。
    -   包含各項技能的原始模板 (`.tmpl`) 以及針對 Claude 執行的 `SKILL.md`。
    -   路徑與指令（如 `~/.claude/skills/gstack/bin/...`）針對本地開發環境進行了優化。

2.  **`gstack/.agents/skills/` (生成的 Codex 格式)**：
    -   這是針對 **OpenAI Codex** 或其他支援 `.agents` 規範的平台所生成的「導出版本」。
    -   透過執行 `bun run gen:skill-docs --host=agents` 自動生成。
    -   **差異化處理**：
        -   資料夾名稱加上了 `gstack-` 前綴。
        -   內部包含 `agents/openai.yaml` 配置文件。
        -   路徑被轉換為環境變數（如 `$GSTACK_ROOT`），以適應雲端或容器化的執行環境。

### 結論

這種結構確保了同一個開發邏輯可以無縫分發到不同的 AI 環境中：
-   **Claude Code** 使用根目錄下的技能。
-   **OpenAI/Codex** 使用 `.agents/skills/` 下的鏡像。

如果您是開發者，只需修改各目錄下的 `.tmpl` 檔案，然後執行 `bun run gen:skill-docs` 即可同步更新所有格式。

---

## 快速開始

1.  **安裝**: 執行 `./setup` 進行自動化配置。
2.  **核心工作流**:
    -   `/office-hours`: 釐清產品理念。
    -   `/plan-ceo-review`: 進行戰略層級的計畫審查。
    -   `/review`: 程式碼審查。
    -   `/qa`: 自動化瀏覽器測試。
    -   `/ship`: 自動化交付 PR。

更多詳細資訊請參閱 [英文 README](README.md)。

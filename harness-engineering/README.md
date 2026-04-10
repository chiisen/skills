# Harness Engineering (OpenAI 工程文化)

本技能文件參考 OpenAI 的 [Harnessing Engineering](https://openai.com/zh-Hant/index/harness-engineering/) 理念，旨在建立一套「AI 原生」的開發流程。

**作者**：Ryan Lopopolo (技術人員)
**解讀與實作**：Antigravity Agent

---

## 如何在全新專案中導入 Harness Engineering？

如果您想在一個全新的專案中啟用此開發工作流，請遵循以下步驟：

### 1. 建立技能目錄
在您的新專案根目錄中，建立存放技能的目錄，並將本目錄下的 `SKILL.md` 複製進去。

```bash
mkdir -p .agent/skills/harness-engineering
# 複製本專案的 harness-engineering/SKILL.md 到該路徑
```

### 2. 配置 AI 助理規則
在您的專案根目錄中的 `CLAUDE.md`、`GEMINI.md` 或 `.cursorrules` 檔案中，明確宣告此工作流的存在。這能確保 AI 助理在開發時知道要切換到「Harness 模式」。

建議加入以下配置：

```markdown
## 核心開發流程 (Harness Engineering)
- 當處理新功能或複雜重構時，必須主動提議執行 `/harness-engineering` 流程。
- **平行實作 (Parallel Implementation)**：針對核心邏輯，要求 AI 同時提供 2-3 種不同的實作版本。
- **評估驅動 (Evaluation-Driven)**：所有實作必須附帶測試或 Benchmark 數據以供對比選擇。
- **DRI 責任制**：明確當前任務的 DRI (直接負責人)，AI 負責執行，DRI 負責監督與決策。
```

### 3. 初始化並下達指令
當您準備開始開發第一個功能時，請以 DRI 的身份啟動流程：

> **指令範例**：
> 「我現在是這個任務的 DRI。請啟動 `harness-engineering` 流程，針對 [功能描述] 產出兩個平行原型實作，並為這兩個版本建立測試基準以進行評估。」

### 4. 核心工作流實踐

1.  **Intent First**: 只描述意圖（What），讓 AI 探索實作（How）。
2.  **Parallel Prototyping**: 同時看多個版本（例如：一個最快實作，一個最乾淨實作）。
3.  **Benchmark Decision**: 不要只看代碼漂亮，要看測試數據和邊界案覆蓋率。
4.  **Iterative Overseer**: 您是那個做最後點頭（Review）的人，AI 是那個幫您把雜事做完的人。

---

## 預期效果
- **開發速度提升**：省去在設計文檔中糾結的時間，直接看實作對比。
- **產出質量穩定**：透過強制的 Evaluation 流程，確保程式碼不只是「能動」，而是「可控」。
- **決策透明化**：平行原型的對比表能清晰展現技術權衡 (Trade-offs)。

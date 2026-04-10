---
description: 如何將 OpenAI 的 Harness Engineering 開發工作流導入新專案
---

# 導入 Harness Engineering 開發工作流

本手冊說明如何將 `harness-engineering` 技能導入您的新專案中，以建立「AI 原生」的工程文化。

## 1. 環境準備

確保您的專案中具備以下基礎結構：
- **`.agent/` 目錄**: 用於存放工作流定義。
- **`SKILL.md` 偵測機制**: 確保您的 AI 助理能識別並載入技能（通常透過 `skills.md` 分發）。

## 2. 導入步驟

### 步驟 A: 安裝技能
在您的專案根目錄中，建立 `harness-engineering` 目錄並複製 `SKILL.md`：
```bash
mkdir -p .agent/skills/harness-engineering
# 複製內容至 .agent/skills/harness-engineering/SKILL.md
```

### 步驟 B: 設定 AI 規則
在 `GEMINI.md` 或 `CLAUDE.md` 中加入對該工作流的引用，讓 AI 知道在處理複雜任務時應優先考慮此模式：
```markdown
## 開發原則
- 優先使用 `harness-engineering` 進行平行原型開發。
- 所有非瑣碎的變更必須附帶 AI 生成的測試 (Evaluation-Driven)。
```

### 步驟 C: 初始化第一個任務
選定一個具備挑戰性的功能（例如：重構核心模組、設計新的 UI 組件），並以 DRI 的身份下達指令：
> "我現在是專案的 DRI，請啟動 `harness-engineering` 流程，針對 [功能名稱] 產出平行原型並進行評估。"

## 3. 工作流實踐建議

1.  **容許失敗**: 平行實作中一定會有被捨棄的方案，這是為了找到最優路徑的必要成本。
2.  **極簡文檔**: 除非 AI 已經無法理解上下文，否則不要花時間寫長篇規格書。
3.  **強迫自動化**: 所有的效能或品質聲明，必須有對應的基準測試 (Benchmark) 作為證據。

## 4. 預期效果

- **開發速度提升**: 減少在「怎麼做」上的糾結，透過實作來對比。
- **品質提升**: 透過 AI 自動生成的測試覆蓋更多邊界情況。
- **創新增加**: 降低了嘗試「非典型方案」的成本。

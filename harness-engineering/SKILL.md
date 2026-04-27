---
name: harness-engineering
version: 1.0.0
description: AI-native workflow. Use for agent collab, parallel prototyping, DRI, and eval-driven dev in fast iterations.
---

# Harness Engineering: OpenAI 的 AI 原生開發工作流

本技能旨在模擬 OpenAI 的工程文化，將 AI 從「自動補全」提升為「同僚代理 (Iterative Overseer)」。

## 核心價值 (Core Values)

1.  **AI 原生 (AI-Native)**: AI 不只是工具，而是處理多步驟、機械性任務的隊友。
2.  **工程師即監督者 (Engineer as Overseer)**: 工程師專注於架構、意圖與品質 review，由 AI 執行初始實作。
3.  **平行實作 (Parallel Implementation)**: 寧願建構多個原型進行比較，也不過度在設計文檔中糾結。
4.  **DRI 責任制 (Ownership)**: 每個專案由一位「直接負責人 (DRI)」主導，具備高度自主權。
5.  **評估驅動 (Evaluation-Driven)**: 所有的改進必須基於可衡量的品質（測試、基準測試、風格指南）。

---

## 工作流階段

### 階段 1: 定義與意圖 (Intent & Scoping)
- **DRI 指定**: 確認當前任務的 DRI。
- **意圖釐清**: 使用自然語言描述目標，而非詳細的步驟。AI 負責將意圖轉換為草圖或原型。
- **最小規格 (Minimal Spec)**: 僅在問題複雜到無法憑腦袋記憶時才寫 Specs。

### 階段 2: AI 驅動的平行原型 (Parallel Prototyping)
- **多重實作**: 針對核心邏輯，AI 同時產出 2-3 種不同的實作方案（例如：效能優先、簡潔優先、模組化優先）。
- **快速實驗**: 在數小時內（而非數天）完成原型並運行初步測試。

### 階段 3: 評估與選擇 (Evaluation & Selection)
- **自動化基準 (Benchmarks)**: 針對平行原型運行單元測試、延遲測試與風格檢查。
- **Overseer Review**: 由工程師進行決策，選擇最佳原型或結合多個原型的優點。

### 階段 4: 整合與交付 (Integration & Delivery)
- **自動化測試生產**: AI 為選定的原型補齊完整測試。
- **快速發布**: 目標是基於真實反饋進行迭代，而非追求「一次完美」。

---

## 指令執行規範

當使用者要求使用 `harness-engineering` 工作流時：

1.  **詢問 intent**: "您的核心意圖是什麼？您希望達成什麼樣的產品效果？"
2.  **執行平行實作**: 主動提議並產出至少兩個版本的實作邏輯。
3.  **建立 eval 基準**: 同步產出測試腳本以衡量這兩個版本的優劣。
4.  **提供決策矩陣**: 以表格形式對比優缺點，並推薦其中一項。

---

## 範例指令
- "幫我用 harness-engineering 流程實作一個新的 API 快取層"
- "我想探索兩種不同的搜尋演算法，請產出平行原型並進行評估"
- "作為 DRI，我想快速迭代這個 UI 組件，請給我幾個方案"

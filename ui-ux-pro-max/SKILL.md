---
name: UI UX Pro Max
description: Plan products, build design systems, and optimize UI. Use for aesthetic guidance and industry-specific logic.
---

# UI UX Pro Max - 設計智慧核心 (Design Intelligence)

這套技能是您的設計大腦，當使用者要求「建立登陸頁」、「設計儀表板」或「優化 UI」時，請啟動此流程。

## 🚀 執行工作流

### 第一步：分析產品需求
先識別以下維度：
*   **產品類型**：娛樂型（社交、遊戲）、工具型（編輯器、轉換器）、生產力型（任務管理、筆記）。
*   **目標受眾**：C 端用戶、專業用戶；考慮使用場景（通勤、休閒、辦公）。
*   **風格關鍵字**：活潑、極簡、深色模式、內容優先、沈浸式。

### 第二步：生成設計系統 (必須執行)
基於上述分析，產生以下規範（Design System）：
1.  **設計模式 (Pattern)**：例如「Hero-Centric + 社交證明」。
2.  **核心風格 (Style)**：例如「軟 UI 進化 (Soft UI Evolution)」，關鍵字：軟陰影、無機形狀。
3.  **色彩計畫 (Colors)**：包含 Primary, Secondary, Background, Text 及其用途。
4.  **字體排版 (Typography)**：推薦 Google Fonts 組合及其傳達的情緒。
5.  **反模式 (Anti-patterns)**：明確列出在該產品類型中應「避免」的設計。

### 第三步：細項檢索與優化
針對特定組件（如：圖表、模態框、按鈕）深入檢索 UI、UX、Color 等領域的細微規範。

---

## 🛡️ 專業介面十大準則 (App UI)

### 1. 圖示與視覺元素
*   **嚴禁使用 Emoji 作為結構圖示**：導覽、設定等功能必須使用 SVG 向量圖示（如 Lucide）。
*   **圖示尺寸一致性**：定義設計 Token（如 icon-md = 24pt），避免隨意混合 20pt / 24pt。
*   **點擊區域 (Touch Target)**：最小 44×44pt。若圖示本身較小，必須擴張熱區 (hitSlop)。

### 2. 交互與反饋
*   **點擊反饋 (Tap Feedback)**：必須在 80-150ms 內提供視覺響應（波紋、變透明、陰影）。
*   **動畫時間**：微動效建議維持在 150-300ms 之間，避免超過 500ms 造成拖沓度感。

### 3. 色彩與對比 (WCAG)
*   **對比度標準**：小元素 4.5:1，大型介面組件 3:1。
*   **深/淺模式平權**：確保介面在兩種模式下皆具備良好的對比度與品牌一致性。

### 4. 佈局與間距
*   **8px 網格系統**：所有間距與對齊應遵循 4px 或 8px 的倍數系統，維持視覺律動感。

---

## ✅ 交付前檢查清單 (Pre-Delivery Checklist)
*   [ ] 沒有使用 Emoji 當作 Icon。
*   [ ] 所有可點擊元素都具備 `cursor-pointer` (Web) 或 44pt 區域 (App)。
*   [ ] 所有的 Hover/Press 狀態具備 150-300ms 的平滑過渡。
*   [ ] 無障礙標籤 (Aria-label) 已配置。
*   [ ] 已針對手機、平板、桌面端進行響應式檢核。

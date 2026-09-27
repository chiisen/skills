# Skills Index

> 本索引按**使用情境**重新編排本倉庫所有 skills，方便在問題發生時快速找到對的工具。
>
> 每個 skill 的完整觸發條件與細節請參考各目錄下的 `SKILL.md`。

**總計**：27 個 skills（含 `gstack/` router 1 個）

---

## 🚨 環境與服務出問題了

### 想看「現在服務還活著嗎？」
- **`debug-wizard`** — 檢查 Docker、關鍵 port（80/3000/3100/9090/9100/8080）與容器狀態。
  觸發詞：「服務沒跑起來」「無法連線」「環境檢查」

### `sail up` 起不來 / Docker 衝突
- **`docker_troubleshooting`** — 找出容器名稱衝突 + 佔用連接埠的 PID。
  觸發詞：「`sail up` 失敗」「`address already in use`」「`Conflict: container name`」

### 想看 log 裡的錯誤
- **`log-sentinel`** — 撈容器日誌並過濾 INFO/DEBUG，只留 ERROR/WARN/Exception。
  觸發詞：「看一下 log」「`500 error`」「`/scan-logs`」

### Grafana Alert 沒收到通知
- **`grafana-alert-troubleshooting`** — 系統化診斷 Contact Point / Notification Policy。
  觸發詞：「Alert 沒發送」「Telegram 機器人沒反應」

### Grafana Provisioned 資源刪不掉（409）
- **`grafana-provisioning-troubleshoot`** — 修復 `provenanceMismatch` 衝突。
  觸發詞：「HTTP 409」「`provenance fields cannot be changed`」

### Prometheus 容量異常 / 想清資料
- **`clean_prometheus_series`** — 清理殘留或過期的 TimeSeries。
  觸發詞：「Prometheus 太肥」「舊容器 series」

### Laravel Sail Xdebug breakpoint 不觸發
- **`laravel_xdebug_troubleshooter`** — 檢查 `.env` / `compose.yaml` / `launch.json`。
  觸發詞：「Xdebug 沒中斷」「斷點無效」

### `bubblewrap build` 失敗
- **`bubblewrap_troubleshooter`** — JVM 記憶體 / JDK 路徑 / 連線錯誤自動處理。
  觸發詞：「`OutOfMemoryError`」「`JAVA_HOME`」「Bubblewrap 建置失敗」

### 終端機歷史紀錄不見 / Oh My Zsh 外掛失效
- **`zsh-fix`** — 修復 `.zshrc`、Homebrew 相容性與外掛掛載。
  觸發詞：「zsh 歷史不見」「外掛失效」

### 跨平台腳本需要判斷 OS
- **`os-detector`** — 自動識別 Windows / macOS / Linux 並回傳版本資訊。
  觸發詞：「判斷作業系統」「跨平台」

---

## 📝 Obsidian 筆記與視覺化

### 編寫 Obsidian 專屬 Markdown
- **`obsidian-markdown`** — Wikilinks、Callouts、Embeds、Properties 完整語法。
  觸發詞：「Obsidian 語法」「`[[wikilink]]`」「`> [!note]`」

### 建立資料庫視圖（`.base` 檔）
- **`obsidian-bases`** — 篩選器、公式、表格/卡片視圖。
  觸發詞：「`.base`」「Obsidian Bases」「資料庫視圖」

### 整理 / 優化既有筆記
- **`doc-refiner`** — 標準化 frontmatter、Callout 轉換、標題層級修復。
  觸發詞：「整理筆記」「`/refine`」「優化 markdown」

### 視覺化畫布（`.canvas` 檔）
- **`json-canvas`** — 節點、文字、檔案、群組與連線邏輯。
  觸發詞：「`.canvas`」「心智圖」「流程圖」

---

## 🎨 設計系統（UI UX Pro Max 系列）

> 這五個 skill 同屬「UI UX Pro Max」設計智慧核心的不同面向，依需求選擇入口。

### 產品整體規劃
- **`ui-ux-pro-max`** — 設計系統推理、產品分析、App UI 十大準則（WCAG / 8px 網格）。
  觸發詞：「規劃產品」「設計儀表板」「`/ui-ux-design`」

### 品牌語調與視覺識別
- **`uupm-brand`**（Brand Excellence）— Voice & Tone、Logo 使用規範、品牌一致性檢查。
  觸發詞：「品牌調性」「撰寫行銷文案」「視覺識別」

### Token 架構與 CSS 變數
- **`uupm-design-system`**（Design System Pro）— Primitive → Semantic → Component 三層架構。
  觸發詞：「定義 Token」「設定 Tailwind 主題」「三層 Token」

### Logo / Icon / Banner 圖形
- **`uupm-graphics-design`**（Graphics Design Mastery）— 標誌設計、圖示系統、橫幅邏輯。
  觸發詞：「設計 Logo」「製作 Banner」「圖示規範」

### 簡報投影片
- **`uupm-presentation-slides`**（Presentation Slides Elite）— 視覺動線、單一焦點、精品感細節。
  觸發詞：「做簡報」「展示方案」「數據說明」

---

## 🛠️ 開發流程

### 生成 Conventional Commits 訊息
- **`semantic-git`** — 依 `git diff --staged` 自動產生 `<type>(<scope>): <subject>`。
  觸發詞：「`/commit-gen`」「提交訊息」

### AI 原生工作流諮詢
- **`harness-engineering`** — OpenAI 工程文化的 DRI、平行原型、評估驅動迭代。
  觸發詞：「AI 工作流」「agent 協作」「平行原型」

---

## ✍️ 內容創作

### 去除 AI 寫作痕跡
- **`Humanizer-zh-TW`** — 改寫文字使其更自然、人味更重。
  觸發詞：「太 AI 味」「自然化」「humanize」
  - 子技能：`text-watermark-cleaner-zh-tw`（清理不可見 Unicode / 浮水印）

### 漫畫生成
- **`manga-master`**（波弟漫畫大師）— 一句話故事 → 8 格少年漫畫。
  觸發詞：「畫漫畫」「8 格漫畫」

### 知識圖譜
- **`graphify`** — 任意輸入（代碼/文檔/圖片）→ 知識圖譜 + 社群偵測 + HTML/JSON。
  觸發詞：「`/graphify`」「知識圖譜」「視覺化關聯」

### 蘇格拉底式思考對話
- **`minerva-thinking`** — 引導式提問釐清問題、檢驗假設、收斂結論。
  觸發詞：「`#minerva`」「密涅瓦模式」「用蘇格拉底對話」

---

## 📡 通知與整合

### 傳 Telegram 通知
- **`telegram-notify`** — 透過 Telegram 機器人發送訊息給指定用戶。
  觸發詞：「傳 Telegram」「通知我」

### 跨工具 router
- **`gstack`** — 60+ 個子 skill 的路由器（瀏覽器、QA、設計、文件、投資人簡報等）。
  觸發詞：「用 gstack」「`/plan`」「`/browse`」「`/qa`」「`/design-review`」

---

## 📦 完整清單（依目錄字母序）

| 目錄 | Catalog 名稱 | 用途 |
|---|---|---|
| `Humanizer-zh-TW/` | humanizer-zh-tw | AI 文字自然化（含浮水印清理子技能） |
| `bubblewrap_troubleshooter/` | bubblewrap_troubleshooter | Bubblewrap 建置障礙排除 |
| `clean_prometheus_series/` | clean_prometheus_series | Prometheus series 清理 |
| `debug-wizard/` | debug-wizard | 監控 stack 健康檢查 |
| `doc-refiner/` | doc-refiner | Obsidian 筆記整理 |
| `docker_troubleshooting/` | Docker Troubleshooting | Docker / Sail 啟動衝突 |
| `grafana-alert-troubleshooting/` | grafana-alert-troubleshooting | Grafana Alert 通知診斷 |
| `grafana-provisioning-troubleshoot/` | Grafana Provisioning Troubleshoot | Grafana 409 刪除問題 |
| `graphify/` | graphify | 知識圖譜生成 |
| `gstack/` | gstack | 跨工具 router（內含 ~60 子 skill） |
| `harness-engineering/` | harness-engineering | AI 原生工作流 |
| `json-canvas/` | json-canvas | Obsidian Canvas 視覺畫布 |
| `laravel_xdebug_troubleshooter/` | laravel_xdebug_troubleshooter | Laravel Sail Xdebug 修復 |
| `log-sentinel/` | log-sentinel | 容器日誌錯誤過濾 |
| `manga-master/` | 波弟漫畫大師 | 8 格少年漫畫生成 |
| `minerva-thinking/` | minerva-thinking | 蘇格拉底式思考對話 |
| `obsidian-bases/` | obsidian-bases | Obsidian Bases 視圖 |
| `obsidian-markdown/` | obsidian-markdown | Obsidian Markdown 語法 |
| `os-detector/` | os-detector | 作業系統判斷 |
| `semantic-git/` | semantic-git | Conventional Commits 生成 |
| `telegram-notify/` | telegram-notify | Telegram 訊息發送 |
| `ui-ux-pro-max/` | UI UX Pro Max | 設計系統總綱 |
| `uupm-brand/` | Brand Excellence | 品牌語調與視覺識別 |
| `uupm-design-system/` | Design System Pro | Token 三層架構 |
| `uupm-graphics-design/` | Graphics Design Mastery | Logo / Icon / Banner |
| `uupm-presentation-slides/` | Presentation Slides Elite | 精品簡報 |
| `zsh-fix/` | zsh-fix | Zsh 終端機修復 |

---

## 🔄 維護指引

### 新增 skill 時
1. 建立目錄並撰寫 `SKILL.md`（frontmatter 含 `name` 與 `description`）。
2. 執行 `./check_skill_md.sh` 驗證所有目錄都有 `SKILL.md`。
3. 在本檔案對應分類補上條目（依觸發詞，而非目錄名）。
4. 在 `CHANGELOG.md` 的 `[Unreleased]` 區塊新增 `Skill: 新增 ...` 條目。

### 懷疑兩個 skill 重複時
1. 對照本檔案的**觸發詞**：兩個 skill 的觸發詞是否會同時命中同一句話？
2. 對照兩個 skill 的**輸出物**：是否產出相同內容？
3. 若都不重疊 → 屬於分工，保留；若重疊 → 合併並更新本檔案與 CHANGELOG。

### 移除 skill 時
1. 用 `git rm -r <dir>` 並提交（保留歷史）。
2. 在本檔案移除對應條目。
3. 在 `CHANGELOG.md` 加上 `Skill: 移除 ...` 條目（依 AGENTS.md 規範使用繁體中文說明原因）。

### 季度健檢
```bash
# 列出所有 skill 的觸發關鍵字，找是否有語意重疊
for d in */; do
  [ -f "$d/SKILL.md" ] && echo "=== $d ===" && \
    grep -E "(Use when|使用時機|當.*時|trigger)" "$d/SKILL.md" | head -3
done
```

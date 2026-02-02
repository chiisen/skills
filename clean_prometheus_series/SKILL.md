---
name: clean_prometheus_series
description: 清理 Prometheus 中累積的無效或過期 Series 數據 (例如: 舊的容器 Nodename)
---

# Clean Prometheus Series Skill

這個 Skill 幫助您管理與清理 Prometheus 資料庫中殘留的 TimeSeries 數據，特別適用於解決 Docker 容器頻繁重建導致的「殭屍 Label」問題 (如 `nodename` 列表暴增)。

## 前置條件 (Prerequisites)
- **環境檢查 (Strict)**：
  - 必須安裝 `curl`。
  - 必須安裝 `jq`。
  - 若使用 `docker-nodename` 模式，必須安裝 `docker` cli。
- **重要規則**：若環境未滿足上述條件，**請直接中止任務**並回報錯誤。**不要**嘗試編寫安裝腳本或尋找替代方案 (以節省 Token)。
- Prometheus 必須啟用 Admin API (`--web.enable-admin-api`)。

## 安全規範 (Critical)
1. **強制確認**：在執行任何**非** `--dry-run` 的清理指令前，**必須**明確詢問用戶是否繼續。
2. **預演流程**：強烈建議先執行 `--dry-run` 模式，並將預計刪除的 Series 數量或範例展示給用戶看。

## 用法

### 模式 1: 自動清理 Docker Nodename (專案常用)

這會自動偵測當前運行的 `node_exporter` 容器 ID，並刪除 Prometheus 中所有**不匹配**該 ID 的 `nodename` 記錄。

```bash
./.agent/skills/clean_prometheus_series/scripts/clean_series.sh --mode docker-nodename
```

### 模式 2: 手動通用清理

您可以指定任意 Label 和保留規則 (Regex)。

```bash
./.agent/skills/clean_prometheus_series/scripts/clean_series.sh \
  --label <LABEL_NAME> \
  --keep "<REGEX_TO_KEEP>" \
  [--url <PROMETHEUS_URL>]
```

**範例：** 清理 `env` 標籤，只保留 `prod` 和 `staging`，刪除其他所有環境 (如 `dev-1`, `test-old`)：
```bash
./.agent/skills/clean_prometheus_series/scripts/clean_series.sh \
  --label env \
  --keep "^(prod|staging)$"
```

### 乾跑測試 (Dry-Run)

如果不確定會刪除什麼，請加上 `--dry-run` 參數：
```bash
./.agent/skills/clean_prometheus_series/scripts/clean_series.sh --mode docker-nodename --dry-run
```

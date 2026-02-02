# Prometheus Series Cleaner Skill

這個目錄包含了一個通用的 Prometheus Series 清理工具，旨在解決 Prometheus 資料庫中累積過期 TimeSeries (如舊容器 ID、無效環境標籤) 的問題。

## 目錄結構

- `scripts/`
  - `clean_series.sh`: 核心執行腳本 (Bash)。

- `SKILL.md`: 供 Agent 閱讀的技能定義與詳細指令說明。

## 快速上手

### 先決條件
1. **Prometheus 配置**：必須啟用 Admin API。請確認 Prometheus 啟動參數包含 `--web.enable-admin-api`。
2. **工具需求**：執行環境**必須**安裝 `curl` 與 `jq`。若使用自動模式還需安裝 `docker`。
   - *注意：若缺少這些工具，腳本將直接報錯終止，不會自動嘗試安裝。*

### 常見用法

**情境 A：清理 Node Exporter 的舊容器 ID (Nodename)**
這是最常見的情況，當 Docker 容器重建後，Grafana 下拉選單會殘留舊的 ID。
```bash
./scripts/clean_series.sh --mode docker-nodename
```

**情境 B：清理無效的環境標籤**
例如想刪除所有非 `prod` 的環境數據。
```bash
./scripts/clean_series.sh --label env --keep "^prod$"
```

## 注意事項
- **強制確認**：執行實際刪除前，**務必**與相關人員確認，避免誤刪重要監控數據。
- **資料遺失風險**：此腳本會**永久刪除**符合條件的數據。操作 SOP：先使用 `--dry-run` 預覽 -> 人工確認 -> 執行刪除。
- **Grafana 更新**：清理完成後，Grafana 的下拉選單快取可能需要幾分鐘才會更新，或是需要重啟 Grafana 容器。

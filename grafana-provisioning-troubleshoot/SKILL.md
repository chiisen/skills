---
name: Grafana Provisioning Troubleshoot
description: 診斷並修復 Grafana Provisioned Resources 無法刪除的問題（HTTP 409 provenanceMismatch）
---

# Grafana Provisioning Troubleshoot Skill

## 功能說明

此 Skill 用於診斷和修復 Grafana 中因 Provisioning 機制導致的資源鎖定問題。當透過 YAML Provisioning 建立的資源（Alert Rules, Contact Points 等）無法透過 API 刪除或修改時，使用此 Skill 進行故障排除。

## 適用場景

- API 回傳 `HTTP 409` 錯誤，訊息包含 `provenanceMismatch`
- API 回傳 `HTTP 400` 錯誤，訊息包含 `request affects resources created via provisioning API`
- 已刪除 YAML Provisioning 檔案，但資源仍顯示為 "Provisioned"
- 自動化腳本無法更新或刪除特定資源

## 使用方式

當使用者遇到上述問題時，按照以下步驟執行：

### 步驟 1: 診斷問題

1. 確認錯誤訊息中的資源類型和 UID
2. 檢查 `grafana/provisioning/alerting/` 目錄是否還有相關 YAML 檔案
3. 如果 YAML 已刪除但問題仍存在，進入步驟 2

### 步驟 2: 提供解決方案選項

根據使用者的環境（開發/生產）和需求，提供以下三種方案：

#### 方案 A: 清除 Grafana Volume（開發環境推薦）

```bash
docker compose down
docker volume rm <project>_grafana-data
docker compose up -d
```

**優點**: 最乾淨，徹底解決  
**缺點**: 丟失所有 Grafana 歷史數據  
**適用**: 開發/測試環境

#### 方案 B: 手動清除資料庫記錄（生產環境推薦）

執行以下步驟：

1. 進入容器（root 權限）：
```bash
docker exec -it -u root grafana /bin/sh
```

2. 安裝 SQLite：
```bash
apk add --no-cache sqlite
```

3. 備份資料庫：
```bash
cp /var/lib/grafana/grafana.db /var/lib/grafana/grafana.db.bak
```

4. 進入資料庫：
```bash
sqlite3 /var/lib/grafana/grafana.db
```

5. 查詢問題資源：
```sql
-- 查看所有 Provisioned 資源
SELECT * FROM provenance_type;

-- 查詢特定資源（根據錯誤訊息中的 UID）
SELECT * FROM provenance_type 
WHERE record_key = '<RESOURCE_UID>' 
AND record_type = '<RESOURCE_TYPE>';
```

6. 刪除 Provenance 記錄：
```sql
DELETE FROM provenance_type 
WHERE record_key = '<RESOURCE_UID>' 
AND record_type = '<RESOURCE_TYPE>';
```

7. （可選）刪除資源本身：
```sql
-- Alert Rule
DELETE FROM alert_rule WHERE uid = '<RESOURCE_UID>';

-- Contact Point (需查詢對應表)
-- 根據實際情況調整
```

8. 退出並重啟：
```sql
.quit
```
```bash
exit
docker compose restart grafana
```

**優點**: 精確移除，保留其他數據  
**缺點**: 需要手動操作資料庫  
**適用**: 生產環境或需保留歷史數據

#### 方案 C: 使用新資源名稱（快速繞過）

修改自動化腳本，使用新的資源名稱：

```bash
# 例如：從 tg-error-alert 改為 tg-error-alert-v2
RULE_NAME="tg-error-alert-v2"
```

**優點**: 最快速，立即生效  
**缺點**: 舊資源變成孤兒數據  
**適用**: 緊急情況或快速測試

### 步驟 3: 驗證修復

執行自動化腳本或 API 請求，確認問題已解決：

```bash
docker compose restart setup
docker compose logs setup -f
```

## 資料庫結構參考

### provenance_type 表

| 欄位 | 說明 |
|------|------|
| `record_key` | 資源的 UID |
| `record_type` | 資源類型：`alertRule`, `contactPoint`, `route` |
| `provenance` | 來源：`file`（YAML）, `api`（API）, `""`（UI 或已解除保護） |

### 常見 record_type 對應

- `alertRule` → Alert Rules
- `contactPoint` → Contact Points  
- `route` → Notification Policies

## 預防措施建議

1. **開發階段**: 優先使用 API-based 自動化，避免 YAML Provisioning
2. **Volume 管理**: 定期清理開發環境 Volume
3. **命名規範**: 為資源加上版本號（v1, v2），方便快速切換
4. **文件記錄**: 將所有 Provisioning 資源記錄在專案文件中

## 輸出格式

所有回應統一使用**繁體中文**，並提供：
1. 問題診斷結果
2. 推薦的解決方案（根據環境選擇）
3. 完整的執行指令（可直接複製執行）
4. 驗證步驟

## 相關文件

- 專案內部文件：`Observability/docs/TROUBLESHOOTING_PROVISIONED_RESOURCES.md`
- Grafana 官方文件：https://grafana.com/docs/grafana/latest/administration/provisioning/

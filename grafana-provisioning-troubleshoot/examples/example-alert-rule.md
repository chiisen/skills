# 範例：修復無法刪除的 Alert Rule

## 問題描述

執行自動化腳本時遇到以下錯誤：

```
[✗] 更新失敗！HTTP 400
錯誤詳情: {"message":"failed to update rule group: request affects resources created via provisioning API: alert rule group [{orgID: 1, namespaceUID: efbp99kdoqj9cf, groupName: tg-error-alert}]"}
```

嘗試透過 Provisioning API 刪除時：

```
✘ 刪除失敗 Provisioned Rule: rule-tg-error-alert (HTTP 409)
回應: {"statusCode":409,"messageId":"alerting.provenanceMismatch","message":"cannot delete with provided provenance '', needs 'file'"}
```

## 診斷結果

- **資源類型**: Alert Rule
- **資源 UID**: `rule-tg-error-alert`
- **問題**: YAML Provisioning 檔案已刪除，但資料庫中仍保留 `provenance = 'file'` 記錄

## 解決方案（方案 B：手動清除資料庫）

### 1. 進入 Grafana 容器

```bash
docker exec -it -u root grafana /bin/sh
```

### 2. 安裝 SQLite

```bash
apk add --no-cache sqlite
```

### 3. 備份資料庫

```bash
cp /var/lib/grafana/grafana.db /var/lib/grafana/grafana.db.bak
```

### 4. 查詢並刪除 Provenance 記錄

```bash
sqlite3 /var/lib/grafana/grafana.db
```

```sql
-- 查詢問題資源
SELECT * FROM provenance_type 
WHERE record_key = 'rule-tg-error-alert' 
AND record_type = 'alertRule';

-- 輸出範例：
-- 48|1|rule-tg-error-alert|alertRule|file

-- 刪除 Provenance 記錄
DELETE FROM provenance_type 
WHERE record_key = 'rule-tg-error-alert' 
AND record_type = 'alertRule';

-- 確認刪除
SELECT * FROM provenance_type 
WHERE record_key = 'rule-tg-error-alert';
-- 應該回傳空結果

-- （可選）刪除 Alert Rule 本身
DELETE FROM alert_rule WHERE uid = 'rule-tg-error-alert';

-- 退出
.quit
```

### 5. 退出容器並重啟

```bash
exit
docker compose restart grafana setup
docker compose logs setup -f
```

## 驗證結果

重新執行後應該看到：

```
[i] 🧹 檢查並清理殘留的 Provisioned Rules (Group: tg-error-alert)...
[✓] ✅ 更新成功！HTTP 202
```

## 時間成本

- 總耗時：約 2-3 分鐘
- 停機時間：約 10 秒（重啟 Grafana）

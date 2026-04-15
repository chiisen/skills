---
name: grafana-alert-troubleshooting
description: Grafana Alert 通知問題診斷與修復流程
---

# Grafana Alert 通知問題診斷

當 Grafana Alert 無法正常發送通知到 Telegram（或其他 Contact Point）時，使用此 skill 進行系統性診斷。

## 快速診斷清單

在開始診斷前，先向使用者確認以下問題：

### 必問問題

1. **Contact Point 測試是否正常？**
   - Grafana UI → Alerting → Contact points → Test
   - 如果測試失敗，問題在 Contact Point 設定（Bot Token、Chat ID）

2. **Alert 的狀態是什麼？**
   - 🔴 Firing（持續紅色）
   - 🟠 Pending（橙色）
   - 🟢 Normal
   - 如果是 Pending，表示還沒達到 `for` 設定的持續時間

3. **Alert History 顯示什麼？**
   - Grafana UI → Alerting → Alert rules → 點擊規則 → History
   - 重點觀察狀態轉換順序和時間戳

4. **第一次 Firing 時有收到通知嗎？**
   - 有：問題在 repeat_interval
   - 沒有：問題在路由或連線

---

## 診斷指令

### Step 1: 設定環境變數
```bash
# 載入 .env（根據專案調整路徑）
source /path/to/Observability/.env

# 或直接設定
GRAFANA_TOKEN=your_token_here
```

### Step 2: 檢查三大元件

```bash
# Contact Points
curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "http://localhost:3000/api/v1/provisioning/contact-points" | jq '.'

# Notification Policy
curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "http://localhost:3000/api/v1/provisioning/policies" | jq '.'

# Alert Rules
curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "http://localhost:3000/api/ruler/grafana/api/v1/rules" | jq '.'
```

### Step 3: 檢查 Telegram API 連線（從容器內）
```bash
docker exec grafana wget -q -O- \
  "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getMe"
```

### Step 4: 查看 Grafana 日誌
```bash
docker logs grafana 2>&1 | grep -iE "notification|telegram|alert|failed|error" | tail -50
```

### Step 5: 檢查 Active Alerts
```bash
curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "http://localhost:3000/api/alertmanager/grafana/api/v2/alerts" | jq '.'
```

### Step 6: 檢查規則是否有 notification_settings
```bash
curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "http://localhost:3000/api/ruler/grafana/api/v1/rules/FOLDER_NAME" | \
  jq '."FOLDER_NAME"[] | .rules[].grafana_alert | {title, notification_settings}'
```

---

## 常見問題與解決方案

### 問題 1: notification_settings 繞過 Notification Policy

**症狀**：
- 首次通知正常
- 後續通知不按 `repeat_interval` 設定發送
- 設定 `repeat_interval: 1m` 但實際間隔約 4 小時

**診斷**：
```bash
# 檢查 alert rule 是否包含 notification_settings
curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "http://localhost:3000/api/ruler/grafana/api/v1/rules/tg-alerts" | \
  jq '.[] | .rules[].grafana_alert.notification_settings'
```

**解決**：
1. 從 Alert Rule JSON 檔案移除 `notification_settings` 區塊
2. 重新部署規則：
   ```bash
   # 刪除舊規則
   curl -s -X DELETE \
     "http://localhost:3000/api/ruler/grafana/api/v1/rules/FOLDER/RULE_GROUP" \
     -H "Authorization: Bearer $GRAFANA_TOKEN"
   
   # 執行部署腳本重建
   bash setup_XXX_alert.sh
   ```

---

### 問題 2: Alert 在 Pending 與 Normal 之間反覆

**症狀**：
- Alert History 顯示 Pending → Normal → Pending...
- 從未真正進入 Alerting/Firing

**原因**：
- 閾值設定過於敏感
- `for` 等待時間內數值回落

**解決**：
- 調整閾值
- 減少 `for` 時間
- 使用平均值減少波動

---

### 問題 3: Contact Point 測試失敗

**症狀**：
- 按 Test 無反應或報錯

**診斷**：
```bash
# 測試網路連線
docker exec grafana wget -q -O- "https://api.telegram.org"

# 檢查 Bot Token
docker exec grafana wget -q -O- \
  "https://api.telegram.org/bot$TOKEN/getMe"
```

**解決**：
- 確認 Bot Token 正確
- 確認 Chat ID 正確（群組需要負號前綴）
- 確認容器可連接外網

---

## 驗證修復

修復後執行以下驗證：

```bash
# 確認 notification_settings 為 null
curl -s -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "http://localhost:3000/api/ruler/grafana/api/v1/rules/tg-alerts" | \
  jq '."tg-alerts"[] | .rules[].grafana_alert | {title, notification_settings}'

# 預期輸出
# {
#   "title": "xxx-alert",
#   "notification_settings": null
# }
```

---

## 相關檔案

| 檔案 | 說明 |
|------|------|
| `Observability/script/setup_tg_contact.sh` | Contact Point 設定腳本 |
| `Observability/script/setup_notification_policy.sh` | Notification Policy 設定腳本 |
| `Observability/script/setup_*_alert.sh` | Alert Rule 部署腳本 |
| `Observability/script/rules_*.json` | Alert Rule 定義檔案 |

## Reporting
When interpreting the results or explaining the diagnosis to the user, you MUST use **Traditional Chinese**.

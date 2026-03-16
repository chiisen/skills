---
name: telegram-notify
description: Send Telegram notifications to a specific user. Use when tasks complete, on-demand messages, or notifications needed.
---

# Telegram Notify

## 概述

此 Skill 用於透過 Telegram 機器人傳送通知訊息給指定用戶。當任務完成或需要即時通知時觸發。

## 使用時機

使用此 Skill 當以下情況發生：

1. **任務完成通知**：長時間運行的任务完成時自動通知
2. **即時訊息**：使用者要求傳送即時通知
3. **监控告警**：系統狀態改變需要通知

## 工作流程

1. 解析使用者的請求，提取訊息內容 (`message`) 和可選的接收者 ID (`chat_id`)
2. 呼叫 `scripts/send_telegram.py` 執行實際的 API 請求
3. 回傳結果給使用者

## 使用方式

### 自動觸發
當任務完成時，AI 會判定是否需要發送通知，並自動呼叫此 Skill。

### 手動指令
```
/notify <訊息內容>
```

## 參數

| 參數 | 必填 | 說明 | 預設值 |
|------|------|------|--------|
| message | 是 | 要傳送的訊息內容 | - |
| chat_id | 否 | 接收者的 Telegram Chat ID | 從環境變數讀取 |

## 設定

在 `.env` 檔案中設定以下環境變數：

```
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
```

### 取得 Telegram Bot Token

1. 在 Telegram 搜尋 `@BotFather`
2. 使用 `/newbot` 命令建立新 Bot
3. 複製提供的 API Token

### 取得 Chat ID

1. 與你的 Bot 交談
2. 訪問 `https://api.telegram.org/bot<TOKEN>/getUpdates`
3. 從回應中找到 `chat.id`

## 資源

### scripts/

`scripts/send_telegram.py` - 傳送 Telegram 訊息的實際腳本

```bash
# 使用方式
python scripts/send_telegram.py --message "任務已完成" --chat_id 123456
```

## 限制與注意

- Telegram API 限制：每秒最多 30 則訊息
- 訊息長度限制：4096 字元
- 若 Rate Limit 遇到錯誤，腳本會自動重試

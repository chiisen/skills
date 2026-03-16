# Telegram Notify Skill

Telegram 通知發送技能，用於在任務完成或需要時傳送通知訊息。

## 目錄結構

```
telegram-notify/
├── .env.example                    # 環境變數範本（請複製為 .env 並填入實質內容）
├── .gitignore                      # 設定忽略 .env 檔案
├── SKILL.md                        # Skill 使用說明
└── scripts/
    └── send_telegram.py            # 傳送 Telegram 訊息的實際腳本
```

## 安裝與設定

> **注意**：此腳本使用 Python 內建套件（`urllib.request`、`json`），**無需額外安裝**任何套件。

### 1. 複製環境變數範本

```bash
cd telegram-notify
cp .env.example .env
```

### 2. 取得 Telegram Bot Token

1. 在 Telegram 搜尋 `@BotFather`
2. 使用 `/newbot` 命令建立新 Bot
3. 複製提供的 API Token

### 3. 取得 Chat ID

1. 與你的 Bot 交談（發送任意訊息）
2. 訪問以下網址（替換 `<TOKEN>` 為你的 Bot Token）：
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
3. 從 JSON 回應中找到 `chat.id`，例如：
   ```json
   {
     "result": [
       {
         "message": {
           "chat": {
             "id": 123456789,
             ...
           }
         }
       }
     ]
   }
   ```

### 4. 設定環境變數

編輯 `.env` 檔案，填入你的 Bot Token 和 Chat ID：

```
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
```

### 5. 驗證設定

```bash
cd telegram-notify
python scripts/send_telegram.py --message "這是一_test 試訊息"
```

## 使用方式

### 自動觸發

當任務完成時，AI 會自動判斷是否需要傳送通知並呼叫此 Skill。

### 手動指令

```
/notify <訊息內容>
```

### 直接使用腳本

```bash
# 傳送一般訊息
python scripts/send_telegram.py --message "任務已完成"

# 傳送特殊字元訊息（自動轉義）
python scripts/send_telegram.py --message "disk 空間 < 10%" --escape

# 傳送給指定 Chat ID
python scripts/send_telegram.py --message "系統警告" --chat_id 987654
```

## 環境變數

| 變數名稱 | 說明 | 必填 |
|---------|------|------|
| `TELEGRAM_BOT_TOKEN` | Telegram Bot API Token | 是 |
| `TELEGRAM_CHAT_ID` | 接收訊息的 Chat ID | 是 |

## 限制

- Telegram API 限制：每秒最多 30 則訊息
- 訊息長度限制：4096 字元
- 支援 MarkdownV2 格式

#!/usr/bin/env python3
"""
Telegram 通知發送腳本

此腳本用於透過 Telegram Bot API 傳送訊息給指定用戶。

使用方式：
    python send_telegram.py --message "訊息內容" [--chat_id 123456]

範例：
    python send_telegram.py --message "任務已完成"
    python send_telegram.py --message "系統異常：disk 空間不足" --chat_id 987654
"""

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


def get_env_config():
    """
    從環境變數或 .env 檔案讀取 Telegram 設定。

    Returns:
        dict: 包含 bot_token 和 chat_id 的字典
    """
    # 從 .env 檔案讀取（若存在）
    # 支援兩種位置：
    # 1. 腳本所在目錄的上層 (scripts/../.env) - 開發環境
    # 2. Claude Skills 目錄 (～/.claude/skills/telegram-notify/.env) - 用戶環境
    env_path_script = Path(__file__).resolve().parent.parent / ".env"
    env_path_claude = Path.home() / ".claude" / "skills" / "telegram-notify" / ".env"
    env_vars = {}

    # 優先使用腳本所在目錄的 .env
    if env_path_script.exists():
        env_path = env_path_script
    elif env_path_claude.exists():
        env_path = env_path_claude
    else:
        return {"bot_token": None, "chat_id": None}

    if env_path.exists():
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    env_vars[key.strip()] = value.strip()

    # 從系統環境變數讀取
    bot_token = env_vars.get("TELEGRAM_BOT_TOKEN") or os.environ.get("TELEGRAM_BOT_TOKEN")
    chat_id = env_vars.get("TELEGRAM_CHAT_ID") or os.environ.get("TELEGRAM_CHAT_ID")

    return {
        "bot_token": bot_token,
        "chat_id": chat_id
    }


def send_telegram_message(bot_token: str, chat_id: str, message: str, max_retries: int = 3) -> dict:
    """
    傳送 Telegram 訊息（使用內建 urllib，無需額外安裝套件）。

    Args:
        bot_token: Telegram Bot Token
        chat_id: 接收者 Chat ID
        message: 訊息內容
        max_retries: 最大重試次數

    Returns:
        dict: API 回應
    """
    api_url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = json.dumps({
        "chat_id": chat_id,
        "text": message,
        "parse_mode": "MarkdownV2"
    }).encode("utf-8")

    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Python Telegram Bot"
    }

    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(api_url, data=payload, headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=10) as response:
                return {
                    "success": True,
                    "status_code": response.status,
                    "data": json.loads(response.read().decode("utf-8"))
                }
        except urllib.error.HTTPError as e:
            # HTTP 錯誤（如 401, 404 等）
            error_body = e.read().decode("utf-8")
            return {
                "success": False,
                "error": f"HTTP {e.code}: {e.reason}. Response: {error_body}"
            }
        except urllib.error.URLError as e:
            # 網路錯誤（如連線失敗、timeout）
            if attempt < max_retries - 1:
                time.sleep(1)  # 等待 1 秒後重試
                continue
            return {
                "success": False,
                "error": f"Network error: {e.reason}"
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

    return {
        "success": False,
        "error": "Max retries exceeded"
    }


def escape_markdown_v2(text: str) -> str:
    """
    轉義 Telegram MarkdownV2 特殊字元。

    Telegram MarkdownV2 需要轉義的字元：_ * [ ] ( ) ~ ` > # + - = | { } . !
    """
    special_chars = r"\_*[]()~`>#+-=|{}.!"
    result = ""
    for char in text:
        if char in special_chars:
            result += "\\" + char
        else:
            result += char
    return result


def main():
    parser = argparse.ArgumentParser(
        description="透過 Telegram Bot 傳送通知訊息"
    )
    parser.add_argument(
        "--message",
        required=True,
        help="要傳送的訊息內容"
    )
    parser.add_argument(
        "--chat_id",
        default=None,
        help="接收者的 Telegram Chat ID（若未提供則使用環境變數）"
    )
    parser.add_argument(
        "--escape",
        action="store_true",
        help="自動轉義 MarkdownV2 特殊字元"
    )

    args = parser.parse_args()

    # 取得設定
    config = get_env_config()

    # 確認 .env 檔案是否存在（支援兩種位置）
    env_path_script = Path(__file__).resolve().parent.parent / ".env"
    env_path_claude = Path.home() / ".claude" / "skills" / "telegram-notify" / ".env"

    if not env_path_script.exists() and not env_path_claude.exists():
        print("=" * 60, file=sys.stderr)
        print("Error: .env 檔案不存在", file=sys.stderr)
        print("=" * 60, file=sys.stderr)
        print("", file=sys.stderr)
        print("請先設定 Telegram Bot 訊息發送功能：", file=sys.stderr)
        print("", file=sys.stderr)
        print("1. 複製範本檔案：", file=sys.stderr)
        if env_path_script.exists() or Path.cwd().name == "telegram-notify":
            print(f"   cp .env.example .env", file=sys.stderr)
        else:
            print(f"   cd /path/to/telegram-notify", file=sys.stderr)
            print(f"   cp .env.example .env", file=sys.stderr)
        print("", file=sys.stderr)
        print("2. 編輯 .env 檔案，填入以下資訊：", file=sys.stderr)
        print("   - TELEGRAM_BOT_TOKEN：透過 @BotFather 取得", file=sys.stderr)
        print("   - TELEGRAM_CHAT_ID：與 Bot 交談後取得", file=sys.stderr)
        print("", file=sys.stderr)
        print("3. 支援位置：", file=sys.stderr)
        print(f"   - 專案內：scripts/../../.env", file=sys.stderr)
        print(f"   - Claude Skills：~/.claude/skills/telegram-notify/.env", file=sys.stderr)
        print("", file=sys.stderr)
        print("=" * 60, file=sys.stderr)
        sys.exit(1)

    # 確認 Bot Token
    if not config["bot_token"]:
        print("Error: TELEGRAM_BOT_TOKEN 未設定", file=sys.stderr)
        print("請在 .env 檔案或環境變數中設定 TELEGRAM_BOT_TOKEN", file=sys.stderr)
        sys.exit(1)

    # 確認 Chat ID
    final_chat_id = args.chat_id or config["chat_id"]
    if not final_chat_id:
        print("Error: chat_id 未提供", file=sys.stderr)
        print("請使用 --chat_id 參數，或在 .env 中設定 TELEGRAM_CHAT_ID", file=sys.stderr)
        sys.exit(1)

    # 處理訊息內容
    message = args.message
    if args.escape:
        message = escape_markdown_v2(message)

    # 傳送訊息
    print(f"正在傳送訊息給 Chat ID: {final_chat_id}")
    print(f"訊息內容: {message[:50]}..." if len(message) > 50 else f"訊息內容: {message}")

    result = send_telegram_message(config["bot_token"], final_chat_id, message)

    if result["success"]:
        print(f"\n[OK] 訊息傳送成功")
        print(f"Status Code: {result['status_code']}")
        if "data" in result and result["data"]:
            print(f"Response: {result['data']}")
    else:
        print(f"\n[ERROR] 訊息傳送失敗")
        print(f"Error: {result.get('error', 'Unknown error')}")
        sys.exit(1)


if __name__ == "__main__":
    main()

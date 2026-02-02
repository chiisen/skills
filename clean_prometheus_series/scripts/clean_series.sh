#!/bin/bash

# clean_prometheus_series.sh
# 通用腳本：從 Prometheus 清理過期或指定的 Series

# 預設值
PROM_URL="http://localhost:9090"
LABEL_NAME=""
KEEP_REGEX="" # 用於過濾「要保留」的值 (Regex)
MODE="manual" # manual | docker-nodename

# 顯示使用說明
usage() {
    echo "用法: $0 [選項]"
    echo "選項:"
    echo "  --url <url>           Prometheus 基礎網址 (預設: http://localhost:9090)"
    echo "  --label <label>       要清理的目標標籤名稱 (手動模式必填)"
    echo "  --keep <regex>        要保留的值的正則表達式 (不匹配此規則的 Series 將被刪除)"
    echo "  --mode <mode>         操作模式: 'manual' (預設) 或 'docker-nodename'"
    echo "                        - manual: 根據 --label 和 --keep 進行清理"
    echo "                        - docker-nodename: 自動偵測執行中的 node_exporter 容器 ID"
    echo "                          並清理過期的 'nodename' 標籤"
    echo "  --dry-run             僅列出將要刪除的項目，不執行實際刪除"
    echo "  --help                顯示此說明訊息"
    exit 1
}

DRY_RUN=false

# 參數解析
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --url) PROM_URL="$2"; shift ;;
        --label) LABEL_NAME="$2"; shift ;;
        --keep) KEEP_REGEX="$2"; shift ;;
        --mode) MODE="$2"; shift ;;
        --dry-run) DRY_RUN=true ;;
        --help) usage ;;
        *) echo "未知的參數: $1"; usage ;;
    esac
    shift
done

# 檢查相依性
# 必須工具: curl, jq
deps=("curl" "jq")
for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "錯誤: 環境未滿足執行條件。缺少必要工具: '$cmd'。"
        echo "請安裝後再試。本程式不負責自動安裝依賴。"
        exit 1
    fi
done

echo "=== Prometheus Series 清理工具 ==="
echo "目標 URL: $PROM_URL"
echo "模式: $MODE"
[ "$DRY_RUN" = true ] && echo "正在以 DRY-RUN (乾跑) 模式執行 (不會進行任何變更)"

# 模式處理邏輯
if [ "$MODE" == "docker-nodename" ]; then
    # 特定模式檢查: docker
    if ! command -v docker >/dev/null 2>&1; then
        echo "錯誤: 模式 'docker-nodename' 需要 Docker 環境，但未找到 'docker' 指令。"
        echo "請確認 Docker 已安裝並在 PATH 中。"
        exit 1
    fi

    echo ">>> 自動偵測執行中的 node_exporter 容器..."
    LABEL_NAME="nodename"
    
    # 自動偵測 Docker 容器 ID
    ACTIVE_ID=$(docker ps --format "{{.ID}}" --filter "name=node_exporter" | head -n 1)
    
    if [ -z "$ACTIVE_ID" ]; then
        echo "錯誤: 找不到名稱為 'node_exporter' 的執行中容器。"
        exit 1
    fi
    
    # 同時保留 active ID 和固定的 'node_exporter' 字串
    KEEP_REGEX="^($ACTIVE_ID|node_exporter)$"
    echo "偵測到活躍的 Node ID: $ACTIVE_ID"
    echo "保留規則 (Regex): $KEEP_REGEX"
fi

# 驗證必要參數
if [ -z "$LABEL_NAME" ]; then
    echo "錯誤: 手動模式下 --label 為必填。"
    usage
fi

if [ -z "$KEEP_REGEX" ]; then
    echo "錯誤: 需要提供 --keep regex 來確認哪些數據是安全的。"
    usage
fi

# 1. 獲取 Label Values
echo ">>> 正在獲取標籤 '$LABEL_NAME' 的所有值..."
VALUES_JSON=$(curl -s "$PROM_URL/api/v1/label/$LABEL_NAME/values")

if [ "$(echo "$VALUES_JSON" | jq -r '.status')" != "success" ]; then
    echo "錯誤: 無法獲取標籤值。回應: $VALUES_JSON"
    exit 1
fi

VALUES=$(echo "$VALUES_JSON" | jq -r '.data[]')

# 2. 篩選與刪除
DELETED_COUNT=0

for val in $VALUES; do
    # 檢查是否匹配保留規則
    if [[ "$val" =~ $KEEP_REGEX ]]; then
        echo "  [保留] $val"
        continue
    fi
    
    echo "  [刪除] $val (符合刪除條件)"
    
    if [ "$DRY_RUN" = false ]; then
        # 執行刪除 API
        # 注意: 這裡使用 curl -g (globbing off) 處理包含 {} 的 URL
        DEL_RES=$(curl -X POST -s -g "$PROM_URL/api/v1/admin/tsdb/delete_series?match[]={$LABEL_NAME=\"$val\"}")
        if [ $? -eq 0 ]; then
            DELETED_COUNT=$((DELETED_COUNT+1))
        else
            echo "    刪除 Series 失敗: $val"
        fi
    else
        DELETED_COUNT=$((DELETED_COUNT+1))
    fi
done

# 3. 總結與清理 Tombstones
echo ">>> 總結"
if [ "$DELETED_COUNT" -eq 0 ]; then
    echo "沒有符合刪除條件的 Series。"
else
    if [ "$DRY_RUN" = false ]; then
        echo "已刪除 $DELETED_COUNT 個過期的 Series。"
        echo ">>> 正在清理 Tombstones (釋放磁碟空間)..."
        curl -X POST -s -g "$PROM_URL/api/v1/admin/tsdb/clean_tombstones"
        echo "完成。"
    else
        echo "預計將刪除 $DELETED_COUNT 個過期的 Series。(Dry Run)"
    fi
fi

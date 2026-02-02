#!/bin/bash

# Grafana Provenance 清理腳本
# 用途：自動清除指定資源的 Provenance 記錄

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 參數檢查
if [ $# -lt 2 ]; then
    echo -e "${RED}使用方式: $0 <container_name> <resource_uid> [resource_type]${NC}"
    echo ""
    echo "範例："
    echo "  $0 grafana rule-tg-error-alert alertRule"
    echo "  $0 grafana tg-contact-points-uid contactPoint"
    echo ""
    echo "resource_type 可選值："
    echo "  - alertRule (預設)"
    echo "  - contactPoint"
    echo "  - route"
    exit 1
fi

CONTAINER_NAME=$1
RESOURCE_UID=$2
RESOURCE_TYPE=${3:-alertRule}

echo -e "${YELLOW}=== Grafana Provenance 清理工具 ===${NC}"
echo "容器名稱: $CONTAINER_NAME"
echo "資源 UID: $RESOURCE_UID"
echo "資源類型: $RESOURCE_TYPE"
echo ""

# 檢查容器是否存在
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}[✗] 錯誤: 找不到容器 '$CONTAINER_NAME'${NC}"
    exit 1
fi

# 檢查容器是否運行中
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}[✗] 錯誤: 容器 '$CONTAINER_NAME' 未運行${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/5] 備份資料庫...${NC}"
docker exec -u root "$CONTAINER_NAME" cp /var/lib/grafana/grafana.db /var/lib/grafana/grafana.db.bak
echo -e "${GREEN}[✓] 備份完成${NC}"

echo -e "${YELLOW}[2/5] 查詢 Provenance 記錄...${NC}"
QUERY_RESULT=$(docker exec -u root "$CONTAINER_NAME" sqlite3 /var/lib/grafana/grafana.db \
    "SELECT * FROM provenance_type WHERE record_key = '$RESOURCE_UID' AND record_type = '$RESOURCE_TYPE';")

if [ -z "$QUERY_RESULT" ]; then
    echo -e "${YELLOW}[!] 未找到 Provenance 記錄，可能已被清除或 UID 不正確${NC}"
    exit 0
else
    echo -e "${GREEN}[✓] 找到記錄:${NC}"
    echo "$QUERY_RESULT"
fi

echo -e "${YELLOW}[3/5] 刪除 Provenance 記錄...${NC}"
docker exec -u root "$CONTAINER_NAME" sqlite3 /var/lib/grafana/grafana.db \
    "DELETE FROM provenance_type WHERE record_key = '$RESOURCE_UID' AND record_type = '$RESOURCE_TYPE';"
echo -e "${GREEN}[✓] 刪除完成${NC}"

echo -e "${YELLOW}[4/5] 驗證刪除結果...${NC}"
VERIFY_RESULT=$(docker exec -u root "$CONTAINER_NAME" sqlite3 /var/lib/grafana/grafana.db \
    "SELECT * FROM provenance_type WHERE record_key = '$RESOURCE_UID' AND record_type = '$RESOURCE_TYPE';")

if [ -z "$VERIFY_RESULT" ]; then
    echo -e "${GREEN}[✓] Provenance 記錄已成功清除${NC}"
else
    echo -e "${RED}[✗] 刪除失敗，記錄仍存在${NC}"
    exit 1
fi

echo -e "${YELLOW}[5/5] 建議重啟 Grafana 容器以套用變更${NC}"
echo ""
echo "執行以下指令重啟："
echo -e "${GREEN}docker restart $CONTAINER_NAME${NC}"
echo ""
echo -e "${GREEN}=== 清理完成 ===${NC}"

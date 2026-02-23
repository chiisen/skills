#!/bin/bash
# ==============================================================================
# 腳本名稱: diagnose.sh
# 功能描述: 診斷 Docker/Sail 環境錯誤，嘗試尋找衝突的容器或連接埠。
# ==============================================================================

echo -e "\033[1;33m>>> Docker 環境診斷腳本\033[0m"
echo -e "\033[0;37m功能：檢查容器衝突、連接埠佔用與驗證設定...\033[0m"
echo ""

# 檢查是否有停止但殘留的 Sail 相關容器
echo "[1] 檢查容器衝突 (Container Conflicts)"
CONFLICT_CANDIDATES=("redis-insight" "mysql" "redis" "app" "grafana" "prometheus" "loki")
FOUND_CONFLICT=false

for container in "${CONFLICT_CANDIDATES[@]}"; do
    EXISTS=$(docker ps -a --format "{{.Names}}" | grep -w "$container" || true)
    if [ ! -z "$EXISTS" ]; then
        echo "⚠️  發現可能衝突的容器: $EXISTS"
        FOUND_CONFLICT=true
    fi
done

if [ "$FOUND_CONFLICT" = false ]; then
    echo "✅ 無明顯常駐容器名稱衝突"
else
    echo "💡 提示：若確定這些容器是舊專案遺留，可使用指令刪除，例如: docker rm -f redis-insight"
fi
echo ""

# 檢查常見連接埠佔用
echo "[2] 檢查連接埠佔用 (Port Allocations)"
PORT_ISSUES=false
for port in 3306 6379 80 5173 3000 9090 3100 9100 8080 3307; do
    PIDS=$(lsof -t -i :$port || true)
    if [ ! -z "$PIDS" ]; then
        COMM=$(ps -p $PIDS -o comm= | tr '\n' ' ' || true)
        echo "⚠️  連接埠 $port 目前正被以下進程佔用: $COMM"
        PORT_ISSUES=true
    fi
done

if [ "$PORT_ISSUES" = false ]; then
    echo "✅ 常用連接埠檢查正常"
fi
echo ""

echo "診斷完畢。"

#!/bin/bash

# 腳本：檢查每個子目錄是否有 SKILL.md 檔案
# 用法：./check_skill_md.sh
# 只顯示沒有 SKILL.md 的目錄

echo "檢查缺少 SKILL.md 的目錄..."
echo "=============================="

# 計數器
total_dirs=0
missing_dirs=0

# 遍歷所有子目錄
for dir in */; do
    # 移除結尾的斜線
    dir=${dir%/}
    
    # 跳過隱藏目錄（以 . 開頭）
    if [[ $dir == .* ]]; then
        continue
    fi
    
    total_dirs=$((total_dirs + 1))
    
    # 檢查 SKILL.md 檔案是否存在
    if [[ ! -f "$dir/SKILL.md" ]]; then
        echo "❌ $dir: 缺少 SKILL.md"
        missing_dirs=$((missing_dirs + 1))
    fi
done

echo "=============================="
echo "檢查完成！"
echo "總共檢查了 $total_dirs 個子目錄"
echo "缺少 SKILL.md 的目錄: $missing_dirs"

if [[ $missing_dirs -eq 0 ]]; then
    echo "✅ 所有目錄都有 SKILL.md 檔案"
fi
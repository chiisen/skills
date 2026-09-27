#!/bin/bash
# ==============================================================================
# audit-skills.sh - 全方位檢查本倉庫 skills 品質
# ==============================================================================
# 用法：./audit-skills.sh [options]
#
#   --no-color       關閉彩色輸出
#   --json           以 JSON 格式輸出（適合 CI 整合）
#   --index FILE     指定索引檔（預設 SKILLS_INDEX.md）
#   --max-desc N     description 最大字元數（預設 120）
#   -h, --help       顯示說明
#
# 退出碼：
#   0 = 沒有 ERROR
#   1 = 有 ERROR（缺 frontmatter、缺 SKILL.md 等）
#   2 = 有 WARNING（description 太長、缺觸發詞段落等）
# ==============================================================================

set -o pipefail

# ----- 預設參數 -----
USE_COLOR=1
JSON_MODE=0
INDEX_FILE="SKILLS_INDEX.md"
MAX_DESC=120
EXIT_CODE=0

# ----- 解析參數 -----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-color)  USE_COLOR=0; shift ;;
    --json)      JSON_MODE=1; USE_COLOR=0; shift ;;
    --index)     INDEX_FILE="$2"; shift 2 ;;
    --max-desc)  MAX_DESC="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# *//'
      exit 0
      ;;
    *)           echo "未知參數：$1"; exit 1 ;;
  esac
done

# ----- 顏色 -----
if [[ $USE_COLOR -eq 1 ]]; then
  RED='\033[0;31m'; YELLOW='\033[0;33m'; GREEN='\033[0;32m'
  CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
else
  RED=''; YELLOW=''; GREEN=''; CYAN=''; BOLD=''; NC=''
fi

# ----- 計數器 -----
TOTAL=0
ERRORS=0
WARNINGS=0
OVERLAPS_FOUND=0
MISSING_TRIGGER=()
LONG_DESC=()
TRIGGER_FILE=$(mktemp)
INDEXED_DIRS=()
UNINDEXED_DIRS=()
trap 'rm -f "$TRIGGER_FILE"' EXIT

# ----- 工具：抓 frontmatter 欄位（傳入順序：file, field）-----
get_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /^---$/{c++; next}
    c==1 && index($0, f":")==1{
      sub("^"f": *",""); gsub(/^["'"'"']|["'"'"']$/,"");
      printf "%s", $0; flag=1; next
    }
    c==1 && flag && /^  /{printf " %s", $0; next}
    c==1 && flag && /^[a-zA-Z]/{exit}
  ' "$file"
}

# ----- 工具：抓 description（傳入 file）-----
get_description() {
  awk '
    /^---$/{c++; next}
    c==1 && index($0, "description:")==1 && /\|$/{flag=1; next}
    c==1 && index($0, "description:")==1{flag=1; sub(/^description: */,""); gsub(/^["'"'"']|["'"'"']$/,""); printf "%s", $0; next}
    c==1 && flag && /^---$/{exit}
    c==1 && flag && /^  /{printf " %s", $0; next}
    c==1 && flag && /^[a-zA-Z]/{exit}
  ' "$1"
}

# ----- 工具：判斷 frontmatter 是否合法（傳入順序：file, field）-----
has_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /^---$/{c++; next}
    c==1 && index($0, f":")==1{print "found"; exit}
  ' "$file" | grep -q "found"
}

# ----- 輸出輔助 -----
out_error()   { ERRORS=$((ERRORS + 1)); EXIT_CODE=1; [[ $JSON_MODE -eq 1 ]] && return; echo -e "${RED}❌ ERROR${NC}   | $*"; }
out_warning() { WARNINGS=$((WARNINGS + 1)); [[ $JSON_MODE -eq 1 ]] && return; echo -e "${YELLOW}⚠️  WARN${NC}    | $*"; }
out_info()    { [[ $JSON_MODE -eq 1 ]] && return; echo -e "${CYAN}ℹ️  INFO${NC}    | $*"; }
out_ok()      { [[ $JSON_MODE -eq 1 ]] && return; echo -e "${GREEN}✅ OK${NC}      | $*"; }

# ===== 標題 =====
if [[ $JSON_MODE -eq 0 ]]; then
  echo -e "${BOLD}${CYAN}========================================${NC}"
  echo -e "${BOLD}${CYAN}  Skills Audit Report${NC}"
  echo -e "${BOLD}${CYAN}========================================${NC}"
  echo ""
fi

# ===== 1. 收集所有 skill 目錄 =====
SKILL_DIRS=()
for dir in */; do
  dir="${dir%/}"
  [[ "$dir" == .* ]] && continue       # 跳過隱藏目錄
  [[ "$dir" == gstack ]] && continue   # gstack 是 router，子 skill 另計
  SKILL_DIRS+=("$dir")
done

# ===== 2. 逐一檢查每個 skill =====
[[ $JSON_MODE -eq 0 ]] && echo -e "${BOLD}[1/4] 檢查 frontmatter 與 description${NC}"

for dir in "${SKILL_DIRS[@]}"; do
  ((TOTAL++))
  skill_md="$dir/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    out_error "$dir/ 缺少 SKILL.md"
    continue
  fi

  # frontmatter name
  if ! has_field "$skill_md" "name"; then
    out_error "$dir/SKILL.md 缺少 frontmatter 'name'"
  fi

  # frontmatter description
  if ! has_field "$skill_md" "description"; then
    out_error "$dir/SKILL.md 缺少 frontmatter 'description'"
  fi

  # description 長度
  desc=$(get_description "$skill_md")
  desc_len=${#desc}
  if (( desc_len > MAX_DESC )); then
    LONG_DESC+=("$dir ($desc_len chars)")
    out_warning "$dir/SKILL.md description 長度 $desc_len (> $MAX_DESC)"
  fi

  # 觸發詞段落
  if ! grep -qE "(When to use|使用時機|何時使用|Usage|Trigger|## Usage)" "$skill_md"; then
    MISSING_TRIGGER+=("$dir")
    out_warning "$dir/SKILL.md 缺少 When to use / 使用時機 段落"
  fi

  # 收集觸發詞供後續比對（取 description 前 60 字）
  printf "%s\t%s\n" "$dir" "${desc:0:60}" >> "$TRIGGER_FILE"
done

# ===== 3. 觸發詞重疊檢查 =====
[[ $JSON_MODE -eq 0 ]] && echo ""
[[ $JSON_MODE -eq 0 ]] && echo -e "${BOLD}[2/4] 觸發詞重疊檢查（N-gram）${NC}"

# 簡化版：用 description 前 60 字的 word overlap 找潛在競爭者
OVERLAPS_FOUND=0
while IFS=$'\t' read -r dir1 desc1; do
  while IFS=$'\t' read -r dir2 desc2; do
    [[ "$dir1" > "$dir2" || "$dir1" == "$dir2" ]] && continue  # 避免重複比對

    # 計算共同詞（取 3+ 字元的單字集合）
    common=$(comm -12 \
      <(echo "$desc1" | tr '[:upper:]' '[:lower:]' | grep -oE "[a-zA-Z\u4e00-\u9fff]{3,}" | sort -u) \
      <(echo "$desc2" | tr '[:upper:]' '[:lower:]' | grep -oE "[a-zA-Z\u4e00-\u9fff]{3,}" | sort -u) \
      | wc -l | tr -d ' ')

    # 共同詞 >= 5 視為可能重疊
    if (( common >= 5 )); then
      out_warning "觸發詞重疊：$dir1 ↔ $dir2 (共同詞 $common 個)"
      ((OVERLAPS_FOUND++))
    fi
  done < "$TRIGGER_FILE"
done < "$TRIGGER_FILE"

if (( OVERLAPS_FOUND == 0 )); then
  out_ok "未發現顯著觸發詞重疊"
fi

# ===== 4. 與索引對照 =====
[[ $JSON_MODE -eq 0 ]] && echo ""
[[ $JSON_MODE -eq 0 ]] && echo -e "${BOLD}[3/4] 與 $INDEX_FILE 對照${NC}"

if [[ ! -f "$INDEX_FILE" ]]; then
  out_error "找不到索引檔 $INDEX_FILE"
else
  for dir in "${SKILL_DIRS[@]}"; do
    if grep -qE "(^|[ \`]*)${dir}(/|\`|$)" "$INDEX_FILE"; then
      INDEXED_DIRS+=("$dir")
    else
      UNINDEXED_DIRS+=("$dir")
      out_warning "$dir/ 未收錄於 $INDEX_FILE"
    fi
  done
  if (( ${#UNINDEXED_DIRS[@]} == 0 )); then
    out_ok "所有 ${#SKILL_DIRS[@]} 個 skills 都已收錄於 $INDEX_FILE"
  fi
fi

# ===== 5. 總結 =====
[[ $JSON_MODE -eq 0 ]] && echo ""
[[ $JSON_MODE -eq 0 ]] && echo -e "${BOLD}[4/4] 總結${NC}"
[[ $JSON_MODE -eq 0 ]] && echo -e "${BOLD}----------------------------------------${NC}"

if [[ $JSON_MODE -eq 1 ]]; then
  # 處理空陣列
  join_json_array() {
    local arr=("$@")
    if [[ ${#arr[@]} -eq 0 ]]; then
      echo ""
    else
      printf '"%s",' "${arr[@]}" | sed 's/,$//'
    fi
  }
  cat <<EOF
{
  "total": $TOTAL,
  "errors": $ERRORS,
  "warnings": $WARNINGS,
  "missing_trigger_count": ${#MISSING_TRIGGER[@]},
  "long_desc_count": ${#LONG_DESC[@]},
  "overlap_count": $OVERLAPS_FOUND,
  "unindexed_count": ${#UNINDEXED_DIRS[@]},
  "missing_trigger": [$(join_json_array "${MISSING_TRIGGER[@]}")],
  "long_desc": [$(join_json_array "${LONG_DESC[@]}")],
  "unindexed": [$(join_json_array "${UNINDEXED_DIRS[@]}")],
  "exit_code": $EXIT_CODE
}
EOF
else
  echo -e "  檢查的 skill 數：${BOLD}$TOTAL${NC}"
  echo -e "  ${RED}ERROR${NC}：${BOLD}$ERRORS${NC}"
  echo -e "  ${YELLOW}WARNING${NC}：${BOLD}$WARNINGS${NC}"
  echo -e "  缺觸發詞段落：${BOLD}${#MISSING_TRIGGER[@]}${NC}"
  echo -e "  description 過長：${BOLD}${#LONG_DESC[@]}${NC}"
  echo -e "  觸發詞可能重疊：${BOLD}$OVERLAPS_FOUND${NC}"
  echo -e "  未收錄於索引：${BOLD}${#UNINDEXED_DIRS[@]}${NC}"
  echo ""
  if (( EXIT_CODE == 0 && WARNINGS == 0 )); then
    echo -e "${GREEN}${BOLD}🎉 全部通過！${NC}"
  elif (( EXIT_CODE == 0 )); then
    echo -e "${YELLOW}${BOLD}⚠️  有警告但無錯誤，可視需要修補${NC}"
  else
    echo -e "${RED}${BOLD}❌ 有錯誤需修正${NC}"
  fi
fi

exit $EXIT_CODE

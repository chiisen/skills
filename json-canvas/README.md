# JSON Canvas Skill

此技能使支援 Skills 的 AI 助理能夠建立與編輯符合 **JSON Canvas 1.0** 標準的檔案 (`.canvas`)。這類檔案常用於 Obsidian 的畫布功能，支援無限畫布、節點連接與多媒體整合。

## 功能概述

**JSON Canvas** 是一個開放的、基於 JSON 的無限畫布資料格式。它允許內容以視覺化的方式組織，包含文字、檔案、連結與群組，並透過線段（Edges）建立邏輯關聯。

### 核心能力

1.  **節點管理 (Nodes)**：
    - **文字節點 (Text)**：支援 Markdown 格式的文字內容。
    - **檔案節點 (File)**：可引用庫中的任何檔案（如 `.md`, 圖片, 影片, PDF 等），並支援連結到特定標題或區塊（subpath）。
    - **連結節點 (Link)**：顯示外部 URL 並提供預覽。
    - **群組節點 (Group)**：視覺化的容器，用於組織與標示節點集合，支援背景圖片。
2.  **線段連接 (Edges)**：
    - 在節點之間建立有向或無向的連接。
    - 支援自定義連接側邊（上、下、左、右）與端點樣式（箭頭或無）。
    - 支援為連線添加標籤文字。
3.  **視覺自定義**：
    - 支援 6 種預設顏色與自定義 Hex 色碼。
    - 支援 Z-Index 堆疊順序管理。
4.  **自動佈局建議**：
    - AI 可以根據邏輯結構建議節點的座標 (x, y) 與尺寸 (width, height)。

## 使用說明

### 觸發場景
當您提及以下關鍵字或執行相關操作時，AI 將自動調用此技能：
- 建立或編輯 `.canvas` 畫布檔案
- 製作心智圖 (Mind Map)、流程圖 (Flowchart) 或視覺化筆記
- 提到「Obsidian Canvas」、「畫布檔案」
- 請求「圖形化呈現」某些資訊的關聯

### 檔案格式
Canvas 檔案使用 `.canvas` 副檔名，內部為標準的 JSON 格式。

### 節點類型參考
- `text`: 純文字/Markdown。
- `file`: 本地附件或筆記路徑。
- `link`: 外部網站連結。
- `group`: 組織用的區塊。

## 範例：簡單的流程圖結構

```json
{
  "nodes": [
    {
      "id": "node1",
      "type": "text",
      "x": 0, "y": 0, "width": 200, "height": 100,
      "text": "# 開始"
    },
    {
      "id": "node2",
      "type": "text",
      "x": 300, "y": 0, "width": 200, "height": 100,
      "text": "進行處理..."
    }
  ],
  "edges": [
    {
      "id": "edge1",
      "fromNode": "node1", "fromSide": "right",
      "toNode": "node2", "toSide": "left",
      "toEnd": "arrow"
    }
  ]
}
```

## 相關參考
- [JSON Canvas Official Spec](https://jsoncanvas.org/spec/1.0/)
- [Obsidian Canvas Documentation](https://help.obsidian.md/plugins/canvas)

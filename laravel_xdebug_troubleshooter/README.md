# Laravel Sail Xdebug Troubleshooter Skill

這個 Skill 旨在協助診斷與修復 Laravel Sail 環境下 Xdebug 中斷點（Breakpoint）失效的問題。

## 功能
此工具會引導 Agent 檢查以下關鍵設定：
1.  **環境變數 (.env)**：確認 Xdebug 模式與設定是否正確。
2.  **Docker 設定 (compose.yaml)**：確認是否強制開啟除錯 Session。
3.  **編輯器設定 (.vscode/launch.json)**：確認監聽端口與路徑映射。

## 使用時機
當使用者回報「中斷點沒反應」、「Xdebug 無法運作」或類似問題時，應優先參考此 Skill 進行排查。

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Changed
- Docs: 更新 `GEMINI.md`，新增 Artifacts 語言規範（Implementation Plan, Task, Walkthrough 統一使用繁體中文）。
- Fixed: 修正 `clean_prometheus_series/SKILL.md` 的 YAML 語法錯誤（為 `description` 加上引號）。
- Script: 更新 `git-pull-skills.sh` 以包含 `WINDSURF_SKILLS_DIR` 與 `CURSOR_SKILLS_DIR` 的處理。

### Added
- Skill: 新增 `harness-engineering` 技能，模擬 OpenAI 的 AI 原生開發工作流，支援平行原型開發與評估驅動迭代。
- Workflow: 新增 `harness-engineering` 工作流，說明如何在新專案中導入 OpenAI 風格的開發流程。
- Script: 新增 `git-pull-skills.ps1`，為 `git-pull-skills.sh` 的 Windows PowerShell 版本，支援路徑自動轉換與日誌管理。
- Skill: 新增 `ui-ux-pro-max` 家族系列技能，包含：
    - `ui-ux-pro-max`: 設計智慧核心與 App UI 規範。
    - `uupm-design-system`: 三層 Token 架構與組件規範。
    - `uupm-brand`: 品牌語調與視覺識別指南。
    - `uupm-graphics-design`: Logo、Icon 與 Banner 設計邏輯。
    - `uupm-presentation-slides`: 精品簡報投影片生成指引。
- UI UX Pro Max 數據庫: 補全了包含 Colors, Fonts, Styles, Reasoning, UX, Charts, Landing, Products, Typography, Icons, React Performance, App Interface 等 12 個核心 CSV 數據集。
- UI UX Pro Max 腳本: 新增了基於 Python 的自動化工具 (`core.py`, `design_system.py`, `search.py`)，支援設計推理與持久化。
- Workflow: 新增 `ui-ux-design` 工作流，提供標準化的產品設計與系統生成流程。
- Skill: 新增 `doc-refiner` 技能，自動化整理與標準化 Obsidian 文件。
- Skill: 新增 `semantic-git` 技能，協助生成符合規範的繁體中文 Git Commit 訊息。
- Skill: 新增 `log-sentinel` 技能，快速檢索與過濾 Docker 服務日誌中的錯誤。
- Workflow: 新增 `skills` 工作流，允許通過 `/skills` 查詢專案中的技能。
- Docs: 在 README 中新增 `Bubblewrap Troubleshooter` 技能說明。
- Skill: 新增 `os-detector` 技能，用於自動判斷作業系統環境。
- Skill: 新增 `debug-wizard` 技能，一鍵診斷專案 Docker 容器與端口狀態。
- Skill: 新增 `grafana-alert-troubleshooting` 技能，用於診斷 Grafana Alert 發送問題。
- Docs: 在 README 中新增 `Grafana Alert Troubleshooting` 技能說明。

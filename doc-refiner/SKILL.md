---
name: doc-refiner
description: Automates the process of refining and organizing Obsidian markdown notes into a standardized format.
---

# Document Refiner

## Description
This skill automates the cleanup and organization of raw Markdown notes (often from the Inbox) into a standardized format suitable for the `20_Technical` or other permanent folders in the Obsidian vault.

## Usage
Use this skill when the user asks to "organize", "refine", or "fix" a note, or uses the command `/refine`.

## Workflow
1.  **Analyze Content**: Read the target file.
2.  **Generate YAML**: Create or update the YAML frontmatter.
    -   `tags`: Add relevant tags based on content (e.g., `#technical`, `#grafana`, `#git`).
    -   `status`: Set to `done` or `processing`.
    -   `date`: Current date in `YYYY-MM-DD` format.
3.  **Format Content**:
    -   Convert "Note:", "Warning:", "Tip:" text blocks into Obsidian Callouts (`> [!NOTE]`, `> [!WARNING]`).
    -   Ensure headers are properly structured (H1 for title, H2+ for sections).
    -   Fix broken or non-standard formatting.
4.  **Rename File** (Optional): Suggest a new filename in English `snake_case` or `PascalCase` if the current one is messy or in Chinese, matching the `GEMINI.md` conventions if present.
5.  **Output**: Multi-replace or overwrite the file with the refined content.

## Commands
### `/refine [file_path]`
Refines the specified file.

## Reporting
When explaining the actions taken or providing feedback to the user, you MUST use **Traditional Chinese**.

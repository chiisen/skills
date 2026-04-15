---
description: List and summarize all available skills in the project
---

1.  **Search for Skills**:
    -   Use `find_by_name` to search for all files named `SKILL.md` in the project root.

2.  **Extract Information**:
    -   For each `SKILL.md` found, use `view_file` to read the first 20 lines.
    -   Extract the skill name and description from the YAML frontmatter (if present) or the file header.

3.  **Report**:
    -   Present a markdown table listing all skills found.
    -   Columns should include: **Skill Name**, **Description**, and **Path**.
    -   Provide a brief instruction on how to use them (e.g., "Ask me to use [Skill Name]").

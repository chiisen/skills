---
name: semantic-git
description: Generates standardized Git commit messages following the project's conventional commit guidelines.
---

# Semantic Git

## Description
This skill helps ensure all Git commits strictly follow the project's conventional commit format defined in `GEMINI.md`. It analyzes staged changes and generates a compliant commit message.

## Usage
Use this skill when the user is ready to commit changes, asks for a commit message, or uses the command `/commit-gen`.

## Workflow
1.  **Check Status**: Run `git status` to see what is staged.
    -   If nothing is staged, warn the user.
2.  **Analyze Diff**: Run `git diff --staged` to understand the changes.
3.  **Generate Message**: logic to construct the message:
    -   **Format**: `<type>(<scope>): <subject>`
    -   **Type**: Choose `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, or `revert` based on the diff.
    -   **Scope**: Identify the module or file affected.
    -   **Subject**: Concise summary in **Traditional Chinese (繁體中文)**.
    -   **Body**: Detailed explanation in **Traditional Chinese**, explaining *why* and *what* changed.
4.  **Output**: Present the command `git commit -m "..."` for the user to review and approve.

## Commands
### `/commit-gen`
Generates a commit message for the currently staged changes.

## Reporting
When proposing the commit message or explaining the changes to the user, you MUST use **Traditional Chinese**.

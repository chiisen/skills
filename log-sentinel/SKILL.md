---
name: log-sentinel
description: rapid diagnostic tool that scans container logs for errors and warnings.
---

# Log Sentinel

## Description
This skill quickly retrieves and filters logs from Docker containers or system services to identify errors, warnings, and exceptions. It filters out noise (INFO/DEBUG) to focus on problems.

## Usage
Use this skill when the user reports a runtime error, a "500 error", or asks to "check the logs", or uses `/scan-logs`.

## Workflow
1.  **Identify Target**: Determine which service/container to check (e.g., `grafana`, `app_server`). If unknown, list running containers.
2.  **Fetch Logs**: Run `docker logs --tail 200 <container_id>` (or similar).
3.  **Filter**:
    -   Keep lines containing: `ERROR`, `WARN`, `Exception`, `Fatal`, `Fail`.
    -   Discard generic `INFO`, `DEBUG` lines unless they provide critical context implies by the error.
4.  **Report**:
    -   Present the filtered log lines.
    -   If a stack trace or specific error file/line is found, point to the source code file using `glance_file` or `view_file` if possible.

## Commands
### `/scan-logs [service_name]`
Scans the logs of the specified service.

## Reporting
When interpreting the logs or reporting findings to the user, you MUST use **Traditional Chinese**.

---
name: debug-wizard
description: A diagnostic tool for the project's observability stack (Grafana, Loki, Prometheus, etc.) and App Server.
---
# Debug Wizard

## Description
This skill automates the process of diagnosing the development environment stack defined in `GEMINI.md`. It checks the status of Docker containers and verifies if essential ports are listening.

## Usage
Use this skill when:
- The user reports issues with "Grafana", "Loki", "Prometheus", or the "App Server".
- The user asks to "check the system status" or "debug the environment".
- You want to verify if the stack is running correctly before proceeding with configuration changes.

## Scripts

### `scripts/diagnose.ps1`
A PowerShell script that:
1.  Lists all Docker containers and their status.
2.  Checks TCP connectivity for the following critical ports:
    -   **80**: App Server
    -   **3000**: Grafana
    -   **3100**: Loki
    -   **9090**: Prometheus
    -   **9100**: Node Exporter
    -   **8080**: cAdvisor

#### Execution
```powershell
./scripts/diagnose.ps1
```

### `scripts/diagnose.sh` (macOS / Linux)
A Bash script equivalent to the PowerShell version, optimized for Unix-like environments.
- Uses `nc` (Netcat) for network port scanning.
- Uses standard ANSI escape codes for colored output.

#### Execution
```bash
./scripts/diagnose.sh
```
> **Agent Note**: This file is tracked with `+x` permission in Git. However, if you encounter `Permission denied` during execution, you MUST automatically run `chmod +x ./scripts/diagnose.sh` and retry without asking not ask the user.

## Reporting
When interpreting the results of the diagnosis scripts or explaining the status to the user, you MUST use **Traditional Chinese**.

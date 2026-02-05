---
name: laravel_xdebug_troubleshooter
description: Diagnose and fix Laravel Sail Xdebug breakpoint issues.
---

# Laravel Sail Xdebug Troubleshooter

> **Note:** All interactions and responses regarding this skill must be in **Traditional Chinese (繁體中文)**.

Use this skill when the user reports that Xdebug breakpoints are not working in a Laravel Sail environment.

## 1. Environment Configuration Check (`.env`)

Check the `.env` file for the following configurations:

-   `SAIL_XDEBUG_MODE`: Should include `debug` (e.g., `develop,debug`).
-   `SAIL_XDEBUG_CONFIG`: Should include `client_host=host.docker.internal` and `start_with_request=yes`.

**Action:** If missing or incorrect, update `.env`.

## 2. Docker Compose Configuration Check (`compose.yaml`)

Check `compose.yaml` (or `docker-compose.yml`) for the `laravel.test` service environment variables:

-   `XDEBUG_SESSION`: Ensure this environment variable is set to `1` to force Xdebug activation.
    ```yaml
            environment:
                # ...
                XDEBUG_SESSION: 1
    ```

**Action:** If `XDEBUG_SESSION` is missing, add it to `compose.yaml` and notify the user that a restart (`sail down && sail up -d`) will be required.

## 3. VS Code Configuration Check (`.vscode/launch.json`)

Check `.vscode/launch.json` for the listener configuration:

-   `port`: Should be `9003`.
-   `hostname`: Should be `"0.0.0.0"` to listen on all interfaces.
-   `pathMappings`: Ensure proper mapping between container and host.
    ```json
    "pathMappings": {
        "/var/www/html": "${workspaceFolder}"
    }
    ```

**Action:** If `hostname` is missing or incorrect, update `launch.json`.

## 4. Verification

After fixing any configurations, guide the user to:
1.  Restart Sail: `./vendor/bin/sail down && ./vendor/bin/sail up -d`
2.  Start debugging in VS Code (F5).
3.  Set a breakpoint.
4.  Trigger a request.

## 5. Advanced Diagnosis (if still failing)

If issues persist:
1.  Temporarily enable Xdebug logging locally in `.env`:
    `SAIL_XDEBUG_CONFIG="... log=/tmp/xdebug.log"`
2.  Restart Sail.
3.  Tail the log: `./vendor/bin/sail exec laravel.test cat /tmp/xdebug.log`.
4.  Look for "Time-out connecting to client" (network issue) or "Step Debugger: enabled" (connection successful but breakpoint missed).

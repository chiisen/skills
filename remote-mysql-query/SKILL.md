---
name: remote-mysql-query
description: "透過 SSH Tunnel、mysql-client 與 .cnf 設定檔安全查詢本地 Sail 及遠端測試站 MySQL，自動處理埠位防衝突與 Docker 內部 IP 漂移。"
---

# Agent Skill: Remote & Local MySQL Safe Query Execution

## 1. 使用時機與觸發條件 (When to Use / Trigger)
Activate this skill when:
- The user requests to query data from the local database (Sail) or remote staging servers (e.g., `test4`, `test0`, `test3`).
- The task involves executing MySQL queries via `mysql-client` with `--defaults-extra-file`.
- A connection error `ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet'` occurs during database access.

---

## 2. Safety Rules & Behavioral Constraints
- **macOS Exclusive & Fail-Fast Pause**: This skill is strictly tailored for **macOS (`Darwin`)** with a pre-configured `mysql-client` and `~/.my-<target>.cnf` setup. If invoked on **Windows, WSL, or Linux**, or if either `mysql-client` or `~/.my-<target>.cnf` is missing, **PAUSE IMMEDIATELY** and ask the user how to proceed. Never guess or auto-switch methods silently.
- **Read-Only Invariant**: Queries must strictly default to `SELECT` statements. Never run destructive statements (`DROP`, `DELETE`, `UPDATE`, `ALTER`, `TRUNCATE`) unless explicitly instructed by the user.
- **Zero-Modification on Remote Servers**: When accessing remote staging servers (e.g., `test4`), all SSH commands executed on the remote host must be strictly read-only diagnostics (`awk`, `ss`, `grep`, `nc`, `cat`). Never edit remote configuration files, environment variables, or container states.
- **Credential Protection & No Unsafe Workarounds**:
  - Never pass plaintext passwords via the `-p<password>` CLI argument when executing commands visible in logs; always prioritize `--defaults-extra-file="$HOME/.my-<target>.cnf"`.
  - **STRICT PROHIBITION**: If local `mysql-client` or `.cnf` is missing, **NEVER** read/extract the password from `~/.my-<target>.cnf` or `.env` to run `ssh <host> "docker exec ... mysql -p..."` as a workaround.
- **Port Allocation Invariant**:
  - `3306`: Local MySQL direct connection (Sail).
  - `3307`: **RESERVED FOR PHPMYADMIN (HTTP)**. NEVER point MySQL connections or tunnels to 3307.
  - `3308`: Dedicated local port for SSH Tunnel forwarding to remote staging databases.

---

## 3. Decision Matrix: Query Target

```text
[User Request]
       |
       +--> Phase 0: Pre-flight Readiness Check
       |      1. OS Guard: Must be macOS (`uname -s` == "Darwin")
       |      2. Binary Check: Resolve $MYSQL_BIN (PATH -> /opt/homebrew -> /usr/local)
       |      3. Config Check: Verify `$HOME/.my-<target>.cnf` exists
       |      |
       |      +--> [ANY CHECK FAILS (e.g., Windows/WSL, no mysql-client, or no .cnf)]
       |             🛑 PAUSE & ASK USER!
       |             Report the exact missing prerequisite / OS mismatch, and ask user whether to:
       |             (a) Switch to an alternative query method (e.g., Sail/Docker/Tinker for local, or user-specified method)
       |             (b) Set up the missing environment first
       |
       +---> [ALL CHECKS PASS] -> Query Local Database (Sail, target=test0)
       |       |
       |       +--> Verify local MySQL is active: `nc -zv 127.0.0.1 3306`
       |       +--> Execute query using `"$MYSQL_BIN"` with `$HOME/.my-test0.cnf` (port=3306)
       |
       +---> [ALL CHECKS PASS] -> Query Remote Staging (e.g., target=test4)
               |
               +--> Step 1: Detect remote MySQL container IP (prevent IP drift)
               +--> Step 2: Establish local SSH Tunnel on 127.0.0.1:3308
               +--> Step 3: Validate tunnel handshake (`nc -zv 127.0.0.1 3308`)
               +--> Step 4: Execute query using `"$MYSQL_BIN"` with `$HOME/.my-<target>.cnf` (port=3308)
```

---

## 4. Execution Pipeline for Database Queries

### Phase 0: Pre-flight Environment & OS Check (Mandatory First Step)
Before running any tunnel or database command, verify OS compatibility (must be macOS, not Windows or WSL), `mysql-client` binary availability, and the target `.cnf` file in a single read-only check:
```bash
OS_NAME=$(uname -s 2>/dev/null || echo "Windows")
MYSQL_BIN=$(command -v mysql || ls /opt/homebrew/opt/mysql-client/bin/mysql /usr/local/opt/mysql-client/bin/mysql 2>/dev/null | head -n 1)
CNF_FILE="$HOME/.my-<target>.cnf"

echo "OS=${OS_NAME} | MYSQL_BIN=${MYSQL_BIN:-MISSING} | CNF=$([ -f "$CNF_FILE" ] && echo OK || echo MISSING)"
```
- **Pause Condition & Standard Prompt Template**: If `OS != Darwin` (e.g., Windows PowerShell, CMD, or WSL `Linux`), OR `MYSQL_BIN == MISSING`, OR `CNF == MISSING`:
  1. **STOP executing this skill immediately.** Do not proceed to Phase 1, and do not silently improvise workarounds.
  2. **Output the following standardized prompt (in Traditional Chinese)** so the user can quickly choose the next action:
     > ⚠️ **`remote-mysql-query` 環境檢查未通過，已暫停執行：**
     > - **作業系統**：`<OS_NAME>`（本 Skill 僅適用 macOS `Darwin`）
     > - **`mysql-client` 狀態**：`<已安裝路徑 或 未安裝>`
     > - **設定檔 `~/.my-<target>.cnf`**：`<存在 或 缺少>`
     >
     > 請問您希望如何處理？
     > 1. **改用當前環境的容器/框架工具查詢**（例如本地 Sail：`./vendor/bin/sail mysql`、`docker exec` 或 `artisan tinker`）
     > 2. **由您指定此環境的連線方式**（請提供指令或連線資訊）
     > 3. **先補齊 macOS `mysql-client` / `.cnf` 設定後再重試**

### Phase 1: Dynamic Container IP Discovery (Avoid IP Drift)
Do not hardcode remote Docker container IPs (e.g., `172.25.0.6` may change to `172.25.0.4` upon container recreation).
Execute remote inspection via SSH using single-quoted regex extraction (safe inside `$(...)` command substitution without variable stripping):
```bash
REMOTE_CONTAINER_IP=$(ssh <host_alias> 'grep -B 1 "/32 host LOCAL" /proc/$(pgrep -o mysqld)/net/fib_trie | grep -Eo "172\.[0-9]+\.[0-9]+\.[0-9]+" | head -n 1')
echo "REMOTE_CONTAINER_IP=${REMOTE_CONTAINER_IP}"
```
*Output: Extracted IPv4 address (e.g., `172.25.0.4`).*

### Phase 2: Tunnel Lifecycle Management
Ensure no stale processes (including tunnels from a previously queried remote host) bind to `3308`, then spawn the background tunnel:
```bash
pkill -f "127.0.0.1:3308:" || true
ssh -f -N -L 127.0.0.1:3308:${REMOTE_CONTAINER_IP}:3306 <host_alias>
```

### Phase 3: Tunnel Health Verification
Verify that the local tunnel endpoint is listening and responsive before running queries:
```bash
nc -zv 127.0.0.1 3308
```
*Expected output: `Connection to 127.0.0.1 port 3308 succeeded!`*

### Phase 4: Query Execution
Execute the required query using the dynamically resolved `$MYSQL_BIN` and the specified configuration profile:
```bash
"$MYSQL_BIN" --defaults-extra-file="$HOME/.my-<target>.cnf" --protocol=TCP -e "<SQL_QUERY>"
```

---

## 5. Automated Failure Diagnostics & Remediation

| Error Signature | Root Cause | Automated Remediation Action |
| :--- | :--- | :--- |
| `OS != Darwin` (Windows / WSL / Linux) | Skill invoked on a non-macOS machine with different network/tunnel/config conventions. | **Pause & Ask User**: Inform user this skill is for macOS only, and ask how they want to query on the current OS (e.g., Sail/Docker/Tinker or custom instructions). |
| `MYSQL_BIN=MISSING` or `CNF=MISSING` | Local machine lacks `mysql-client` or `~/.my-<target>.cnf`. | **Pause & Ask User**: Report exact missing item. Ask whether to wait for `brew install mysql-client` / `.cnf` setup, or switch to an alternative method. |
| `ERROR 2013 (HY000): Lost connection ... reading initial communication packet` | Target port is pointing to phpMyAdmin (3307), or remote container IP is stale/unreachable. | 1. Check if port is 3307; if yes, switch to 3306 or 3308.<br/>2. Re-run Phase 1 to detect fresh container IP and restart tunnel. |
| `bind [127.0.0.1]:3308: Address already in use` | An orphan SSH process is holding port 3308. | Execute `pkill -f "3308"` and re-run Phase 2. |
| `ERROR 1045 (28000): Access denied for user` | User does not exist or credentials in `.cnf` are invalid. | Verify `.cnf` syntax: ensure `[client]` header exists, no quotes around values, and no trailing comments. |
| `service "laravel.test" is not running` | Local Sail environment is down. | Run `./vendor/bin/sail up -d` in `app/code`. |

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
- **Read-Only Invariant**: Queries must strictly default to `SELECT` statements. Never run destructive statements (`DROP`, `DELETE`, `UPDATE`, `ALTER`, `TRUNCATE`) unless explicitly instructed by the user.
- **Zero-Modification on Remote Servers**: When accessing remote staging servers (e.g., `test4`), all SSH commands executed on the remote host must be strictly read-only diagnostics (`awk`, `ss`, `grep`, `nc`, `cat`). Never edit remote configuration files, environment variables, or container states.
- **Credential Protection**: Never pass plaintext passwords via the `-p<password>` CLI argument when executing commands visible in logs; always prioritize `--defaults-extra-file="$HOME/.my-<target>.cnf"` or interactive inputs.
- **Port Allocation Invariant**:
  - `3306`: Local MySQL direct connection (Sail).
  - `3307`: **RESERVED FOR PHPMYADMIN (HTTP)**. NEVER point MySQL connections or tunnels to 3307.
  - `3308`: Dedicated local port for SSH Tunnel forwarding to remote staging databases.

---

## 3. Decision Matrix: Query Target

```text
[User Request]
       |
       +---> Query Local Database (Sail)
       |       |
       |       +--> Verify local MySQL is active: `nc -zv 127.0.0.1 3306`
       |       +--> Use `$HOME/.my-test0.cnf` (host=127.0.0.1, port=3306)
       |       +--> Fallback: `./vendor/bin/sail artisan tinker --execute="..."`
       |
       +---> Query Remote Staging (e.g., test4)
               |
               +--> Step 1: Detect remote MySQL container IP (prevent IP drift)
               +--> Step 2: Establish local SSH Tunnel on 127.0.0.1:3308
               +--> Step 3: Validate tunnel handshake (`nc -zv 127.0.0.1 3308`)
               +--> Step 4: Execute query using `$HOME/.my-<target>.cnf` (port=3308)
```

---

## 4. Execution Pipeline for Remote Database Queries

### Phase 1: Dynamic Container IP Discovery (Avoid IP Drift)
Do not hardcode remote Docker container IPs (e.g., `172.25.0.6` may change to `172.25.0.4` upon container recreation).
Execute remote inspection via SSH:
```bash
ssh <host_alias> "awk '{print \$1, \$2}' /proc/\$(pgrep -o mysqld)/net/fib_trie | grep -B 1 '32 host' | grep -v '127.0.0.1' | head -n 1 | awk '{print \$2}'"
```
*Output: Extracted IPv4 address (e.g., `172.25.0.4`). Store as `$REMOTE_CONTAINER_IP`.*

### Phase 2: Tunnel Lifecycle Management
Ensure no stale processes bind to `3308`, then spawn the background tunnel:
```bash
pkill -f "3308.*<host_alias>" || true
ssh -f -N -L 127.0.0.1:3308:${REMOTE_CONTAINER_IP}:3306 <host_alias>
```

### Phase 3: Tunnel Health Verification
Verify that the local tunnel endpoint is listening and responsive before running queries:
```bash
nc -zv 127.0.0.1 3308
```
*Expected output: `Connection to 127.0.0.1 port 3308 succeeded!`*

### Phase 4: Query Execution
Execute the required query using the specified configuration profile:
```bash
/opt/homebrew/opt/mysql-client/bin/mysql --defaults-extra-file="$HOME/.my-<target>.cnf" --protocol=TCP -e "<SQL_QUERY>"
```

---

## 5. Automated Failure Diagnostics & Remediation

| Error Signature | Root Cause | Automated Remediation Action |
| :--- | :--- | :--- |
| `ERROR 2013 (HY000): Lost connection ... reading initial communication packet` | Target port is pointing to phpMyAdmin (3307), or remote container IP is stale/unreachable. | 1. Check if port is 3307; if yes, switch to 3306 or 3308.<br/>2. Re-run Phase 1 to detect fresh container IP and restart tunnel. |
| `bind [127.0.0.1]:3308: Address already in use` | An orphan SSH process is holding port 3308. | Execute `pkill -f "3308"` and re-run Phase 2. |
| `ERROR 1045 (28000): Access denied for user` | User does not exist or credentials in `.cnf` are invalid. | Verify `.cnf` syntax: ensure `[client]` header exists, no quotes around values, and no trailing comments. |
| `service "laravel.test" is not running` | Local Sail environment is down. | Run `./vendor/bin/sail up -d` in `app/code`. |

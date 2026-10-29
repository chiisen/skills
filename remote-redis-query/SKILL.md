---
name: remote-redis-query
description: "透過 SSH Tunnel、redis-cli 與 .env 設定檔安全查詢本地 Sail 及遠端測試站 Redis，自動處理埠位防衝突、Docker IP 漂移與多 DB 檢索。"
---

# Agent Skill: Remote & Local Redis Safe Query Execution

## 1. 使用時機與觸發條件 (When to Use / Trigger)
Activate this skill when:
- The user requests to query or inspect Redis data, cache, sessions, queues, or BAM states from the local environment (Sail) or remote staging servers (e.g., `test4`, `test0`, `test3`).
- The task involves executing `redis-cli` commands or troubleshooting Laravel Redis keys (`laravel_database_*`).
- A connection error or empty `(nil)` result occurs when looking up Redis keys across databases (`db0`, `db1`, `db2`).

---

## 2. Safety Rules & Behavioral Constraints
- **macOS Exclusive & Fail-Fast Pause**: This skill is strictly tailored for **macOS (`Darwin`)** with a pre-configured `redis-cli` and `~/.redis-<target>.env` setup. If invoked on **Windows, WSL, or Linux**, or if either `redis-cli` or `~/.redis-<target>.env` is missing, **PAUSE IMMEDIATELY** and ask the user how to proceed. Never guess or auto-switch methods silently.
- **Read-Only Invariant**: Commands must strictly default to read-only operations (`PING`, `INFO`, `DBSIZE`, `SCAN`, `TYPE`, `TTL`, `PTTL`, `GET`, `MGET`, `HGET`, `HGETALL`, `HMGET`, `LRANGE`, `LLEN`, `SMEMBERS`, `SCARD`, `ZRANGE`, `ZCARD`). Never run destructive or mutating commands (`DEL`, `UNLINK`, `FLUSHDB`, `FLUSHALL`, `SET`, `HSET`, `EXPIRE`, `CONFIG SET`) unless explicitly instructed by the user.
- **No `KEYS *` Invariant (Anti-Blocking)**: **NEVER** execute `KEYS *` or `KEYS <pattern>`, as it blocks the single-threaded Redis event loop. Always use non-blocking cursor iteration: `SCAN 0 MATCH "<pattern>" COUNT 100`.
- **Zero-Modification on Remote Servers**: When accessing remote staging servers (e.g., `test4`), all SSH commands executed on the remote host must be strictly read-only diagnostics (`grep`, `pgrep`, `ss`, `nc`, `cat`). Never edit remote configuration files or container states.
- **Credential Protection & No Unsafe Workarounds**:
  - Never pass plaintext passwords via `-a <password>` on the CLI; always load `REDISCLI_AUTH` from `"$HOME/.redis-<target>.env"`.
  - **STRICT PROHIBITION**: If local `redis-cli` or `.env` is missing, **NEVER** extract passwords from `.env` files to run `ssh <host> "docker exec ... redis-cli -a ..."` as a workaround.
- **Port Allocation Invariant**:
  - `6379`: Local Redis direct connection (Sail).
  - `5540`: **RESERVED FOR REDIS INSIGHT (HTTP Web GUI)**. NEVER point `redis-cli` or SSH tunnels to 5540.
  - `6380`: Dedicated local port for SSH Tunnel forwarding to remote staging Redis instances.

---

## 3. Decision Matrix: Query Target

```text
[User Request]
       |
       +--> Phase 0: Pre-flight Readiness Check
       |      1. OS Guard: Must be macOS (`uname -s` == "Darwin")
       |      2. Binary Check: Resolve $REDIS_BIN (PATH -> /opt/homebrew -> /usr/local)
       |      3. Config Check: Verify `$HOME/.redis-<target>.env` exists
       |      |
       |      +--> [ANY CHECK FAILS (e.g., Windows/WSL, no redis-cli, or no .env)]
       |             🛑 PAUSE & ASK USER!
       |             Report the exact missing prerequisite / OS mismatch, and ask user whether to:
       |             (a) Switch to an alternative query method (e.g., Sail/Docker/Tinker for local, or user-specified method)
       |             (b) Set up the missing environment first
       |
       +---> [ALL CHECKS PASS] -> Query Local Redis (Sail, target=test0)
       |       |
       |       +--> Verify local Redis is active: `nc -zv 127.0.0.1 6379`
       |       +--> Source `$HOME/.redis-test0.env` (port=6379) & execute via `"$REDIS_BIN"`
       |
       +---> [ALL CHECKS PASS] -> Query Remote Staging (e.g., target=test4)
               |
               +--> Step 1: Detect remote Redis container IP (prevent IP drift)
               +--> Step 2: Establish local SSH Tunnel on 127.0.0.1:6380
               +--> Step 3: Validate tunnel handshake (`nc -zv 127.0.0.1 6380`)
               +--> Step 4: Source `$HOME/.redis-<target>.env` (port=6380) & execute via `"$REDIS_BIN"`
```

---

## 4. Execution Pipeline for Redis Queries

### Phase 0: Pre-flight Environment & OS Check (Mandatory First Step)
Before running any tunnel or Redis command, verify OS compatibility (must be macOS, not Windows or WSL), `redis-cli` binary availability, and the target `.env` file in a single read-only check:
```bash
OS_NAME=$(uname -s 2>/dev/null || echo "Windows")
REDIS_BIN=$(command -v redis-cli || ls /opt/homebrew/bin/redis-cli /usr/local/bin/redis-cli 2>/dev/null | head -n 1)
ENV_FILE="$HOME/.redis-<target>.env"

echo "OS=${OS_NAME} | REDIS_BIN=${REDIS_BIN:-MISSING} | ENV=$([ -f "$ENV_FILE" ] && echo OK || echo MISSING)"
```
- **Pause Condition & Standard Prompt Template**: If `OS != Darwin` (e.g., Windows PowerShell, CMD, or WSL `Linux`), OR `REDIS_BIN == MISSING`, OR `ENV == MISSING`:
  1. **STOP executing this skill immediately.** Do not proceed to Phase 1, and do not silently improvise workarounds.
  2. **Output the following standardized prompt (in Traditional Chinese)** so the user can quickly choose the next action:
     > ⚠️ **`remote-redis-query` 環境檢查未通過，已暫停執行：**
     > - **作業系統**：`<OS_NAME>`（本 Skill 僅適用 macOS `Darwin`）
     > - **`redis-cli` 狀態**：`<已安裝路徑 或 未安裝>`
     > - **設定檔 `~/.redis-<target>.env`**：`<存在 或 缺少>`
     >
     > 請問您希望如何處理？
     > 1. **改用當前環境的容器/框架工具查詢**（例如本地 Sail：`./vendor/bin/sail redis`、`docker exec` 或 `artisan tinker`）
     > 2. **由您指定此環境的連線方式**（請提供指令或連線資訊）
     > 3. **先補齊 macOS `redis-cli` / `.env` 設定後再重試**

### Phase 1: Dynamic Container IP Discovery (Remote Only - Avoid IP Drift)
Do not hardcode remote Docker container IPs. Use single-quoted regex extraction over `/proc/<pid>/net/fib_trie` so command substitution `$(...)` never strips `$` variables:
```bash
REMOTE_REDIS_IP=$(ssh <host_alias> 'grep -B 1 "/32 host LOCAL" /proc/$(pgrep -o redis-server)/net/fib_trie | grep -Eo "172\.[0-9]+\.[0-9]+\.[0-9]+" | head -n 1')
echo "REMOTE_REDIS_IP=${REMOTE_REDIS_IP}"
```

### Phase 2: Tunnel Lifecycle Management (Remote Only)
Ensure no stale processes (including tunnels from a previously queried remote host) bind to `6380`, then spawn the background tunnel:
```bash
pkill -f "127.0.0.1:6380:" || true
ssh -f -N -L 127.0.0.1:6380:${REMOTE_REDIS_IP}:6379 <host_alias>
```

### Phase 3: Tunnel Health Verification
Verify that the local endpoint (`6379` for local, `6380` for remote tunnel) is listening and responsive:
```bash
nc -zv 127.0.0.1 6380
```
*Expected output: `Connection to 127.0.0.1 port 6380 succeeded!`*

### Phase 4: Multi-DB Discovery & Safe Query Execution
Laravel projects typically distribute data across multiple logical databases with a `laravel_database_` prefix:
- **`db0` (`-n 0`)**: Default connection, queues, sessions, temporary tokens, BAM transaction timestamps.
- **`db1` (`-n 1`)**: Laravel Cache (`Cache::get()`, system settings, permission cache, merchant quotas).
- **`db2` (`-n 2`)**: Extended application states (e.g., BAM account error tracking).

Always load the environment profile safely (unsetting `REDISCLI_AUTH` if empty to avoid warning noise) and inspect `keyspace` first if the target DB index is unknown:
```bash
set -a && source "$HOME/.redis-<target>.env" && set +a
[ -z "$REDISCLI_AUTH" ] && unset REDISCLI_AUTH

# 1. Overview of populated databases
"$REDIS_BIN" -h "$REDISCLI_HOST" -p "$REDISCLI_PORT" INFO keyspace

# 2. Non-blocking search in target database (e.g., -n 1 for Cache)
"$REDIS_BIN" -h "$REDISCLI_HOST" -p "$REDISCLI_PORT" -n 1 SCAN 0 MATCH "*<keyword>*" COUNT 100

# 3. Check key type and TTL before reading value (avoids WRONGTYPE error)
"$REDIS_BIN" -h "$REDISCLI_HOST" -p "$REDISCLI_PORT" -n 1 TYPE "<full_key_name>"
"$REDIS_BIN" -h "$REDISCLI_HOST" -p "$REDISCLI_PORT" -n 1 GET "<full_key_name>"
```

---

## 5. Automated Failure Diagnostics & Remediation

| Error Signature | Root Cause | Automated Remediation Action |
| :--- | :--- | :--- |
| `OS != Darwin` (Windows / WSL / Linux) | Skill invoked on a non-macOS machine. | **Pause & Ask User**: Output the standard Phase 0 prompt and ask how the user wants to query on the current OS. |
| `REDIS_BIN=MISSING` or `ENV=MISSING` | Local machine lacks `redis-cli` or `~/.redis-<target>.env`. | **Pause & Ask User**: Report exact missing item via standard Phase 0 prompt. |
| `AUTH failed: WRONGPASS` / `NOAUTH Authentication required` | `REDISCLI_AUTH` in `~/.redis-<target>.env` is empty, incorrect, or contains trailing spaces/comments. | Verify `REDISCLI_AUTH=<password>` in `~/.redis-<target>.env` matches the target server's `REDIS_PASSWORD` (no trailing comments on the same line). Also ensure `pkill -f "6380"` was run before switching between different remote hosts (e.g., `test4` -> `test3`). |
| `(nil)` returned when querying a known cache key | 1. Querying `db0` instead of `db1` (`-n 1`).<br/>2. Missing `laravel_database_` prefix. | 1. Run `INFO keyspace` to check active DB indices.<br/>2. Run `SCAN 0 MATCH "*<keyword>*" COUNT 100` across `-n 0`, `-n 1`, `-n 2`. |
| `WRONGTYPE Operation against a key holding the wrong kind of value` | Using `GET` on a `hash`, `list`, `set`, or `zset`. | Run `TYPE <key>` first, then use `HGETALL` (hash), `LRANGE <key> 0 -1` (list), `SMEMBERS` (set), or `ZRANGE <key> 0 -1 WITHSCORES` (zset). |
| `bind [127.0.0.1]:6380: Address already in use` | An orphan SSH tunnel is holding port 6380. | Execute `pkill -f "6380"` and re-run Phase 2. |
| `Could not connect to Redis at 127.0.0.1:6380: Connection refused` / reset | Remote Redis container restarted and its internal Docker IP drifted. | Re-run Phase 1 to detect fresh container IP and restart tunnel in Phase 2. |


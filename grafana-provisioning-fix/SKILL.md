---
name: Grafana Provisioning Lock Fixer
description: Detects and resolves "Provenance Mismatch" (HTTP 409) errors in Grafana, where resources cannot be deleted via API because they are locked by file provisioning.
---

# Grafana Provisioning Lock Fixer

This skill helps resolve the stubborn **HTTP 409 Conflict** error when trying to modify or delete Grafana resources (Dashboards, Alert Rules, Contact Points) via API.

## 🚨 Symptom Detection

Look for error logs containing:
- `HTTP 409`
- `messageId: alerting.provenanceMismatch`
- `cannot delete with provided provenance '', needs 'file'`
- `StoredProvenance: file`

This means the resource was originally created by a YAML file (Provisioning) and Grafana's database has locked it to prevent API modifications.

## 🛠 Fix Strategy: The SQLite Surgery

Since the API is blocked, the most reliable fix is to modify the Grafana SQLite database directly to remove the "lock" (provenance record).

### Method 1: Automated Fix via Docker (Recommended)
If you are running in Docker Compose, you can perform this fix dynamically.

1. **Mount Volume**: Ensure your setup container mounts the Grafana data volume.
   ```yaml
   volumes:
     - grafana-data:/var/lib/grafana
   ```
2. **Install SQLite**: Ensure `sqlite3` is available in your container.
3. **Execute SQL**:
   ```bash
   # For Grafana v11+ (stored in 'provenance_type' table)
   sqlite3 /var/lib/grafana/grafana.db "DELETE FROM provenance_type WHERE record_key = '$UID';"
   
   # For older versions (sometimes stored directly in resource table)
   sqlite3 /var/lib/grafana/grafana.db "UPDATE alert_rule SET provenance = NULL WHERE uid = '$UID';"
   ```

### Method 2: Manual Interactive Fix
1. Enter the Grafana container:
   ```bash
   docker compose exec grafana bash
   ```
   (Installing sqlite3 might be required: `apk add sqlite`)
2. Run the cleanup command:
   ```bash
   sqlite3 /var/lib/grafana/grafana.db "DELETE FROM provenance_type WHERE record_key = 'YOUR_LOCKED_UID';"
   ```

## 📦 Resource Script
A reference script `fix_provenance.sh` is provided in the `resources/` folder. It encapsulates the check and fix logic.

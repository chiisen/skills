#!/bin/bash
# fix_provenance.sh
# Usage: ./fix_provenance.sh <UID_TO_FIX> [GRAFANA_DB_PATH]

UID_TO_FIX="$1"
DB_PATH="${2:-/var/lib/grafana/grafana.db}"

if [ -z "$UID_TO_FIX" ]; then
    echo "Usage: $0 <UID_TO_FIX> [DB_PATH]"
    exit 1
fi

if [ ! -f "$DB_PATH" ]; then
    echo "Error: Database file not found at $DB_PATH"
    echo "Ensure you have mounted the Grafana volume correctly."
    exit 1
fi

echo "🔍 Checking for provenance lock on UID: $UID_TO_FIX..."

# Check if lock exists (Grafana v11+ structure)
LOCK_EXISTS=$(sqlite3 "$DB_PATH" "SELECT count(*) FROM provenance_type WHERE record_key = '$UID_TO_FIX';")

if [ "$LOCK_EXISTS" -gt 0 ]; then
    echo "⚠️ Lock found! (Count: $LOCK_EXISTS). Removing..."
    sqlite3 "$DB_PATH" "DELETE FROM provenance_type WHERE record_key = '$UID_TO_FIX';"
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed provenance lock for $UID_TO_FIX"
    else
        echo "❌ Failed to remove lock."
        exit 1
    fi
else
    echo "ℹ️ No lock found for $UID_TO_FIX in provenance_type table."
    # Optional: Check older table structure fallback if needed
fi

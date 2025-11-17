#!/usr/bin/env bash
set -euo pipefail

OUT="/var/lib/node_exporter/textfile_collector/updates.prom"
COUNT=0

# Debian/Ubuntu update count
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -qq || true
  COUNT=$(apt list --upgradable 2>/dev/null | grep -v 'Listing' | wc -l || true)
fi

# Validate numeric
if ! echo "$COUNT" | grep -Eq '^[0-9]+$'; then
  COUNT=0
fi

cat > "$OUT" <<EOM
# HELP updates_available_total Number of package updates available
# TYPE updates_available_total gauge
updates_available_total $COUNT
EOM

chmod 644 "$OUT"
chown node_exporter:node_exporter "$OUT"

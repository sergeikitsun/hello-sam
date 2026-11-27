#!/usr/bin/env bash
# Invoke the running local Lambda.
# Usage: scripts/invoke.sh [payload] [port]
#   payload defaults to @events/event.json (curl @file syntax); pass raw JSON too.
set -euo pipefail
cd "$(dirname "$0")/.."

PAYLOAD="${1:-@events/event.json}"
PORT="${2:-8080}"

curl -s -XPOST "http://localhost:${PORT}/2015-03-31/functions/function/invocations" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
echo

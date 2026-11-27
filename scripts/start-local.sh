#!/usr/bin/env bash
# Start the Lambda Runtime Interface Emulator (RIE) with the compiled function.
# Usage: scripts/start-local.sh [address]   (default 0.0.0.0:8080)
set -euo pipefail
cd "$(dirname "$0")/.."

ADDR="${1:-0.0.0.0:8080}"
FUNC="./src/HelloWorld/bin/Release/net8.0/linux-x64/publish/bootstrap"

if [ ! -x "$FUNC" ]; then
  echo "Function not built yet. Run scripts/build.sh first." >&2
  exit 1
fi

if [ -f rie.pid ] && kill -0 "$(cat rie.pid)" 2>/dev/null; then
  echo "RIE already running (pid $(cat rie.pid))."
  exit 0
fi

setsid ./aws-lambda-rie --runtime-interface-emulator-address "$ADDR" "$FUNC" \
  > rie.log 2>&1 < /dev/null &
echo $! > rie.pid
sleep 1

echo "RIE started on http://localhost:${ADDR##*:} (pid $(cat rie.pid)). Logs -> rie.log"
